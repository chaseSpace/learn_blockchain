// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
@ERC721
# 介绍
- 不同于ERC20和ERC777表示的是同质化代币，ERC721是代表一种非同质化代币，如现实中的一幅画、一个宠物等。
    - ERC721中使用<uint256 tokenID>作为一个非同质化代币在合约内的唯一标识
*/

// 部署时注释这一段import，使用下面github的import
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC721/ERC721.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

// 对于 ERC721 和 ERC721URIStorage的模板代码都比较简单，所以这里特别关注 ERC721Enumerable.sol 的模板代码实现

// 这里复制了 contracts/token/ERC721/extensions/IERC721Enumerable.sol 的代码，下面进行注释说明
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // map <address => map(index => tokenID)>
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // map <tokenID => index inside of _ownedTokens)
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // 一个数组存放合约内全部代币
    uint256[] private _allTokens;

    // map <tokenID => index inside of _allTokens>
    mapping(uint256 => uint256) private _allTokensIndex;

    // ERC165支持，注意这里重载了 IERC165, ERC721
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    // 通过owner地址和index查询tokenID，index无效会报错
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    // 查询合约内全部代币的totalSupply
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    // 通过index在全局数组查询tokenID，index无效会报错
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    // 重载 ERC721合约模板的_beforeTokenTransfer方法
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        // 这里仍然会调用继承合约的该方法
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // 仅在铸币期间支持批量转账
            revert("ERC721Enumerable: consecutive transfers not supported");
        }

        uint256 tokenId = firstTokenId;

        if (from == address(0)) { // 铸币操作
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) { // 正常转账或销毁
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) { // 销毁操作
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) { // 铸币或正常转账
            _addTokenToOwnerEnumeration(to, tokenId);
        }

        // 但不可能 from 和 to 都是0地址, 上层调用进行控制
    }

    // to地址接收代币，更新两个map
    // 注意：这里的index 来自 ERC721.balance(map) 存储的代币数量，但这里始终没有用数组存放NFT
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    // 总map添加代币，由铸币操作调用
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    // 内部方法：从 _ownedTokens 和 _ownedTokensIndex 中移除一个token
    // 疑惑：不管是 ERC721模板合约 还是 当前合约 都没有使用数组存放NFT，下面的做法却仍然采用swap and pop的方式来移除token，无疑增加了一部分逻辑
    /* 笔者的实现如下
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][tokenIndex];
    */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    // 内部方法：从 _allTokens 和 _allTokensIndex 中移除一个代币
    // 说明：这里因为 _allTokens 是数组结构，所以使用 swap and pop 的方式没有疑问。
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
