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

// ERC1820的interface定义文件
//import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
//// ERC1820的具体实现，开发者可以直接使用
//import "@openzeppelin/contracts/utils/introspection/ERC1820implementer.sol";
