// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// - 实现一个简单的读（retrieve）和写（store）的名字叫做Storage的合约
//   1. 合约部署后，可以在通过某些方式调用/查询合约中通过 public 关键字暴露给外部调用的 函数 或 变量，如果函数有参数，则需要传入参数

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    uint256 public number;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}