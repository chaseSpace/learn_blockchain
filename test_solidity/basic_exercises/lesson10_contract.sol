// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@合约
-   介绍
    前面已经介绍了一些合约内容，这里介绍一些边角料。
    构造函数：
        -   如果不声明，编译时会自动创建
        -   新版本已经不推荐用public/internal标识可见性，而是用abstract表示是一个抽象合约，无法部署
    constant状态变量
        -   仅状态变量可用，常量不存在storage区
        -   必须编译时能够确定值，可以使用内建函数，如 keccak256/sha256/ripemd160/ecrecover/addmod/mulmod
    immutable状态变量
        -   与常量类似，但可以先声明，然后在构造函数中初始化
        -   部署时确定，不可再改
    view函数：未修改状态的函数需要标识view状态，以下操作被认为是修改状态
        -   修改状态变量
        -   触发事件
        -   创建其他合约
        -   selfdestruct()
        -   调用发送以太币
        -   调用没有标记view、pure的函数
        -   使用低级调用
        -   使用包含特定操作码的内联汇编
    pure函数：不读取也不修改状态的函数需要标识pure，以下操作被认为是读取状态：
        -   读取状态变量
        -   访问address(this).balance 或 .balance
        -   访问block、tx、msg中任意成员（除了msg.sig, msg.data）
        -   调用未标记pure的函数
        -   使用包含特定操作码的内联汇编
    getter函数：public的状态变量，会自动被创建一个变量访问函数
        -   对于值类型的变量，生成一个同名无参数函数
        -   对于数组，生成一个同名且以下标为参数的函数；若要获取整个数组，需要手工添加函数
        -   对于map，生成一个同名且以key为参数的函数，同上
        -   对于一个嵌套数组的map，会生成一个同名，且多个参数的函数，用以访问最深层结构的元素
            -   比如mapping(uint => mapping(bool => uint[])) data; 生成的函数：function data(uint key, bool key2, index key3) returns (uint)
    receive函数：一个合约需要定义（最多）一个receive函数来接收以太币，若没有，还可以定义一个payable的fallback函数来替代，都没有则往这个合约的转账操作会报错！
        -   无需function关键字
        -   签名要求：receive() external payable;   fallback() external payable;
    fallback函数：合约中最多存在一个的特殊函数，中文叫回退函数。
        -   无需function关键字
        -   用途：在合约被调用时，未实现对应函数时执行；另一个作用是替代receive()
*/

contract LearnGetter {
    mapping(uint => mapping(bool => uint[])) public data;
}

contract LearnContract{
    // uint constant a;  // 必须给一个值
    // uint constant now1 = block.timestamp;  // 区块时间戳无法编译器求值
    bytes32 constant x = keccak256("abc");

    uint immutable decimal; // 比如代币的小数点位需要在部署时指定，而不是编码时
    constructor(uint _decimal) {
        decimal = _decimal;
        // decimal = 1;  // 无法再修改

        LearnGetter g = new LearnGetter();
        uint x2 = g.data(1, false, 0);
        x2;
    }

}