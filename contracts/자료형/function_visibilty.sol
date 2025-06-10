//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract FunctionVisibility{

    uint8 private data = 255;
    uint8 public data2 = 255;
    uint8 public data3 = 255;
    uint8 public data4 = 255;
    
    function setData(uint8 _data) private {//private 외부에서 접근 불가,상속된 자식에서도 접근 불가, 내부에서만 접근 가능
        
        data = _data;
    }

    function setData2(uint8 _data) internal {//internal 외부에서 접근 불가,상속된 자식에서 접근 가능, 내부에서만 접근 가능
        data2 = _data;
    }

    function setData3(uint8 _data) public { //public 외부에서 접근 가능,상속된 자식에서 접근 가능, 내부에서만 접근 가능
        data3 = _data;
    }

    function setData4(uint8 _data) external {//external 외부에서 접근 가능,상속된 자식에서 접근 불가, 내부에서 접근 불가
        data4 = _data;
    }
}

