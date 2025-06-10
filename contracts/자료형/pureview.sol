//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PureView{
    // 상태 변수 선언 (private: 외부에서 접근 불가)
    uint8 private data = 255;

    // 상태값을 조회하는 경우 view 사용
    function getData() public view returns (uint8)  {
        return data;
    }
    
    // 상태값을 조회하지 않고, 오직 입력값이나 내부 변수만 사용하는 경우 pure 사용
    function getPureData(string memory _data) public pure returns (string memory) {
        // 임시 변수 선언 (예시)
        uint8 temp_data = 9;
        // 입력받은 문자열을 그대로 반환
        return _data;
    }
}