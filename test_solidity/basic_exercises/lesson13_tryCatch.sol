// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@错误处理函数
-   介绍
    常用的是assert/require，不同的是：
        -   assert()触发的异常会消耗所有剩余gas，而require不会
        -   操作符不同。assert触发异常时，solidity执行一个invalid指令0xfe，而require是执行0xfd(revert)
        -   assert触发一个Panic(uint256)异常；require触发一个Error(string)异常
        -   require可以接收一个string参数作为错误提示，assert不行。
    使用场景：
        -   assert通常用来测试内部错误，也就是合约部署前的测试任务
        -   require用来判断外部输入、外部调用的返回值是否满足条件
    会触发panic(uint256)异常的情况：
        -   访问数组的索引太大或负数，包含bytesN
        -   0当做除数或进行模运算
        -   位移负数位
        -   转换一个太大或负数作为枚举
        -   调用内部函数类型的初始化变量
        -   assert的输入是false
        -   空数组执行pop()
        -   访问一个不正确编码的storage区的字节数组
        -   分配较多memory或创建较大数组
        -   在unchecked{} 之外发生了算数溢出

    另外，可以调用revert()来手动回退。

    另外，v0.6.0开始，使用try/catch来捕获异常，如require/assert以及其他错误，在早期版本，一般通过低级调用如call、delegatecall来避免异常
*/



contract Example {
    function div(uint a) public pure {
        // require(a != 0, "a = 0"); // 测试1

        if (a == 0) {// 测试2
            revert("xxx");
        }

        1 % a;

    }
}

contract LearnTryCatch {
    event Data(bytes);

    Example ex = new Example();

    // 测试1.简单使用
    function test1() public view {
        try ex.div(0) {// 注意：仅能捕获try与花括号{之间的表达式错误

        } catch {
            revert("ex.div(0) error");
        }
    }

    // 测试2.捕获特定错误+兜底
    function test2() public {
        try ex.div(0) {

        } catch Error(string memory reason) {// 捕获require(false, reason) 或revert(reason)错误，要求目标也返回reason，否则只能被bytes exception捕获
            revert(reason);
        } catch (bytes memory exception) {// 任何类型的异常都会产生bytes数据。若上一个catch无法捕获，则这里兜底
            emit Data(exception);
        }
    }

    // 测试3.处理out-of-gas
    // -    若尝试捕获的外部调用设置的gas不足以完成调用，则异常会被exception捕获，而无法被Error()捕获
    function test3() public {
        try ex.div{gas : 10}(0) {// 设置2000就足够

        } catch Error(string memory reason) {// 由于 out-of-gas，无法捕获
            revert(reason);
        } catch (bytes memory exception) {// 捕获任何错误
            emit Data(exception);
            // exception="0x"
        }
    }
}