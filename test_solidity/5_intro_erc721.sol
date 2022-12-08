// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
@ERC721
# 介绍
- 不同于ERC20和ERC777表示的是同质化代币，ERC721是代表一种非同质化代币，如现实中的一幅画、一个宠物等。
    - ERC721中使用<uint256 tokenID>作为一个非同质化代币在合约内的唯一标识，所以使用合约地址+tokenID可以在世界范围内唯一定义一个NFT
    - 标准中没有规定tokenID的实现方式，
*/

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

// 1. 介绍IERC721接口
interface IERC721 is IERC165 {
    // 事件：NFT的所有权发生改变时触发（不论什么方式）
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // 事件：所有者把它的某个NFT授权给其他人时触发
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // 事件：所有者启用/取消某个操作者对它所有资产的授权（是的，允许指定一个操作员全权操作自己的所有资产）
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 功能：查询所有者剩余的NFT数量
    function balanceOf(address owner) external view returns (uint256 balance);

    // 功能：查询一个NFT的所有者，要求tokenID必须有效
    function ownerOf(uint256 tokenId) external view returns (address owner);

    // 功能：安全转账NFT。要求from和to地址是有效地址，且tokenID也是有效的。另外，caller若不是from地址，则必须是其授权的操作员（或这个tokenID的授权使用人）
    // - 若to地址是一个合约地址，则要求改地址必须实现 IERC721Receiver-onERC721Received 接口（相当于一个回调通知），该接口会在此功能中被调用
    // - 最后触发 Transfer 事件
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    // 功能同上，但不带data参数
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    // 功能基本同 safeTransferFrom，但不要求to地址实现接口，即由caller确定to地址是一个有效地址，若不是则可能导致NFT永久丢失，所以推荐使用 safeTransferFrom
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    // 功能：所有者转移一个NFT的授权给to地址，caller也可以是NFT操作员，tokenID必须有效。另外，若to地址为0地址，则该NFT的授权被取消。
    // - 触发 Approval 事件
    function approve(address to, uint256 tokenId) external;

    // 功能：批准或取消caller对一个operator的操作员授权，若批准，则operator可以代替caller调用 transferFrom 和 safeTransferFrom
    // - 触发 ApprovalForAll 事件
    function setApprovalForAll(address operator, bool _approved) external;

    // 功能：查询一个NFT的操作员（若有），要求tokenID必须有效
    function getApproved(uint256 tokenId) external view returns (address operator);

    // 功能：查询一个operator是否是owner的全部资产授权地址
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// 2. 若收款人是一个合约地址，要接受 safeTransferFrom 的调用，则必须实现以下接口，否则转账回退
interface IERC721Receiver {
    // 此接口必须返回 IERC721Receiver.onERC721Received.selector，它其实是
    // bytes4(keccak256("onERC721Received(address, address, uint256, bytes)"))，即一个固定4字节值 0x150b7a02
    // - 此接口会被 IERC721.safeTransferFrom 调用，若未被收款合约地址实现或未正确返回上述值，则转账回退！
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// 2.1 示例实现
contract ERC721ReceiverImpl {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        // 有如下几种方式实现，但直接返回值显然更节省gas
        // return 0x150b7a02;
        // return IERC721Receiver.onERC721Received.selector;
        return this.onERC721Received.selector;
    }
}

// 3. 这个接口是用来描述代币元信息的用途，可选实现。
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    // NFT的统一资源标识符，若tokenID无效，则报错
    // - URI 可以指向一个符合ERC721 元数据JSON格式的 JSON文件，具体查看 https://eips.ethereum.org/EIPS/eip-721
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// 4. 虽然ERC721标准中没有规定tokenID的实现规则，但在ERC721/extensions/中给出了 token的枚举接口定义，推荐实现该接口，方便用户查询NFT的完整列表
interface IERC721Enumerable is IERC721 {
    // 查询合约内总的NFT发行量
    function totalSupply() external view returns (uint256);

    // 查询index对应owner的NFT列表中的token，配合 IERC721.balanceOf() 可以遍历owner的所有token，所以index仅在owner的NFT列表有意义
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    // 查询index索引合约发行的所有NFT，配合 totalSupply() 可以遍历合约发行的全部NFT，此时index在合约全局有意义
    function tokenByIndex(uint256 index) external view returns (uint256);
}
