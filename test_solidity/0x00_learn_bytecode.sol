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