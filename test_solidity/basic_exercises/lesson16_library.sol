// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@库
-   介绍
    使用关键字 library 定义，目的是定义一些可复用的函数，比如 SafeMath.sol 提供一些常见的数学操作
    特点：
        -   不能定义状态变量
    有3种使用方式：
        1. 内嵌库：即import之后，直接通过库合约名进行调用，下面代码就是示例；
        2. 链接库（如同上一节中的接口使用方式，不再演示）
            -   首先，若库有public/external函数，可以单独部署，这样在以太坊上有自己的地址
            -   其次，部署我们的合约时，可以通过把库合约地址写入合约里，在合约中通过Delegateall（委托调用）的方式调用库函数
                -   delegateall是类似call的一种低级调用，调用时使用的依旧是当前合约的上下文，即库合约中使用的状态变量和this都是我们的合约信息。
                -   为何库函数不能拥有自己的状态？
                    -   因为库函数会被不同的合约调用多次，这样无法保证库合约的状态，也就无法保证库函数的调用结果。
        3. using for *：如 using SafeMath for myType; 它将库合约关联到自己的类型，就好像自己的类型实现了那些库函数一样进行调用，是一种常用的简洁的调用方式！
            -   必须定义在storage区
*/


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/utils/math/SafeMath.sol";

library Math {
    // constructor() {}  // 不可以

    // uint a;  // 不可以
    function add(uint a, uint b) internal pure returns (uint) {
        return SafeMath.add(a, b);
    }
}

contract LearnLibrary {
    // 第3种方式
    using SafeMath for uint;

    constructor() {
        // 第1种方式
        require(Math.add(1, 1) == 2);

        // 第2种方式
        uint a = 1;
        require(a.add(1) == 2);
    }
}