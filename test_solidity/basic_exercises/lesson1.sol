// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@本课主题
- 合约基本编写格式
- 变量类型（主要介绍address类型）
- 变量命名
*/


// 1. 合约基本编写格式
// - 驼峰命名风格
// - contract关键字声明合约对象，并在部署后被执行、调用，没有其他【启动】方式
// - 内部可自定义一些函数，constructor是特殊的构造器函数，无需function修饰，仅在部署时执行一次
// - 修饰符:每个函数可以添加一个或多个修饰符，如 payable表示调用此函数时可以往合约地址发送以太币，否则不能发送
//      -   public 表示可以被外部和内部调用，类似的还有external表示只能被外部调用，这两个还可修饰状态变量；
//      -   还有internal、private,二者差别是private表示仅能在当前合约中读写该函数，继承的合约也无法方法，即比internal更强调私有
contract WhatUsageIs {
    constructor(uint a) payable {}

    // solidity是静态类型语言，需要标注类型；没有undefine, null值
    function some_function(uint x) public {}
}


// 2. 变量类型
// -    状态变量：永久存储于账本
// -    局部变量：函数中的定义
// -    全局变量：由EVM提供，只能读取。可用的全局变量：https://docs.soliditylang.org/en/v0.8.17/units-and-global-variables.html#block-and-transaction-properties
contract LearnVarTypes{
    // 状态变量
    // view又是一类函数修饰符，后续介绍
    uint stateVarUint;
    function xxx() public view {
        // 局部变量，在函数执行结束后销毁
        uint x = 1;
        require(x==1); // 断言

        // 全局变量，读取了block.coinbase：当前区块矿工地址
        require(block.coinbase != address(0));
    }
}


// 3. 数据类型(此合约主要介绍address类型)
// -    整体分为 值类型和引用类型
// -    值类型：传参是总是复制值本身。包括 bool, all int, fixed-size point number, fixed-size byte arrays, rational and int常量, string liternals, hex常量, enums, function types, address, address常量
// -    引用类型：TODO
contract LearnDataTypes_address{
    // 整型：int8到int256, uint8到uint256，int和uint默认256bit
    // -    比较运算符，常见那样；位操作： &与 |或 ^异或 ~取反；算数操作：常见那样；位移：常见那样
    // -    注意几点：1.整数除法总是截断的 2.整数除0报错 3.位移结果的正负与操作符左边的数一致 4.不能进行负位移，即操作符右边不能是负数，否则报错 5.溢出时非截断处理
    uint stateVarUint;

    // address类型：保存一个20byte的以太坊地址
    // address payable类型：没太大差别，可与address互转，表示可支付地址。包含成员属性和函数，如属性balance(uint256), 函数transfer(uint256)
    address public _owner = 0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24;

    // 与address互转, v0.6引入，更早版本：address(uint160(addr))
    // -    实践中，当被转换的是一个合约地址时，则要求合约实现函数receive() 或 fallback()payable，否则报错；不过，还可以使用 payable(address(addr))的方式强行转换
    address payable ap = payable(_owner);

    bytes20 b20 = bytes20(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    address public _addr = address(b20); // 可与bytes20互转
    // -    address运算：<= < == != >= >，常用的是== !=
    // -    address payable拥有自己的成员属性和函数，如属性balance(uint256), 函数transfer(uint256)
    // -    可以在函数中获取合约地址: address(this)
    uint256 _balance = _addr.balance;


    // string stateVarStr = "";
    // bytes4 stateVarBytes4 = 0x00112233;

    // uint[] stateVarArray = [1,2,3];
    // mapping( address => uint ) balance;

    // 这个区域只能声明变量，不能加其他代码

    constructor() {
        // type(T).max/min 获取整型的边界值
        require(type(uint).max == 2**256-1);
        require(type(uint).min == 0);

        // address payable的transfer()  send()
        // send()是更低层次的调用，必须验证返回值，推荐transfer()
        // 两个函数的gas消耗固定2300，但由于会自动调用收款合约地址的receive或fallback函数，就可能因为receive或fallback函数中定义了复杂的逻辑把2300gas耗光了，从而导致转账失败，解决版本是使用address.call，在下面介绍
        ap = payable(msg.sender);
        ap.transfer(0); // 构造器执行结束前，当前合约尚未完成收款操作，没有余额可操作。转账参数单位：wei，失败时报错！
        bool ok = ap.send(0); // 与transfer用法一致，不过返回一个bool值表示成功失败（不报错）。即 addr.transfer(x) 等价于 require(addr.send(x))

    }


    // -    接收以太币：若是合约地址，想要接收以太币，则必须定义receive()external payable  或 fallback() external payable，没有按要求定义则无法收款失败（对方转账调用也失败）。
    // -    其中receive()是在收款时执行，若没有定义，则调用fallback()，这个函数的意义是在外部调用该合约时，找不到匹配的函数时才调用它。
    receive() external payable{}
    fallback() external payable{}
}

// 4. 使用底层函数 address.call() 控制转账或函数调用时发送的gas，可避免gas不够导致的转账失败
contract LearnAddressCall{
    function testTransfer(address payable to) public payable {
        // to.transfer(1 ether);

        // 使用call替代transfer()，注意以下几点：
        // -    value表示发送的以太币数量，gas参数设定本次调用最多可消耗的gas（不像transfer固定2300gas），旧版本调用方式：to.call.gas(5000).value(1 ether)("")，已废弃；
        // -    第二个括号的空串是必须的，表示一个字符串参数。
        // -    call会返回两个值，bool, bytes; 通常只读取bool值，忽略bytes，bool表示调用结果。忽略第二个返回值的简写方式: (bool succ, ) = ...
        (bool succ, bytes memory data) = to.call{value:1 wei, gas: 5000}("");
        require(succ, "to.call() failed!");

        // address.call并不是经常用于转账场景，而是用于一种底层的与其他合约交互的方式
        // -    它主要用途是通过ABI协议去指定调用目标合约地址的任意一个函数，具体来说，是将函数签名以及函数参数按ABI协议打包为一个最终的32byte值，作为call的调用参数，如下示例
        // -    另外还有三个类似call的底层调用在后续介绍：callcode, delegatecall, staticcall
        bytes memory payload = abi.encodeWithSignature("register(string)", "Diga");
        (bool succ2, ) = address(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24).call(payload);
        require(succ2);
    }

}