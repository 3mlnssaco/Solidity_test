// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// 상태 변수와 지역 변수의 범위를 설명하는 컨트랙트
contract VariableRange {
    // 상태 변수: 컨트랙트 전체에서 접근 가능, 블록체인에 저장됨
    uint private data = 10;

    // 상태 변수 data의 값을 반환 (view: 상태를 읽기만 함)
    function getData() public view returns (uint) {
        return data; // 상태 변수 반환
    }

    // 지역 변수의 값을 반환 (pure: 상태를 읽거나 쓰지 않음)
    // 아래의 localData는 상태 변수 data와 이름이 다르므로 섀도잉 경고가 없음
    function getData2() public pure returns (uint) {
        uint localData = 5; // 함수 내에서만 사용되는 지역 변수
        return localData; // 지역 변수 반환
    }
}
