// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Example {
    address _owner;
    uint abc = 0;
    constructor() {
        _owner = msg.sender;
    }
    function set_val(uint _value) public {
        abc = _value;
    }
}
// 请阅读本仓库下的文档：https://github.com/chaseSpace/learn_blockchain/blob/main/ethereum_execute_contract.md