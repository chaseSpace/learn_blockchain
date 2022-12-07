// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/introspection/IERC1820Registry.sol)

pragma solidity ^0.8.0;
/*
@ERC777功能型代币标准

## 背景
- ERC20代币使用简洁，很适合用来代表某种权益，不过想在其之上添加一些功能，就会力不从心。如下：
    - 使用ERC20代币购买商品时，该合约无法记录购买具体商品的信息，需要添加额外的代码，并且不便实现
    - 在经典的存币生息Defi应用中，理想情况是代币转入存币生息合约后，后者开始生息，然后由于ERC20的缺陷，合约无法知道有人转账到合约（没有转账通知），因此无法开始计息。
- ERC20有一个较大的问题，代币误转入一个ERC20合约后，若合约没有对代币做相应处理，则代币将永远被锁死在合约中。ERC777则解决了这个问题。

## ERC777介绍
- ERC777兼容ERC20，同时新增了一些功能函数，如send(dest, value, data)，send具备ERC20的transfer功能，但支持额外的data参数记录转账备注
    -   send()调用成功时同时会对转账者和收款者发送通知，以便转账时二者进行额外处理
    -   send()的通知是通过ERC1820接口注册表合约实现的
- 所以主要是增加hook等功能使智能合约在事件发生时能够作出反应或执行特定的操作，从而给予代币持有者更多的控制权。这样做的好处是可以避免代币被发送到错误的目的地址从而丢失代币的情况
- ERC777标准向后兼容ERC20，这允许与这些代币无缝交互，还增加了一些改进，所以建议开发新代币时使用ERC777
*/

// 部署时注释这三行
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/utils/introspection/ERC1820implementer.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/utils/introspection/IERC1820Registry.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/utils/introspection/ERC1820Implementer.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC777/ERC777.sol";

// 1. 演示使用ERC777发行代币M7
// 直接继承ERC777模板代码，稍作修改即可
contract MyTokenERC777 is ERC777 {
    constructor(address[] memory defaultOperators) ERC777("MyToken777", "M7", defaultOperators) {
        // 发行2100w个代币
        uint initialSupply = 21000000 * 10 ** 18;
        // 给部署者账户发送全部发行量的M7代币
        _mint(msg.sender, initialSupply, "", "");
    }
    // 下面对 ERC777 的内部代码进行说明

    // 0. ERC777中保留有ERC20中的name, symbol, totalSupply等字段逻辑

    // 1. constructor, 在ERC777的构造器中，会调用ERC1820的接口对ETC777和ERC20标准进行注册，如下
    /*
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    */

    // 2. 增加一个 function granularity() public view returns (uint256)  定义了代币最小操作粒度(>=1)，只能在创建时设定，无法更改
    //    在铸币、转账和销毁步骤，操作的代币数量必须是粒度的整数倍。decimal()定义的是代币存储单位，granularity()是在其之上的划分，
    //    比如granularity()=2表示一次操作的代币数必须的2的整数倍

    // 3. ERC777 引入了操作员（operator）的角色，定义为操作代币的角色，默认代币持有者就是代币的操作员；但可以授权其他人操作自己的代币。
    //    1. 与ERC20中的approve、transferFrom稍有不同，ERC20未明确定义批准地址的角色，只是叫做spender。
    //    2. 合约中默认初始化一批项目管理员(_defaultOperators)，可以管理所有人的代币，用户可以添加、撤销和查询属于自己的管理员地址

    // 4. ERC777 关键带来的是两个转账函数，它们执行成功后都会触发对应事件
    //      1. send(address recipient, uint256 amount, bytes memory data)   一般转账函数，data字段为转账备注
    //      2. operatorSend(address sender, address recipient, uint256 amount, bytes memory data, bytes memory operatorData)  管理员代替持有者转账
    //    它们都会调用一个共同的函数 _send(...) 来执行核心逻辑，_send 在执行真正的转账操作前还会调用 _callTokensToSend()，后者的逻辑是
    //        通过ERC1820检查实际代币转账者和收款者地址是否实现了对应钩子函数，若实现了则调用，钩子函数和调用时机分别是
    //        - IERC777Sender(from).tokensToSend()  转账前
    //        - IERC777Recipient(to).tokensReceived() 转账后，注意，在send和operatorSend调用时（transfer不要求），若收款者是合约地址，则这个钩子函数是必须实现的，否则交易回退！避免了代币锁死到一个无效合约地址
    //        钩子函数会将 _send()的所有参数原样传递给过去，以通知转账者和收款者，方便它们执行个性化逻辑。所以如果转账者和收款者希望收到通知，则需要实现对应钩子函数

    // 5. ERC777增加了铸币和销毁代币的函数。在ERC20中没有明确定义这两个行为，只是用transfer来表达，即来自全零地址的转账是铸币，转给全零地址是销毁。
    //      ERC777则定义了代币的铸币（_minted）、转移（send/operatorSend）和销毁（burn/operatorBurn）全过程。
    //      1. 铸币：由于很多代币在发布时就确定了总发行量，所以铸币功能并不是必须的。ERC777只定义了 _minted()函数以及 Minted事件，若发行者要增加铸币功能，则必须按照规范调用 _minted()
    //              铸币的过程类似转账，就是给一个账户转入N个代币，N会累加到totalSupply，同时操作会触发 Minted和Transfer事件
    //      2. 转移：上面说过了。
    //      3. 销毁：由操作员调用此函数，销毁的代币数量不能超过拥有的，销毁会在totalSupply中减去销毁的数量。最后触发Burned和Transfer事件
    //      4. 上面的操作都应该正常支持代币数量为0的情况。
}


