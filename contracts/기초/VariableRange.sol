//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract VariableRange {
    // 상태 변수: 컨트랙트 전체에서 접근 가능
    uint private data = 10;

    // 상태 변수 반환 (view)
    function getData() public view returns (uint) {
        return data;
    }

    // 지역 변수 반환 (pure)
    function getData2() public pure returns (uint) {
        uint data = 5;
        return data;
    }
}
