pragma solidity ^0.8.20;
// SPDX-License-Identifier: MIT

contract DataType{

    bool public data1 = false;

    int public data2 = -10;
    uint public data3 = 10;
    
    uint256 public data4 = 10000000000; // 0~2^256-1 
    int256 public data5 = -10000000000; // -2^255~2^255-1

    uint8 public data6 =100; //  0 ~ 2^256 - 1 
    int8 public data7 = -100;  

    string public data8 = "fastcampus";
    bytes public data9 = "fastcampus";
    bytes20 public data = bytes20(0); //address
    bytes32 public data10 = bytes32(0); //hash

    address public data11 = address(0);
    address public data12 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

   
}