// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@gas优化
-   背景
    合约的存储和执行需要计算和存储资源，而矿工节点资源有限，所以用户需要为包含合约交互的交易设定一个合理的gas price和gas limit，以允许交易得到优先执行。
    同时需要知道：
        -   交易的gas计价是根据合约字节码长度和计算量进行的；
        -   单个区块消耗的gas数量是有上限的，2021年是1250万；
        -   随着DeFi的兴起，以太坊区块的空间利用率逐渐提高，由于矿工是按照gas price较高的交易优先打包的原则
            -   那么根据total gas=gas price * gas number公式，第一个变量增加，想要降低一笔交易的总gas消耗，只能降低gas数量，这就涉及到合约交易的gas优化。

-   介绍
    一笔交易中的gas消耗的组成=txGas + dataGas + opGas，其中txGas是交易本身的消耗，dataGas是指交易中的data字段携带数据消耗gas，而opGas是指合约计算量消耗gas
    -   txGas固定21000 gas
    -   data字段中，每个零字节数据或代码支付4 gas，每个非零字节数据或代码支付68 gas
    -   在交易gas的构成中，dataGas一般远小于opGas，优化的空间也比较小，优化gas的主要焦点在opGas上。大部分的OP消耗的gas数量是固定的（比如ADD消耗 3 个 gas）
        少部分OP的gas消耗是可变的，也是gas消耗的大头（比如SLOAD一个全新的非零值需要花费至少 20000 个 gas）。

    下面分析两种场景的gas消耗：
        1. 部署合约的交易的gas消耗：
            -   固定创建合约的gas消耗：32000 gas
            -   交易本身的gas费用：21000 gas
            -   data数据的gas费用：根据实际字节码长度计算
                -   每个非零字节数据或代码支付68 gas
                -   每个零字节数据或代码支付4 gas
            -   最占比例的部分：合约构造函数执行消耗的gas费用：取决于其中的计算量
                -   若构造函数为空，不消耗此部分gas；
            -   本次调用使用存储资源的gas费用：每32字节消耗20000 gas，使用1kb就是640000 gas
                -   合约字节码需要存储到链上，所以此部分需要消耗gas
            -   总消耗=total gas（53000+dataGas+stateVarGas+构造函数的opGas） * gas price(用户设置)

        2. 调用合约函数的gas消耗：
            -   交易本身的gas费用：21000 gas
            -   data数据的gas费用：根据实际字节码长度计算
                -   每个非零字节数据或代码支付68 gas
                -   每个零字节数据或代码支付4 gas
            -   本次调用使用存储资源的gas费用，函数调用操作本身不使用存储资源，此时为空（除了函数包含修改状态变量值的逻辑）
            -   最占比例的部分：函数计算量的gas消耗
                -   首先，待执行的每条EVM汇编指令都有对应的gas价格表，参考https://www.evm.codes/?fork=merge
                -   其次，执行过程中，创建临时的memory数据，或者修改storage变量都要消耗对应的gas
            -   总消耗=total gas（21000+dataGas+函数的opGas） * gas price(用户设置)


-   实例
    计算一笔创建合约的交易的gas消耗总价值： https://etherscan.io/tx/0xeed6c791744af81bde027c6bcb2ac927b6d7964535edfc434c060fec7d24de2b
    total gas的美元价值=gas_price * gas_used * ether_price= 86.74Gwei * 3,533,714 * 1e-9 Ether * $3829.61 = $1173.83，其中1e-9是把gwei转ether，3829.61是交易发生时1ETH的美元价格

*/

// TODO