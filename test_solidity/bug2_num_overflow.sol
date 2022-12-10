// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

/*
@整型溢出攻击
- 介绍
    -   与其他通用编程语言一样，solidity的基本类型，如uint8，uint256等类型在算数运算时也会发生溢出问题；
    -   溢出有两种情况，上溢出（overflow） 和 下溢出（underflow）；
    -   注意：除法不会导致溢出，任何数除以0会报错；

- 关于 overflow 和 underflow 的具体说明
    -   以uint8为例，其表示范围是 [0,255] ，那么 uint8(255) + uint8(1) = 0 就表示overflow
    -   同理，uint8(0) - uint8(1) = 255 ，这是underflow
    -   方便理解：把数字的溢出现象看做是一个汽车里程表盘一样，超过最大值就会回到0的位置重新计数，数值以周期性的方式在一个固定范围内变化。

*/


// 1. 给出一个存在 overflow 漏洞的合约
// - 这个合约的功能是将存入合约的用户以太币锁定一段时间，之后才能取出
contract TimeLock {
    mapping(address => uint) public balance;
    mapping(address => uint) public lockTime;

    event printLockTime(uint);

    function deposit(address) public payable {
        balance[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    // 存在漏洞的方法：假设 lockTime[msg.sender] = 1555555555，传参 _seconds = 2^256-1000000000，那么lockTime[msg.sender] = 555555555
    // 这个值必然小于目前的任何时间戳数字，将导致下面的提取函数中的锁定判断一定验证通过！
    function increaseLockTime(uint _seconds) public {
        lockTime[msg.sender] += _seconds;
        emit printLockTime(lockTime[msg.sender]);
    }

    function withdrawAll(uint _amount) public payable {
        // 如果把这行改为：require(balance[msg.sender] - _amount >= 0, "balance insufficient"); 就变成一个存在underflow漏洞的例子
        require(balance[msg.sender] >= _amount, "balance insufficient");

        require(lockTime[msg.sender] < block.timestamp, "still in lock");
        balance[msg.sender] -= _amount;
        msg.sender.transfer(_amount);
    }
}
