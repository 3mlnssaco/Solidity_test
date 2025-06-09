pragma solidity ^0.8.20;

contract Function{

    uint8 private data = 255;

    function setData(uint8 _data) public {
        data =_data;

    }

    function getData() public view returns(uint8) {
        return data;
    }

 

}