// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract BlockProperty2 {
    // Block properties contract
    uint256 public blockNumber;
    uint256 public timestamp;
    
    constructor() {
        blockNumber = block.number;
        timestamp = block.timestamp;
    }
    
    function getCurrentBlockInfo() external view returns (uint256, uint256) {
        return (block.number, block.timestamp);
    }
}