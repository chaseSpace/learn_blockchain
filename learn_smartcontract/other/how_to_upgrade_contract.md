# 如何使用OpenZeppelin编写可升级合约

- [1. 为什么需要可升级合约](#1-为什么需要可升级合约)
- [2. 重新部署合约的缺点](#2-重新部署合约的缺点)
- [3. 使用OZ的插件编写可升级合约](#3-使用OZ的插件编写可升级合约)
  - [3.1 初始化环境](#31-初始化环境)
  - [3.2 编写业务合约](#32-编写业务合约)
  - [3.3 部署可升级合约](#33-部署可升级合约)
  - [3.4 使用控制台进行交互](#34-使用控制台进行交互)
  - [3.5 为合约添加功能](#35-为合约添加功能)
  - [3.6 升级合约](#36-升级合约)
  - [3.7 再次使用控制台进行验证](#37-再次使用控制台进行验证)
- [4. 升级原理](#4-升级原理)
- [5. 可升级合约的局限](#5-可升级合约的局限)
  - [5.1 不能定义构造函数](#51-不能定义构造函数)
  - [5.2 不能更改状态变量布局](#52-不能更改状态变量布局)
- [6. 测试](#6-测试)

### 说明
本文档主要按照官方文档 [Upgrading smart contracts][3] 的内容进行翻译整理，但文中也根据笔者个人实践经验给出相关建议，希望对你有所帮助。

## 1. 为什么需要可升级合约

目的很简单，在保留原合约地址的同时

- 修复bug
- 增加特性
- 在与用户协商一致的前提下修改合约内容

这一操作与使用传统合同无异。在这之前，我们都听说合约是一旦部署后就无法更改的，确实没错，但可以通过一种**取巧的部署模式**来实现合约迭代升级。 当然，这需要利用到一些Solidity底层的知识，下面一起来学习一下。

## 2. 重新部署合约的缺点

在这之前，我们想要升级合约只能通过重新部署的方式，但缺点很明显：

- 需要再次支付部署费用
- 完全同步之前合约的数据也需要支付gas
- 更新所有与旧合约交互的合约，以使用新合约地址
- 通知并说服所有用户改用新合约，由于用户迁移是一个缓慢过程，新合约需要同时接受旧合约的数据

如上，重新部署的方案费时费力费钱。

OpenZeppelin提供了一些升级插件，帮助我们实现合约的升级，同时保留旧合约的状态、余额以及地址。

## 3. 使用OZ的插件编写可升级合约

下面我们会用到 [OpenZeppelin Upgrades Plugins][0] 中的`deployProxy`插件函数来部署合约，该函数在部署过程中会部署三个合约（创建三笔交易）：

- 部署业务合约
- 部署`ProxyAdmin`合约
- 部署`Proxy`合约，并运行任何`initializer`函数

其中`ProxyAdmin`是`Proxy`的管理合约。部署合约后，会使用到`upgradeProxy`插件函数来升级合约，下面开始操作。

### 3.1 初始化环境

先说明，本文演示的代码均在 [./other/upgrade_contract](./upgrade_contract) 目录。此外，本文以Hardhat作为框架进行演示，如使用Truffle，请在阅读完本文后再去参考参考中第一个链接。

```shell
lei@WilldeMacBook-Pro learn_smartcontract % cd other/upgrade_contract
# 0. 安装hardhat
lei@WilldeMacBook-Pro upgrade_contract % npm install --save-dev hardhat
# 1. 选择[Create an empty hardhat.config.js]，初始化Hardhat配置 
lei@WilldeMacBook-Pro upgrade_contract % npx hardhat     
# 2. 安装OZ插件
lei@WilldeMacBook-Pro upgrade_contract % npm install --save-dev @openzeppelin/hardhat-upgrades
# 3. 安装ethers插件用于与区块链交互
lei@WilldeMacBook-Pro upgrade_contract % npm install --save-dev @nomiclabs/hardhat-ethers
```

### 3.2 编写业务合约

如下，这是一个简单的`Box`合约，主要包含一个`store`函数、`retrieve`函数实现对状态变量`_value`的读写。

```solidity
// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Box {
    uint256 private _value;

    // Emitted when the stored value changes
    event ValueChanged(uint256 value);

    // Stores a new value in the contract
    function store(uint256 value) public {
        _value = value;
        emit ValueChanged(value);
    }

    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return _value;
    }
}
```

合约文件位于 `contracts/Box.sol` 。

### 3.3 部署可升级合约

首先在hardhat配置文件引入刚才安装的三方库：

```javascript
/** @type import('hardhat/config').HardhatUserConfig */
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');

module.exports = {
    solidity: "0.8.17",
};
```

然后编写部署脚本：

```javascript
// scripts/deploy_upgradeable_box.js
const {ethers, upgrades} = require("hardhat");

async function main() {
    const Box = await ethers.getContractFactory("Box");
    console.log("Deploying Box...");
    const box = await upgrades.deployProxy(Box, [42], {initializer: 'store'});
    await box.deployed();
    console.log("Box deployed to:", box.address);
}

main();
```

执行部署命令：

```shell
lei@WilldeMacBook-Pro upgrade_contract % npx hardhat run scripts/deploy_upgradeable_box.js    
Compiled 1 Solidity file successfully
Deploying Box...
Box deployed to: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
```

注意，这条命令本质上只是证明我们的合约以及部署脚本没有问题，实际上还没有部署。下面，启动hardhat local节点作为一个以太坊模拟节点，进行测试。

打开另外一个cmd窗口，执行以下命令：

```shell
lei@WilldeMacBook-Pro upgrade_contract % npx hardhat node


Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/
Accounts
========
...
```

命令会在你本机启动一个hardhat节点，此外还会创建20个包含10000个ETH余额的账号供测试。现在执行部署到本地节点的命令：

```shell
lei@WilldeMacBook-Pro upgrade_contract % npx hardhat run --network localhost scripts/deploy_upgradeable_box.js
Deploying Box...
Box deployed to: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
```

部署成功。

### 3.4 使用控制台进行交互

回到第一个创建，执行命令进入hardhat控制台，并在控制台中与已部署的合约进行交互：

```shell
lei@WilldeMacBook-Pro upgrade_contract % npx hardhat console --network localhost
Welcome to Node.js v18.10.0.
Type ".help" for more information.
> const Box = await ethers.getContractFactory("Box")
undefined # 忽略
> const box = await Box.attach("0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0")
undefined # 忽略
> (await box.retrieve()).toString()  # 访问在部署时写入box中的_value值
'42'
```

### 3.5 为合约添加功能

现在，假设要为Box增加一个函数，如下：

```solidity
// contracts/BoxV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract BoxV2 {
    // ... code from Box.sol

    // Increments the stored _value by 1
    function increment() public {
        _value = _value + 1;
        emit ValueChanged(_value);
    }
}
```

这个`increment`函数的功能很简单，不做多余解释。另外创建一个`BoxV2.sol`文件来存放新合约，完整代码在`contracts/BoxV2.sol`中。

### 3.6 升级合约

现在要将BoxV2.sol的代码直接更新到刚才Box.sol部署的地址`0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`中去，要使用的是`upgradeProxy`函数。 
这个函数会执行以下2个操作（创建2个交易）：

- 部署新的业务合约（BoxV2）
- 调用之前部署的`ProxyAdmin`合约更新`Proxy`合约来使用新的业务合约地址

这个过程中，实际上我们会抛弃掉已部署的旧合约Box逻辑，注意其中的状态信息仍然是保留在`Proxy`合约中的。

现在，创建新的升级脚本：

```javascript
// scripts/upgrade_box.js
const {ethers, upgrades} = require("hardhat");

async function main() {
    const BoxV2 = await ethers.getContractFactory("BoxV2");
    console.log("Upgrading Box...");
    const box = await upgrades.upgradeProxy("0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0", BoxV2);
    console.log("Box upgraded");
}

main();
```

执行升级脚本：

```shell
lei@WilldeMacBook-Pro upgrade_contract % npx hardhat run --network localhost scripts/upgrade_box.js
Compiled 1 Solidity file successfully
Upgrading Box...
Box upgraded
```

OK，升级完成，现在再次使用控制台来验证升级后的合约逻辑是否正确。

### 3.7 再次使用控制台进行验证

```shell
lei@WilldeMacBook-Pro upgrade_contract % npx hardhat console --network localhost                   
Welcome to Node.js v18.10.0.
Type ".help" for more information.
> const BoxV2 = await ethers.getContractFactory("BoxV2")
undefined
> const box = await BoxV2.attach("0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0")
undefined
> await box.increment()
{显示本次函数调用的交易明细}
> (await box.retrieve()).toString()
'43' # 验证成功
```

这就是OZ的升级插件的使用过程，旧合约Box的状态变量以及部署地址都成功保存下来了。无论是在本地节点、测试网或主网都是一样的操作步骤。

## 4. 升级原理

前面说过，插件会在部署过程中会部署三个合约（创建三笔交易）：

- 部署业务合约（我们写的）
- 部署`ProxyAdmin`合约（管理下面的Proxy合约）
- 部署`Proxy`合约，此合约作为我们与业务合约交互的**中间人**（即我们实际交互的是Proxy合约，由Proxy合约去转发请求）

`Proxy`合约是通过DelegateCall的方式转发请求的，DelegateCall是Solidity中的一个low-level调用，也称委托调用，其用法大致如下：

- 假设有A、B两个合约，它们拥有完全一致的状态变量定义。然后B有个函数`function increment()`为状态变量value加一；
- 现在在A中DelegateCall调用B的`increment()`
- 效果：B合约中的value值不变，A合约中的状态变量value加一。

这就是一个委托调用的过程。将A的状态数据（包括状态变量、代币余额）委托给B管理。在这个过程中，A是委托者，其地址不变，因为我们的状态数据都在A中， 而B是一个接受委托的合约，可以随时更换。
当需要更改某个函数的逻辑时，只需要重新部署受委托合约即可，需要注意的是受委托合约的状态变量定义（类型、顺序）必须和主合约一致。
> 这里的委托者就是上面的`Proxy`合约。

通过DelegateCall可以实现合约的状态与逻辑代码的解耦，当需要升级（更改逻辑代码）时，执行以下步骤：

- 部署新的逻辑合约
- 向委托合约发送一个交易，将其逻辑地址替换为新的逻辑合约地址

> 我们可以让多个Proxy合约使用同一个逻辑合约，所以如果我们计划部署同一个合约的多个副本，就可以使用这个模式来节省gas。

智能合约的用户总是与Proxy合约进行交互，Proxy合约永远不会改变其地址。这允许我们可以推出升级或修复错误，而无需要求用户作出任何改变， 他们只是一如既往地与相同的地址进行交互。

## 5. 可升级合约的局限

### 5.1 不能定义构造函数
由于一些原因，可升级合约不能有构造函数constructor。为了帮助你初始化代码，OpenZeppelin提供了 Initializable 基础合约，通过在方法上添加`initializer`标签，确保只被初始化一次。

下面通过initializer来写一个新版本的Box合约，设置一个admin为唯一一个可以修改`_value`的caller。
>由于之前安装的@openzeppelin/hardhat-upgrade并不包含Initializable 基础合约，所以需要另外安装这个插件：  
>`npm install --save-dev @openzeppelin/contracts-upgradeable`
```solidity
// contracts/AdminBox.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AdminBox is Initializable {
    uint256 private _value;
    address private _admin;

    // Emitted when the stored value changes
    event ValueChanged(uint256 value);

    function initialize(address admin) public initializer {
        _admin = admin;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    // Stores a new value in the contract
    function store(uint256 value) public {
        require(msg.sender == _admin, "AdminBox: not admin");
        _value = value;
        emit ValueChanged(value);
    }

    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return _value;
    }
}
```
部署合约时，我们需要指定initializer对应的函数名（如果函数名是`initialize`则可以不用指定），并提供一个管理员地址。
```javascript
// scripts/deploy_upgradeable_adminbox.js
const {ethers, upgrades} = require("hardhat");

async function main() {
    // 得到部署账号
    const [owner] = await ethers.getSigners();

    const AdminBox = await ethers.getContractFactory("AdminBox");
    console.log("Deploying AdminBox...");

    // 将部署账号作为初始化参数传入（因为函数名是initialize，所以opts参数可以省略）
    const adminBox = await upgrades.deployProxy(AdminBox, [owner.address], {initializer: 'initialize'});
    await adminBox.deployed();
    console.log("AdminBox deployed to:", adminBox.address);
    
    // 测试函数调用
    tx = await adminBox.store(1);
    await tx.wait();
    console.log("adminBox.store(1) is OK!")
}

main();
```
注意，为了方便演示，这个部署脚本中包含了测试调用的逻辑，实际上这部分逻辑应该放在test代码中。

### 5.2 不能更改状态变量布局
因为状态变量的布局在第一次部署时就已经确定在`Proxy`合约中了，而后者是无法改变的。比如：
- 不能修改已定义状态变量的类型、顺序
- 不能修改已定义的状态变量

但可以在最后一个状态变量后新增变量。对于合约中的函数，我们可以随意增删改。

## 6. 测试
编写可升级合约的测试用例，与普通的测试也有所不同。也需要用到OZ提供的`deployProxy`和`upgradeProxy`函数，下面是笔者为上文提到的几个合约编写的示例：
<details>
<summary>展开查看代码</summary>
<pre>

```javascript
// test/all.js
const {upgrades, ethers} = require("hardhat");
const {expect} = require('chai')

// Box的测试用例
describe("Box", function () {
    it("works", async function () {
        const Box = await ethers.getContractFactory("Box");
        const box = await upgrades.deployProxy(Box);
        await box.deployed();

        await expect(box.store(1)).to.emit(box, "ValueChanged").withArgs(1);
        expect(await box.retrieve()).to.equal(1);
    })
})

// BoxV2的测试用例
describe("BoxV2", function () {
    it("works", async function () {
        const Box = await ethers.getContractFactory("Box");
        const BoxV2 = await ethers.getContractFactory("BoxV2");

        const instance = await upgrades.deployProxy(Box);
        await instance.deployed();
        await expect(instance.store(1)).to.emit(instance, "ValueChanged").withArgs(1);
        expect(await instance.retrieve()).to.equal(1);

        // 使用旧地址升级
        const upgraded = await upgrades.upgradeProxy(instance.address, BoxV2);
        await upgraded.deployed();

        await upgraded.increment();
        expect(await upgraded.retrieve()).to.equal(2);
    })
})

// AdminBox的测试用例
describe("AdminBox", function () {
    it("works", async function () {
        const [owner, address1] = await ethers.getSigners();

        const AdminBox = await ethers.getContractFactory("AdminBox");
        const instance = await upgrades.deployProxy(AdminBox, [owner.address]);
        await instance.deployed();

        // 切换账户测试
        await expect(instance.connect(address1).store(1)).to.revertedWith("AdminBox: not admin");
        await instance.store(1);
        expect(await instance.retrieve()).to.equal(1);
    })
})
```
</pre>
</details>

>需要安装包含测试库的工具包：npm install --save-dev @nomicfoundation/hardhat-toolbox

更多关于断言库 Chai 的使用，请查阅官网 [Hardhat Chai Matchers][1] 。

本文提到的合约代码位于 [upgrade_contract][2] 。

[0]: https://docs.openzeppelin.com/upgrades-plugins/1.x/
[1]: https://hardhat.org/hardhat-chai-matchers/docs/overview
[2]: https://github.com/chaseSpace/learn_smartcontract/tree/main/other/upgrade_contract
[3]: https://docs.openzeppelin.com/learn/upgrading-smart-contracts

### 参考

- [OpenZeppelin Official: Upgrading smart contracts](https://docs.openzeppelin.com/learn/upgrading-smart-contracts)
- [OpenZeppelin Official: Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/hardhat-upgrades)