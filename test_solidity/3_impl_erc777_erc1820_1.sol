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
    -   send()的通知是通过ERC1820接口注册表合约实现的，下面也会介绍ERC1820
- 所以主要是增加hook等功能使智能合约在事件发生时能够作出反应或执行特定的操作，从而给予代币持有者更多的控制权。这样做的好处是可以避免代币被发送到错误的目的地址从而丢失代币的情况
- ERC777标准向后兼容ERC20，这允许与这些代币无缝交互，还增加了一些改进，所以建议开发新代币时使用ERC777

@ERC1820接口注册表
## 背景
- 之前的ERC165可以声明合约实现了哪些接口，却没法为普通账户地址声明实现了哪些接口。ERC1820标准通过一个区块链平台全局的注册表合约记录了任何地址声明的接口，
    类似于windows系统注册表，注册表中包含了所实现接口的地址、注册的接口、接口实现的合约地址（可以和第一个地址一样）

## ERC1820介绍
- 是一个全局的合约，在以太坊主网、测试网、甚至是ETC链上都有一个固定一致的合约地址：0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24
    可以在这个合约地址上查询实现了哪些接口，所以它相当于是一个去中心化的中央注册表，合约A可以在其之上注册某些地址对应的接口，合约B可以去查询自己是否实现了合约A注册的接口信息
    -   ERC1820通过一种巧妙的方式（称为无密钥部署方式）将合约部署到一个固定地址的，具体自行查询
    -   ERC1820主要提供两个函数功能
        -   setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer)
            用来设置地址（_addr）的接口（_interfaceHash 接口名称的 keccak256 ）由哪个合约实现（_implementer），所以是由接口注册者调用
        -   getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address)
            这个函数用来查询地址（_addr）的接口由哪个合约实现，由接口查询者调用

- 需要注意的是ERC1820是一个已经实现并部署的合约
- ERC1820引入了管理员角色，由管理员设置哪个合约在哪个地址实现了哪些接口
- ERC1820要求实现接口的合约，必须实现函数canImplementInterfaceForAddress，来声明其实现的接口，并且在用户查询其实现的接口时，必须返回常量ERC1820_ACCEPT_MAGIC
- ERC1820兼容ERC165，so可以在ERC1820上查询ERC165接口
*/

// ERC1820的interface定义文件
//import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
//// ERC1820的具体实现，开发者可以直接使用
//import "@openzeppelin/contracts/utils/introspection/ERC1820implementer.sol";

// 换为github地址，以便在浏览器remix中运行时遇到openzeppelin版本问题
// ERC1820的interface定义文件
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/utils/introspection/IERC1820Registry.sol";
// ERC1820的具体实现，开发者可以直接使用
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/utils/introspection/ERC1820Implementer.sol";


// 1. 演示ERC1820的使用
// - `TestERC1820Interface` 是一个接口注册者，构造器中调用1820去中心化注册表 注册了自己的someFunction函数
contract TestERC1820Interface {
    IERC1820Registry internal _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 constant public SOMEFUNC_INTERFACE_HASH = keccak256("SOMEFUNC_INTERFACE_HASH");

    constructor() {
        _erc1820.setInterfaceImplementer(address(this), SOMEFUNC_INTERFACE_HASH, address(this));
    }
    function someFunction() public {}
}

// 直接使用 @openzeppelin/contracts/utils/introspection/ERC1820implementer.sol 提供的模板代码进行改写
contract TestERC1820Implementer is IERC1820Implementer {
    IERC1820Registry internal _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 constant public SOMEFUNC_INTERFACE_HASH = keccak256("SOMEFUNC_INTERFACE_HASH");

    bytes32 private constant _ERC1820_ACCEPT_MAGIC = keccak256("ERC1820_ACCEPT_MAGIC");
    mapping(bytes32 => mapping(address => bool)) private _supportedInterfaces;

    address implementer;

    // from参数是代币转出者的地址
    function test_transfer(address from, uint256 amount){
        implementer = _erc1820.getInterfaceImplementer(from, SOMEFUNC_INTERFACE_HASH);
        if (implementer == address(0)) {
            // 转出者的代币合约没有实现 `SOMEFUNC_INTERFACE_HASH` 这个函数，可以进行相应处理，如转账失败
            return;
        }
        // 如果实现了目标函数，可以进行transfer逻辑...
    }

    function canImplementInterfaceForAddress(bytes32 interfaceHash, address account) public view returns (bytes32)   {
        return _supportedInterfaces[interfaceHash][account] ? _ERC1820_ACCEPT_MAGIC : bytes32(0x00);
    }

    function _registerInterfaceForAddress(bytes32 interfaceHash, address account) internal virtual {
        _supportedInterfaces[interfaceHash][account] = true;
    }
}