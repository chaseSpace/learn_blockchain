// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@全局变量和API
-   介绍
    之前已经介绍过一些API使用，比如<addr>.balance，<addr>.transfer()，以及错误处理函数require/assert/revert()
    这些都相当于是solidity的内建API；
    solidity还提供一些全局变量和API来访问区块信息以及一次消息调用的上下文信息，如下：
    -   blockhash(uint blockNum) returns (bytes32)  获取某个高度的区块哈希，允许查询最近256个区块（不含当前）
    -   block.coinbase returns (address)  获取挖出当前区块的矿工地址
    -   block.difficulty returns (uint) 获取当前区块难度
    -   block.gaslimit returns (uint)
    -   block.number returns (uint)  当前区块高度
    -   block.timestamp returns (uint)
    -   gasleft() returns (uint256) 获取剩余gas
    -   msg.data returns (bytes)  获取当前调用完整的calldata数据
    -   msg.sender returns (address)  当前调用的消息发送者，合约部署以及函数调用时可用
    -   msg.sig returns (bytes4) 当前调用函数的标识符
    -   msg.value returns (uint) 当前调用发送的以太币数量
    -   tx.gasprice returns (uint) 当前交易的gas price
    -   tx.origin returns (address payable) 交易的起始发起者；
        -   如果交易只有当前一个调用，那么msg.sender==tx.origin；如果交易中触发多个子调用，那么msg.sender是每个发起子调用的合约地址，而tx.origin是发起交易的签名者。

    另外，还有一些ABI编码及解码函数API（省略号表示不定长参数）：
        -   因为以太坊合约与外部的交互方式，以及合约之间的调用方式底层都是通过ABI编码进行的，所以有时候为了方便开发者进行底层调用，提供了这些API
            -   前面的代码示例中已经介绍了它们的使用方法，本节不再介绍
        -   abi.decode(bytes memory encodedData, (...))
        -   abi.encode(...) returns (bytes)  对参数进行ABI编码，若结果长度不足32字节，则填充至32字节
        -   abi.encodePacked(...) returns (bytes)  对参数进行ABI编码，与上个函数不同，它的编码结果不会填充到32字节，而是紧凑拼接一起
        -   abi.encodeWithSelector(bytes4 selector, ...) returns (bytes) 第二个开始是selector函数的参数，第二个开始的参数会被ABI编码，最后与selector拼接在一起返回
        -   abi.encodeWithSignature(string signature, ...) returns (bytes)  等价于abi.encodeWithSelector(bytes4(keccak256(<function_sig>)))

    另外，还提供了一些数学和密码学API：
        -   addmod(uint x, uint y, uint k) returns (uint) 计算 (x+y)%k
        -   mulmod(uint x, uint y, uint k) returns (uint) 计算 (x*y)%k
        -   keccak256(bytes memory) returns (bytes32)
        -   sha256(bytes memory) returns (bytes32)
        -   ripemd160(bytes memory) returns (bytes20)
        -   ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)  利用椭圆曲线签名恢复与公钥相关的地址，即通过签名数据计算出地址，错误返回零值
            -   参数分别是 ECDSA签名的值，r是签名的前32字节，s是签名的第二个32字节，v是签名的最后一个字节

*/


contract LearnGlobalVars {
    event Blockhash(bytes32);
    event Coinbase(address);
    event Difficulty(uint);
    event GasLimit(uint);
    event Number(uint);
    event Timestamp(uint);
    event GasLeft(uint);
    event TxGasPrice(uint);
    event TxOrigin(address);

    // 部署后观察日志
    constructor() {
        emit Number(block.number);
        emit Blockhash(blockhash(block.number - 1));
        emit Coinbase(block.coinbase);
        emit Difficulty(block.difficulty);
        emit GasLimit(block.gaslimit);
        emit Timestamp(block.timestamp);
        emit GasLeft(gasleft());
        emit TxGasPrice(tx.gasprice);
        emit TxOrigin(tx.origin);
    }
}