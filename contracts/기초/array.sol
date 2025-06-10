//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Array {
    // 동적 배열 선언
    int[] public intList;
    // 고정 길이 배열 선언
    int[3] public int3List;

    // 구조체 선언
    struct Product {
        string name;
        uint price;
    }

    // 생성자에서 배열 값 할당
    constructor() {
        // int3List에 값 할당
        int3List = [int(1), int(2), int(3)];

        // intList에 값 추가
        intList.push(1);
        intList.push(2);
        intList.push(3);
        intList.push(4);
        intList.push(5);

        // 배열의 두 번째 요소 삭제
        delete intList[1];

        // 마지막 요소 제거 (값 반환 없음)
        intList.pop();
    }

    // 배열의 두 번째 요소를 반환하는 함수
    function getSecondData() public view returns (int) {
        return intList[1];
    }

    // 배열의 마지막 요소를 반환하는 함수
    function getLastData() public view returns (int) {
        return intList[intList.length - 1];
    }
}
