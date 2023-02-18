# 通过 USDT 学习 ERC-20

## 说明

本文档中提到的合约示例都是参照知名ERC20项目（如USDT/DAI/UNI/CRV等）编写而成的。

## 1. ERC-20介绍

- 一项以太坊区块链之上的同质化代币标准Ethereum Request for Comment 20 (ERC-20)，基于智能合约实现;
- 就像传统货币一样，它可以和自己以及NFT（非同质化代币）之间互换（RMB可以互换以及购买物品）；
- 自从推出以来，以太坊区块链上已经有非常多的ERC-20代币被发行，比如上面的USDT/DAI/UNI/CRV等；
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

## 2. 通过USDT学习ERC-20

### 2.1 

[0]: https://eips.ethereum.org/EIPS/eip-20

[1]: https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20/extensions

[2]: https://github.com/OpenZeppelin/openzeppelin-contracts

[3]: https://explorer.bitquery.io/ethereum/token/0xdac17f958d2ee523a2206206994597c13d831ec7/smart_contract

[4]: https://explorer.bitquery.io/tron/trc20token/TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t/smart_contract

[5]: https://explorer.bitquery.io/bsc/token/0x55d398326f99059ff775485246999027b3197955/smart_contract

### 参考

- [What Are ERC-20 Tokens on the Ethereum Network?](https://www.investopedia.com/news/what-erc20-and-what-does-it-mean-ethereum/)