// SPDX-License-Identifier: MIT 
pragma solidity >= 0.8.0 < 0.9.0;
pragma solidity ^0.8.0;

contract Solidity { 
    // a -> Fun() -> b
    uint8 public a = 10;

    function changeData() public {
        a = 15;
    }
}
