//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Mapping {
    mapping(address => int) public balance;
    
    // Function to set balance for a given address
    function setBalance(address _addr, int _value) public {
        balance[_addr] = _value;
    }
    
    // Function to get balance for a given address (optional, since public mapping already provides this)
    function getBalance(address _addr) public view returns (int) {
        return balance[_addr];
    }
}