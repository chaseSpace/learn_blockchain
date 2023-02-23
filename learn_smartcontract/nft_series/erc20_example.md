# 通过USDT学习ERC-20

- [1. ERC-20介绍](#ERC-20介绍)
    - [1.1 产生背景](#11-产生背景)
    - [1.2 诞生](#12-诞生)
    - [1.3 标准内容](#13-标准内容)
    - [1.4 流行的ERC-20代币](#14-流行的ERC-20代币)
    - [1.5 铸币和销毁代币](#15-铸币和销毁代币)
    - [1.6 使用代币](#16-使用代币)
- [2. 通过USDT学习ERC-20](#2-通过USDT学习ERC-20)
    - [2.1 说明](#21-说明)
    - [2.2 以太坊USDT合约](#22-以太坊USDT合约)
    - [2.3 波场USDT合约](#23-波场USDT合约)
    - [2.4 币安智能链USDT合约](#24-币安智能链USDT合约)
- [3. USDT背后的货币经济](#3-USDT背后的货币经济)
    - [3.1 什么是稳定币](#31-什么是稳定币)
    - [3.2 还有哪些稳定币](#32-还有哪些稳定币)
    - [3.3 什么支撑USDT的价值](#33-什么支撑USDT的价值)
    - [3.4 算法稳定币](#34-算法稳定币)

## 1. ERC-20介绍

- 一项以太坊区块链之上的同质化代币标准Ethereum Request for Comment 20 (ERC-20)，基于智能合约实现;
- 就像传统货币一样，它可以和自己以及NFT（非同质化代币）之间互换（RMB可以互换以及购买物品）；
- 自从推出以来，以太坊区块链上已经有非常多的ERC-20代币被发行，比如USDT/DAI/UNI/CRV等；
- 是以太坊区块链（甚至是整个web3世界）的第一项具有历史意义的基于智能合约的代币标准，它后来的流行程度也影响了其他区块链平台；

### 1.1 产生背景

区块链上有许多dApp，它们之间的交流需要一种标准化的代币，不可能说每个dApp都创建自己的代币，那样无法快速使dApp流行，这是一种来自于市场的需求。

### 1.2 诞生

ERC-20由开发者 Fabin Vogelstellar 在2015年在以太坊区块链上提出。刚好因为是第20个Ethereum Request for Comment (ERC)，所以叫ERC-20。

按照以太坊开发者社区的流程，该提案在2017年被批准并实施为 Ethereum Improvement Proposal 20（EIP-20）。然而，它仍然被称为ERC-20， 因为这就是它被批准之前的流行叫法。

官方链接：[ERC-20][0]

### 1.3 标准内容

一般来说，只要是代币类的ERC，其内容都是要求代币合约所必须定义的一些函数和事件。ERC-20代币标准要求的函数列表如下：

- TotalSupply：查看此合约发行的ERC-20代币总量
- BalanceOf：查看某账户余额
- Transfer：owner转账
- TransferFrom：spender使用owner的代币进行转账，金额不能超过allowance（以及owner余额）
- Approve：owner给spender授权一定的自己账户的转账额度
- Allowance：查看owner给spender授权的可转账额度

除了函数，还有两个必须的事件：

- Transfer：转账成功触发的事件
- Approval：给某账户授权一定额度的事件

另外，还有一些可选的扩展（为了增强可用性），由于扩展较多，这里举一个例子`IERC20Metadata`，它要求定义如下函数：

- name：代币名称（如 Tether USD）
- symbol：符号（如USDT）
- decimals：小数点后精度（如6，表示允许小数点后最多6位）

需要说明的是，官方只定义了ERC-20代币合约必须的函数和事件接口，并无具体实现要求，所以任何人都可以拥有自己的实现。但通常这种时候， 业界都会出现一些流行度很高的模板实现，比如 [OpenZeppelin][2]，**
但它们可能并不是最优实现**，所以采用它们的代码时开发者需要了解其实现逻辑做到心中有数。

关于ERC-20的其他扩展，读者可以直接到 [OpenZeppelin插件库][1] 中查看。
> OpenZeppelin 是一个包含各种ERC标准模板实现的智能合约开发库，其代码经过安全审计，一般情况下可以直接使用或引用，但仍然建议开发者在使用前掌握其实现逻辑。

### 1.4 流行的ERC-20代币

- Tether USD (USDT)
- USD Coin (USDC)
- Shiba Inu (SHIB)
- Binance USD (BUSD)
- BNB (BNB)
- DAI Stablecoin (DAI)
- HEX (HEX)
- Bitfinex LEO (LEO)
- MAKER (MKR)

注意，ERC-20代币除了在以太坊区块链上发行，同时也可以在其他以太坊兼容链上发行，比如 [以太坊USDT][3] 、 [波场USDT][4] 和 [BSC USDT][5]，
并且不同区块链平台上USDT的部分属性还可以是不同的（属性在合约部署时写入），比如`totalSupply`和`decimals`。

### 1.5 铸币和销毁代币

**铸币**操作为某个账户增加代币余额，这些代币是即时创造的，而不是原本就流通于市场的，通常只有代币发行方能够执行这个操作。

**销毁代币**
操作是指将某个账户中的一部分代币转移到一个无法转出的账户中（比如0地址），这个操作将使得这部分代币永久从流通中移除（减少代币的总供应量）。代币销毁类似于股票回购。什么是股票回购？股票回购发生在公司通过公开市场或从其股东手中回购其股票时。公司使用回购来增加股权价值。

ERC-20代币充当了一种区块链上的通用货币角色，既然是货币，就得受到市场影响，逃不了通胀与通缩，**通胀时**就需要代币发行方来销毁部分代币（通常会先回购散户手中的代币，再销毁），以推高人们账户中的单位代币的价格。
而通缩时，发行方又可以通过铸币（`mint`）来增加总发行量。总的来说，代币发行方需要通过铸币和销毁代币来调节所发行代币的价格（更多是推高），以增加代币稳定性。

### 1.6 使用代币

ERC20代币是基于以太坊智能合约之上运行的，而我们使用这个代币的方式本质上就是调用合约的各种函数（获取代币余额、转账等），而与合约交互需要通过发送以太坊交易的方式来进行。
经过不断发展，现在我们可以通过区块链浏览器或者浏览器钱包的方式与代币合约快速交互，非常方便。
> 现在大部分浏览器钱包都已经支持添加ERC20代币，如小狐狸钱包、imToken钱包等。

## 2. 通过USDT学习ERC-20

### 2.1 说明

笔者将通过 [以太坊USDT][3] 、 [波场USDT][4] 和 [币安智能链USDT][5]三个区块链平台上发布的代币合约代码进一步讲解ERC-20，继续阅读要求读者对合约基础知识以及Solidity语法有基本了解。

下面是三个平台上USDT合约的简介:

- 以太坊USDT合约：部署于2017-11-28、合约复杂度-简单
- 波场USDT：部署于2019-04-16、合约复杂度-较高
- 币安智能链USDT：部署于2020-09-04、合约复杂度-一般、基于BEP-20（BSC链的标准，是ERC-20的扩展，与其兼容）

对于每个合约，笔者都只（在代码中通过注释）介绍其重点，下面根据合约部署顺序进行介绍。

### 2.2 以太坊USDT合约

源码如下（部分简单代码未贴出，但会注明）：

<details>
  <summary>展开查看</summary>
  <pre>

```solidity
// solidity v0.4.18
// 单独写的一个进行安全算数运算的lib，这个合约部署的时间在 OpenZeppelin 库之前，将被绑定
library SafeMath {/* ... */}

// 一个简易的函数调用权限控制合约，后来在OZ中也有，将被继承
contract Ownable {/* ... */}

// 父合约：ERC20的基础函数以及事件，将被继承
contract ERC20Basic {
    uint public _totalSupply;

    function totalSupply() public constant returns (uint);

    function balanceOf(address who) public constant returns (uint);

    function transfer(address to, uint value) public;

    event Transfer(address indexed from, address indexed to, uint value);
}

// 父合约：同上
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint);

    function transferFrom(address from, address to, uint value) public;

    function approve(address spender, uint value) public;

    event Approval(address indexed owner, address indexed spender, uint value);
}

// 父合约：Token的基础功能实现（继承上面的两个合约），同时仍然将被继承
contract BasicToken is Ownable, ERC20Basic {
    // 给uint类型绑定lib，以便进行安全算数运算
    using SafeMath for uint;
    // map映射账户到余额
    mapping(address => uint) public balances;

    // 用于控制转账手续费的变量（后续可更改）
    uint public basisPointsRate = 0;
    uint public maximumFee = 0;

    // 类似Python装饰器，绑定到转账函数，防止ERC20的短地址攻击
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    // 转账函数
    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        // 计算待扣减的手续费
        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        // 基本的A- B+ 操作，注意转账金额扣除了手续费
        uint sendAmount = _value.sub(fee);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            // 手续费会被转入合约owner账户（注意是ERC20代币，不是ETH）
            balances[owner] = balances[owner].add(fee);
            // 记录转手续费的event（早期Solidity版本触发事件不需要emit）
            Transfer(msg.sender, owner, fee);
        }
        // 记录转给to地址的event
        Transfer(msg.sender, _to, sendAmount);
    }
    // 余额查询
    function balanceOf(address _owner) public constant returns (uint balance) {/* ... */}
}

// 父合约：StandardToken
contract StandardToken is BasicToken, ERC20 {
    // 实现ERC20的几个函数，重点实现了授权转账的功能
    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {/* ... */}

    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {/* ... */}

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {/* ... */}
}

// 父合约：控制Token的转账开关
contract Pausable is Ownable {/* ... */}

// 父合约：实现黑名单功能（将转账人加入/移除黑名单）
contract BlackList is Ownable, BasicToken {
    /* ... */
    // 关键函数：销毁（不是没收）某个黑名单账户下的全部ERC20代币
    function destroyBlackFunds(address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        // 触发事件
        DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
}

// 父合约：【技巧】给几个关键函数提供可升级功能（具体看下面的主合约实现）
contract UpgradedStandardToken is StandardToken {
    function transferByLegacy(address from, address to, uint value) public;

    function transferFromByLegacy(address sender, address from, address spender, uint value) public;

    function approveByLegacy(address from, address spender, uint value) public;
}

// 主合约
contract TetherToken is Pausable, StandardToken, BlackList {
    string public name;
    string public symbol;
    uint public decimals;
    // 重要：未来的升级合约地址
    address public upgradedAddress;
    //  是否抛弃此主合约，如果是，主合约中的几个重要函数都将转发请求至升级合约，具体看下面
    bool public deprecated;

    // 早期Solidity版本没有构造函数，此函数作为init函数
    function TetherToken(uint _initialSupply, string _name, string _symbol, uint _decimals) public {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;
        deprecated = false;
    }
    // 转账函数：注意 deprecated 和 upgradedAddress 的使用（这两个变量允许在下面的函数中修改）
    // - 注意使用了装饰器 whenNotPaused，表示只能在合约开启时执行本函数
    function transfer(address _to, uint _value) public whenNotPaused {
        require(!isBlackListed[msg.sender]);
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            // 如果未抛弃主合约，则调用BasicToken中的transfer函数
            return super.transfer(_to, _value);
        }
    }

    // 授权转账函数
    function transferFrom(address _from, address _to, uint _value) public whenNotPaused {/* ... */}

    /* 省略部分 */

    // 此函数在修改deprecated的同时填入upgradedAddress
    function deprecate(address _upgradedAddress) public onlyOwner {
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        Deprecate(_upgradedAddress);
    }

    // （铸币）添加ERC20代币的总供应量，注意代币是转入owner账户
    function issue(uint amount) public onlyOwner {
        require(_totalSupply + amount > _totalSupply);
        require(balances[owner] + amount > balances[owner]);

        balances[owner] += amount;
        _totalSupply += amount;
        Issue(amount);
    }
    // （销毁/燃烧）减少ERC20代币的总供应量，注意代币是从owner账户扣减
    function redeem(uint amount) public onlyOwner {
        require(_totalSupply >= amount);
        require(balances[owner] >= amount);

        _totalSupply -= amount;
        balances[owner] -= amount;
        Redeem(amount);
    }

    /* 省略部分 */
}

```

</pre>
</details>

### 2.3 波场USDT合约

这个合约的逻辑稍微复杂一点，分三部分介绍，**相同的代码将不再注释说明**，第一部分是基础部分：

<details>
  <summary>展开查看</summary>
  <pre>

```solidity
// solidity v0.4.25
contract ERC20Basic {
    function totalSupply() public constant returns (uint);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {

    /* ... */

    // 相对于以太坊USDT合约，去除了onlyPayloadSize装饰器，笔者推测是此合约使用的Solidity版本已经修复了该问题
    function transfer(address _to, uint256 _value) public returns (bool) {}
}

contract BlackList is Ownable {
    /* ... */
    // 相对于以太坊USDT合约，去除了event
}

// 【此合约定义未找到使用位置】
contract Migrations {/* ... */}

// 简单的权限util合约
contract Ownable {/* ... */}

// 简单的合约状态控制
contract Pausable is Ownable {/* ... */}

// 算数库
library SafeMath {/* ... */}

// 函数签名定义
contract ERC20 is ERC20Basic {/* ... */}

// 标准token的函数定义
contract StandardToken is ERC20, BasicToken {/* ... */}

// 实现包含转账手续费的转账逻辑
contract StandardTokenWithFees is StandardToken, Ownable {/* ... */}
```

</pre>
</details>

第二部分是多签名账户交易管理合约（注意此合约未被主合约引用，**实际没有意义**）：

<details>
  <summary>展开查看</summary>
  <pre>

```solidity
// 父合约：实现多签名账户管理
contract MultiSigWallet {
    // 管理的多签名账户数量上限
    uint constant public MAX_OWNER_COUNT = 50;

    /* 定义一些事件 */

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint public required; // 必须确认的账户数量
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    // 装饰器：仅合约owner能调用（权限控制）
    modifier onlyWallet() {
        if (msg.sender != address(this))
        // 抛出异常
            throw;
        _;
    }
    modifier ownerDoesNotExist(address owner) {/*...*/}
    modifier ownerExists(address owner) {/*...*/}
    modifier transactionExists(uint transactionId) {/*...*/}
    modifier confirmed(uint transactionId, address owner) {/*...*/}
    modifier notConfirmed(uint transactionId, address owner) {/*...*/}
    modifier notExecuted(uint transactionId) {/*...*/}
    modifier notNull(address _address) {/*...*/}
    // 装饰器：确保下面对 owners切片的管理 符合要求
    modifier validRequirement(uint ownerCount, uint _required) {/*...*/}

    // Solidity语法中，这是一个fallback函数，在合约收到未定义的函数请求时执行。另一个（主要）作用是为此合约增加【接收ETH】的功能，若没定义则无法接收ETH
    function() payable {
        if (msg.value > 0) // 如果合约收到了ETH转账
        // 则记录ETH入账的event
            Deposit(msg.sender, msg.value);
    }

    /* 下面是 public 函数*/

    //  作为构造函数，将一个地址列表写入合约存储（列表长度上限为 MAX_OWNER_COUNT）
    function MultiSigWallet(address[] _owners, uint _required)
    public
    validRequirement(_owners.length, _required)
    {
        for (uint i = 0; i < _owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == 0)
                throw;
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    // 添加owner
    function addOwner(address owner)
    public
    onlyWallet
    ownerDoesNotExist(owner)
    notNull(owner)
    validRequirement(owners.length + 1, required) {/*...*/}

    // 移除owner
    function removeOwner(address owner)
    public
    onlyWallet
    ownerExists(owner) {
        isOwner[owner] = false;
        // 注意观察这里从切片中移除元素的方式是：元素移位，长度减一
        for (uint i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        // 早期solidity版本的切片长度是单独控制，新版本已不支持语法，也不需要单独控制
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        OwnerRemoval(owner);
    }

    // 从owner切片中替换某个账户
    function replaceOwner(address owner, address newOwner)
    public
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner) {/*...*/}

    // 修改 required
    function changeRequirement(uint _required)
    public
    onlyWallet
    validRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

    // 允许管理的owner地址提交一个交易到此合约进行确认（此合约并未提供移除交易的函数）
    function submitTransaction(address destination, uint value, bytes data)
    public
    returns (uint transactionId)
    {
        // 主要逻辑是把这笔交易信息添加到合约的状态变量map中
        transactionId = addTransaction(destination, value, data);
        // 添加到 map confirmations中
        confirmTransaction(transactionId);
    }

    // 确认交易
    function confirmTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        // 执行交易，看下面
        executeTransaction(transactionId);
    }

    // 撤销交易
    function revokeConfirmation(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    // 执行交易
    function executeTransaction(uint transactionId)
    public
    notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            // 从tx map中取出交易信息，并执行（就是说之上submitTransaction时并未执行）
            Transaction tx = transactions[transactionId];
            tx.executed = true;
            if (tx.destination.call.value(tx.value)(tx.data))
                Execution(transactionId);
            // 成功执行交易事件
            else {
                ExecutionFailure(transactionId);
                // 失败执行交易事件
                tx.executed = false;
                // 并标记
            }
        }
    }

    /* ... */
}
```

</pre>
</details>

第三部分是主合约部分：

<details>
  <summary>展开查看</summary>
  <pre>

```solidity
// 可升级合约（几个关键函数的）签名定义
contract UpgradedStandardToken is StandardToken {
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    uint public _totalSupply;

    function transferByLegacy(address from, address to, uint value) public returns (bool);

    function transferFromByLegacy(address sender, address from, address spender, uint value) public returns (bool);

    function approveByLegacy(address from, address spender, uint value) public returns (bool);

    function increaseApprovalByLegacy(address from, address spender, uint addedValue) public returns (bool);

    function decreaseApprovalByLegacy(address from, address spender, uint subtractedValue) public returns (bool);
}

contract TetherToken is Pausable, StandardTokenWithFees, BlackList {
    address public upgradedAddress; // 未来的升级合约地址
    bool public deprecated;

    // 构造函数
    function TetherToken(uint _initialSupply, string _name, string _symbol, uint8 _decimals) public {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;
        deprecated = false;
    }

    // 跟以太坊合约类似，根据 deprecated 值判读是否转发请求到升级后的合约地址
    function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender]);
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            return super.transfer(_to, _value);
        }
    }

    // 下面是转账、转授权、查余额、铸币、销毁等函数定义
    /* ... */
}
```

</pre>
</details>

综上，虽然波场USDT合约代码量挺多，但部分合约未被引用，所以实际部署的合约逻辑与以太坊USDT合约是相差无几的。不过对于这种未被引用的合约代码也会出现在链上的情况，笔者也尚不清楚原理。 可以清楚的是，两个合约所使用的升级方案是一样的。

### 2.4 币安智能链USDT合约

需要先说明的是，币安智能链USDT合约中出现的BEP是币安智能链上的增强提案（类似EIP），BEP20是对ERC20的扩展，大同小异。


<details>
  <summary>展开查看</summary>
  <pre>

```solidity
interface IBEP20 {
    /* 定义了ERC20要求的函数和事件*/
}

// utils合约
contract Context {/* ... */}
// utils合约
library SafeMath {/* ... */}
// utils合约
contract Ownable is Context {/* ... */}

// 主合约
contract BEP20USDT is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor() public {
        _name = "Tether USD";
        _symbol = "USDT";
        _decimals = 18;
        _totalSupply = 30000000000000000000000000;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /* ... */

    // 普通转账
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // 授权转账
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        // 先转账
        _transfer(sender, recipient, amount);
        // 再修改授权额度，若amount超出，则会在扣减时报错（交易回滚）
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    // 设定授权转账金额的函数
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // 铸币函数
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    // 销毁（交易发送者BEP20代币）函数
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }
}
```

</pre>
</details>

通过BSC USDT合约源码，我们可以观察到，总体逻辑与前两者几乎是没有差别的，只是它这个合约代码写的更优美一点（封装度高点）。另外有个重点， 那就是这个合约**没有支持可升级**，这也挺奇怪的。

## 3. USDT背后的货币经济

### 3.1 什么是稳定币

稳定币是现实世界和加密货币之间的重要纽带。由于它们的价格与稳定的资产挂钩，例如像美元这样的中央银行发行的（法定）货币，稳定币承诺保护加密货币持有者免受波动影响，并且非常适合区块链上和区块链之间的交易和交易。

### 3.2 还有哪些稳定币

USDT的发行方Tether 公司发行了几种法定稳定币，一种与黄金挂钩。其中最普遍的是与美元挂钩的稳定币USDT，流通量约为730亿枚。

其他 Tether 发行的稳定币是：

- Tether Gold (AUXT)：与黄金价格挂钩
- Tether euro (EURT)：与欧盟共同货币挂钩
- Tether peso (MXNT)：与墨西哥比索挂钩
- Tether yuan (CNHT)：与离岸人民币挂钩

### 3.3 什么支撑USDT的价值

与传统的法币类似，如果一个国家没有实体经济支撑，那么这个国家的货币将是空中楼阁，毫无价值。同样的，随着这个国家经济发展的上行与下滑，国家货币的价值也会随之变化。

那么USDT能做到与美元同等价值，必然是因为其发行方Tether公司所公布的储备资产的声明，以确保与其价格所锚定的货币（或资产）的一对一兑换比率。类似于赌场必须在其金库中有足够的现金来支付所有筹码，储备金可以保证如果每个人都想将 USDT
转换为法定货币，他们可以。

Tether公司会定期发布其储备资产证明，根据其最新（2022）报告，Tether 的储备资产包含多种组合：

- 现金
- 现金等价物（货币市场基金、美国国库券）
- 商业票据
- 公司债券
- 贷款
- 包括数字货币在内的其他投资

当然，这些资产需要第三方审计公司进行核实才具有可信度。如果需要大量持有某一种代币，那必然要对其发行方的实际资产进行核查，避免持有的Token无法兑回法币。

### 3.4 算法稳定币

Tron 的USDD或 Waves 的USDN等算法稳定币通过交易激励和代币的自动铸造和燃烧来保持汇率，并借助**双代币吸收波动性**，**而无需外部储备资产**。下面通过著名的韩国加密货币公司 Terra 的 UST来进行说明。

LUNA币是Terra的平台代币，用于稳定币（TerraSDRs）的发行，价格稳定机制。 UST 是Terra设计的一种与美元挂钩的算法稳定币。为了铸造 UST，用户必须销毁同等价值的 LUNA （也即 $1：$1）；类似地，为了赎回
LUNA，用户将必须销毁同等价值的 UST。这意味着 UST 没有外部抵押品资产的支持，而是依靠市场激励来维持稳定。 通过一个简单的示例来了解这种机制是如何运作的:

- 假设 UST 的价格是 1.01 美元，也即高于 1 美元的锚定价格。这意味着对 UST 稳定币的需求超过了供应。在这种情况下，为了降低 UST 的价格，套利者会被激励销毁 1 美元的 LUNA 来铸造新的 UST，从而捕获 UST
  的目标锚定价格 （即 1 美元） 与当前的价格 （即 1.01 美元） 之间的 0.01 美元的差额带来的收益。
- 当 UST 的交易低于 1 美元的锚定价格时，也存在类似的套利机会，这意味着 UST 稳定币的供应超过了需求。如果 UST 的价格是 0.99 美元，套利者就会被激励销毁 UST 来铸造 1 美元的
  LUNA，并将差额收入自己腰包。这将减少 UST 的供应，从而帮助 UST 的价格提高到 1 美元的锚定价格。

#### 风险是什么？

Terra为存入UST的用户设计了一个借贷平台叫做Anchor，可以给付20%的年收益率（**这在传统存款项目中直接会被视为骗局**）。所以人们就疯狂购入LUNA来兑换UST并质押到Anchor中（付出了自己的真金白银），
这个操作使得人们大量持有LUNA和UST，大量真钱流入为LUNA凭空创造了价值，引发市场上的LUNA价值一路走高。

然而，当UST本身发生价格脱锚时，就会发生LUNA挤兑引发崩盘。

那么UST什么时候会发生价格脱锚呢？那就是当平台上的UST存款总额大大减少的时候，比如某个巨鲸地址在Anchor上大量套现（抛售UST换回LUNA），
此时市场上的LUNA供应量大增会导致LUNA价格的下降。而当LUNA价格持续下跌，市值接近或者小于UST时，大家就开始恐慌并大量卖掉UST。这时候，死亡螺旋就会开始，造成的后果就是LUNA和UST全部跌进深渊。
当形势足够严峻时，UST就会彻底失去美元稳定币属性（价格脱锚），这会引发一系列连锁反应，最终导致其绑定的LUNA代币大大贬值。

虽然无法证明是平台方的行为导致UST价格脱锚，但最终韩国法院依旧逮捕了加密货币生态系统Terraform Labs的创始人权道亨（Do Kwon）发出了逮捕令， 因为他创办的稳定币2022年5月损失了400亿美元市值（**
极大的经济动荡事件**），引发了一场全球加密货币崩溃风暴，令投资者损失惨重。

总结，LUNA崩盘（UST与美元脱钩）存在几个原因如下：

- 平台方推出的20%收益率Anchor存贷款项目，倘若平台方能真正使用人们存入的资金实现20%收益，也不至于无法支付人们的提款，但这么高的收益率显然是不可能实现的；
- 脚踏空气的LUNA，该代币的发行并没有实际等价资产的储备；

关于LUNA与UST崩盘的始末，参见[这篇文章][6]。

[0]: https://eips.ethereum.org/EIPS/eip-20

[1]: https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20/extensions

[2]: https://github.com/OpenZeppelin/openzeppelin-contracts

[3]: https://explorer.bitquery.io/ethereum/token/0xdac17f958d2ee523a2206206994597c13d831ec7/smart_contract

[4]: https://explorer.bitquery.io/tron/trc20token/TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t/smart_contract

[5]: https://explorer.bitquery.io/bsc/token/0x55d398326f99059ff775485246999027b3197955/smart_contract

[6]: http://finance.sina.com.cn/tech/csj/2022-05-20/doc-imcwipik0875218.shtml

### 参考

- [What Are ERC-20 Tokens on the Ethereum Network?](https://www.investopedia.com/news/what-erc20-and-what-does-it-mean-ethereum/)
- [都在用USDT，但是你知道USDT 是如何运作的吗？](https://zhuanlan.zhihu.com/p/524767611)