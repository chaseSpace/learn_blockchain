// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@合约修改器modifier
-   介绍
    用来修改函数的行为，作用类似装饰器。
    用法：
    -   先定义一个modifier 函数：modifier mustBeOwner() { ...; _; }
    -   修饰其他函数：withdraw() public mustBeOwner {}
    -   如此一来，执行withdraw函数时，会先执行mustBeOwner()，同时将withdraw的逻辑嵌入 mustBeOwner() 中 `_;` 的位置
    特点：
        -   可以给一个函数添加多个modifier
        -   modifier可以接收函数参数
*/


// 测试1
contract Example{
    address owner;

    constructor () {
        owner = msg.sender;
    }

    // 若没有参数可以省略括号
    modifier mustBeOwner virtual {
        require(owner == msg.sender, "no permission!");
        _; // 占位，用于存放被修饰函数的逻辑
    }

    // 测试函数
    function transfer() public mustBeOwner {

    }
}

// 测试2
// modifier可以被继承并重写
contract LearnModifier is Example{
    uint a;
    modifier mustBeOwner override {
        require(owner == msg.sender, "no permission!");
        a ++; // 顺序1
        _; // 占位，用于存放被修饰函数的逻辑
        a ++; // 顺序4
    }

    // 可以接收参数
    modifier limitNum(uint num) {
        require(num < 3, "num < 3 is must!");
        a ++;  // 顺序2
        _;
        a ++;  // 顺序3
    }

    // 可以设置多个modifier，接收函数参数作为modifier参数
    // 注意这个函数实际的执行顺序：mustBeOwner(limitNum(transfer2)))
    function transfer2(uint num) public mustBeOwner limitNum(num) {
        require(a == 2);
    }
}