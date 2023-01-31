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
// 请结合本仓库下的文档进行理解：https://github.com/chaseSpace/learn_blockchain/blob/main/ethereum_execute_contract.md