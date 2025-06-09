pragma solidity ^0.8.20;
// SPDX-License-Identifier: MIT

contract Operation{

    uint public intData;
    string public stringData;

    function math() public {
        intData = intData + 1; //더하기 연산
        intData += 1; //더하기 연산
        intData = intData - 1; //빼기 연산
        intData -= 1; //빼기 연산
        intData = intData * 2; //곱하기 연산
        intData *= 2; //곱하기 연산
        intData = intData / 2 ; //나누기 연산
        intData /= 2; //나누기 연산
        intData = intData % 2; //나머지 연산
        intData %= 2; //나머지 연산
    }

    function weitoEth() public {
        uint wei_data = 1 wei;
        // Correct conversion: wei to ETH (divide by 10^18)
        uint ethdata = wei_data / (10**18);
        // ETh =  //1 wei = 10^18  1000000000000000000 wei
    }

    function logical() public {
        bool true_data = true;
        bool false_data = false;
        
        if(true_data){

        }else{

        }
        if(true_data && false_data) //false
        if(true_data || false_data) //true
        if(true_data == false_data) //false
        if(true_data != false_data) //true

        if(true_data && false_data) //false
        if (true_data || false_data) { // true
            // Logic can be added here if needed
        }
    }
}