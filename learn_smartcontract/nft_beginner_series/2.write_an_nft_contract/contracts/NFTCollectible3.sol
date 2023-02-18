//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// 备注：此合约是 NFTCollectible2.sol 的优化版本，主要优化Counter的使用方式，解决第一次铸币时较高的gas费用
contract NFTCollectible is ERC721, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint public constant MAX_SUPPLY = 100;
    uint public constant PRICE = 0.01 ether;
    uint public constant MAX_PER_MINT = 5;

    string public baseTokenURI;

    constructor(string memory baseURI) ERC721("NFT Collectible", "NFTC") {
        setBaseURI(baseURI);
        _tokenIds.increment();
        // 初始化为1（避免在第一次铸币初始化，因为初始化会调用sstore指令，会一下消耗较多gas，而修改不会）
    }

    function reserveNFTs() public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(10) < MAX_SUPPLY, "Not enough NFTs left to reserve");

        for (uint i = 0; i < 10; i++) {
            _mintSingleNFT();
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    // 旧的铸币函数
    //    function mintNFTs(uint _count) public payable {
    //        uint totalMinted = _tokenIds.current();
    //
    //        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs left!");
    //        require(_count > 0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs.");
    //        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");
    //
    //        for (uint i = 0; i < _count; i++) {
    //            _mintSingleNFT();
    //        }
    //    }

    // 新的批量铸币函数
    function mintNFTs(uint _count) public payable {
        uint totalMinted = _tokenIds.current() - 1;

        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs left!");
        require(_count > 0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs.");
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }
    // 新的铸币函数
    function _mintSingleNFT() private {
        _safeMint(msg.sender, _tokenIds.current()); // 直接使用当前数值作为新ID
        _tokenIds.increment();
    }


    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success,) = (msg.sender).call{value : balance}("");
        require(success, "Transfer failed.");
    }
}