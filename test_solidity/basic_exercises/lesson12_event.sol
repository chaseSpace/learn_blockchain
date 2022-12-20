// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@事件：event
-   介绍
    是在合约中定义和触发的内容。
    特点：
        -   只能在storage区声明，通常是大写开头
        -   订阅：如名字那样，事件可以被app通过web3.js提供的RPC接口订阅和监听，然后在前端进行对应响应。
            -   在合约内无法读取事件
        -   经济：一个事件比一个状态变量更节省gas，前者是2000gas，后者是20000gas。事件用来记录合约函数被调用时的log，如转账等。
        -   匿名：允许定义匿名事件
        -   可查询：在区块链浏览器上查询交易对应的事件内容：https://rinkeby.etherscan.io/tx/0x8cf87215b23055896d93004112bbd8ab754f081b4491cb48c37592ca8f8a36c7#eventlog
            -   indexed的字段将作为topic以便观察；topic 0是事件签名的keccak哈希，其他topic是indexed字段的keccak哈希，data字段是未索引的字段
            -   匿名事件不会记录事件名和参数名，因此也无法通过web3接口进行筛选查询/监听
            -   若indexed的字段是数组类型（包含bytes和string类型），则只会保存其keccak哈希到区块链上，即topic观察到的是哈希值
    使用场景：
        -   智能合约给用户的返回值
        -   异常触发
        -   更便宜的数据存储

*/

contract LearnEvent{
    // indexed 表示将该字段进行索引，以便在区块链浏览器上
    // 通过web3.js进行筛选后的监听：var event = myContract.Transfer({num: 100})
    event Transfer(address indexed from, address indexed to, uint num);
    event Transfer2(address indexed from, address indexed to, uint num) anonymous; // 匿名事件

    function transfer(address from, address to, uint num) public {
        emit Transfer(from ,to , num);
        emit Transfer2(from ,to , num);
    }
}