// 2. 演示如何为收款者合约实现tokensReceived的钩子函数
// - 场景假设：寺庙实现了功德箱合约，在收取代币时需要记录每位施主的善款金额，并实现tokensReceived的钩子函数
contract Merit is IERC777Recipient {
    mapping(address => uint) public givers;
    address _owner;
    IERC777 _m7_token;
    IERC1820Registry internal _erc1820 = IERC1820Registry(0xd9145CCE52D386f254917e481eB44e9943F39138);
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    event WithdrawOK(address, address, uint256);
    constructor(IERC777 token)  {
        // 这个合约地址作为收款地址，可以为自己实现ERC777TokensRecipient 方法，从而在转账时能够被代币合约调用
        _erc1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
        _owner = msg.sender;
        _m7_token = token;
    }
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        givers[from] += amount;
    }

    // 方丈提现（将这个合约地址中的M7代币全部转入自己的地址）
    function withdraw() external {
        require(msg.sender == _owner, "no permission");
        uint balance = _m7_token.balanceOf(address(this));
        _m7_token.send(_owner, balance, "");

        emit WithdrawOK(address(this), _owner, balance);
    }
}

// 部署一个临时合约查看一个hash值，下面会用到，也可以通过 http://tools.jb51.net/password/hash_md5_sha 查询 sha3-256("ERC777TokensSender")
//  其实就是 0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895，作为合约参数使用时前面加0x
contract QueryHash{
    event erc777_token_sender_hash(bytes32);
    constructor () {
        emit erc777_token_sender_hash(keccak256("ERC777TokensSender"));
    }
}


// 3. 如果代币持有者想要对转账操作进行更多控制，比如黑名单内的收款地址不允许转账等，就需要为自己的转账地址实现 `ERC777TokensSender`
//  - 然而这与实现`ERC777TokensRecipient`不同，因为转账地址一般不是一个合约地址，是个外部账户，那该如何为外部账户实现接口呢？
//  - 方法：编写一个代理合约（代理是字面意思）为外部账户实现该接口。原理是外部账户调用ERC1820的 setInterfaceImplementer(address account, bytes32 _interfaceHash, address implementer)时，该函数有个要求：
//          如果 account 不等于 implementer，则验证implementer是否实现 canImplementInterfaceForAddress(bytes32 interfaceHash, address account)并正确返回keccak256("ERC1820_ACCEPT_MAGIC")，
//          若返回正确则可以成功注册！所以现在只需要代理合约实现这个接口（这个账号）
//  - # 部署此代理合约后，再通过ERC1820Registry的地址手动调用其 setInterfaceImplementer 为外部账户设置接口接口，参数分别是：
//      <外部账户> <0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895（也就是keccak256("ERC777TokensSender")）> <此代理合约地址>
//      若调用成功说明代理合约实现正确！
contract SenderControl is IERC777Sender, IERC1820Implementer {
    IERC1820Registry internal _erc1820 = IERC1820Registry(0xd9145CCE52D386f254917e481eB44e9943F39138);
    bytes32 private constant _ERC1820_ACCEPT_MAGIC = keccak256("ERC1820_ACCEPT_MAGIC");

    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");

    mapping(address => bool) blacklist;
    address _owner;

    constructor() {
        _owner = msg.sender;
    }

    function canImplementInterfaceForAddress(bytes32 interfaceHash, address account) external view returns (bytes32) {
        // 我们这个代理合约较为简单，仅为部署者地址实现 canImplementInterfaceForAddress。当然，还可以为其他账户实现，比如实现一个 addERC777TokensSenderAccount() 函数
        if (interfaceHash == _TOKENS_SENDER_INTERFACE_HASH && _owner == account) {
            return _ERC1820_ACCEPT_MAGIC;
        }
        return bytes32(0x00);
    }

    // 实现钩子函数
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external{
        if (blacklist[to]) {
            revert("ohh... recipient is on blacklist!");
        }
    }

    // 允许部署者更新黑名单
    function updateBlacklist(address account, bool _block) public {
        require(msg.sender == _owner, "no permission!");
        if (_block) {
            blacklist[account] = true;
        }else {
            delete blacklist[account];
        }
    }
}