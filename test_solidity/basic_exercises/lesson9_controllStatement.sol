// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@控制结构
-   介绍
    除了是switch和goto，solidity支持JS中的大多数控制语句，例如，if-else, while，do，for，break，continue，return;
    还有try-catch进行异常处理。

*/

contract LearnControlStatement {
    function testIf() public pure {
        // if-else省略

        // 单条if
        uint a;
        if (1==1) a = 1; // if包含的语句是单条，则可以省略{}
        return;
    }

    function testWhile() public pure {
        uint i=0;
        while (true) {
            if (i<3) {
                i ++;
                continue;
            }
            break;
        }

        while (i < 3) {}
    }

    function testFor() public pure{
        for (uint i=0; i<3; i++) {

        }
    }
}