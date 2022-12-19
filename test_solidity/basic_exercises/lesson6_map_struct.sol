// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@mapping
-   介绍
    一个map结构，引用类型，在合约中通常用来存储用户余额或游戏级别，map的key类型限制不能是某些类型：mapping、数组、结构体，value类型不限制。
    map的数据位置只能是storage，并且只允许在状态变量区声明，无法函数中创建。
-   原理
    key并不存在map中，而是存储key的keccak256哈希值用于查找value；
    也没有key和value集合，以及length的概念。所以无法遍历map，只能自己实现一个iterableMap。


@struct
-   介绍
    -   结构体，见下方代码
*/

contract LearnMapping {
    // 1. 存储此合约中的用户以太币信息
    mapping(address => uint) balances;

    // 功能：存以太币到此合约地址
    function deposit() public payable{
        require(msg.value > 0, "need ether!");
        balances[msg.sender] += msg.value;  // 默认msg.value的单位是wei
    }

    // 查询用户的以太币信息
    function balance(address user) public view returns (uint){
        return balances[user];
    }

    // 2. 如果作为参数，则只能是internal函数，且任何时候map都只能使用storage存储。
    function testMap(mapping(address => uint) storage x) internal {
        // 无法动态创建map，只能在状态变量区声明
        // mapping(address => uint) storage m;

    }
}

contract LearnStruct{
    struct Base{
        string name;
        uint age;
    }
    struct MyType {
        bool b;
        uint i;
        Base base;
        // MyType t;  // 不能将自己作为成员
        mapping(uint => MyType) m; // 可以作为成员map的值类型
    }

    MyType mt; // 状态变量结构体的初始化方式

    mapping(uint => MyType) m;

    function testStruct() public {
        Base memory b = Base("", 1); // 函数中创建struct变量只能存在memory位置，按字段定义顺序填入
        Base memory b2 = Base({age:1, name:""}); // 或者按字段填入

        // 1. 一旦结构体包含了map，就不能动态创建
        // MyType memory mt = MyType(true, 2, b);
        // 2. 只能通过map的方式间接“创建”，本质上这并不是独立创建的，因为此变量还是作为状态变量m的value存在
        MyType storage mt2 = m[0];
        mt2.b = true;
        mt2.i = 2;
        mt2.base = b;
        // mt2.m[1] = mt; // 无法将包含map的类型mt变量进行分配，如此一来，相当于在结构体内定义的map是无法使用的。

        mt.b = false; // 函数内直接使用状态变量
        mt.base = b2;
    }
}