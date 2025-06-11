// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// 'this' 키워드 사용 예시를 보여주는 컨트랙트
// ------------------------------------------------------
// this란?
//   - this는 현재 컨트랙트의 주소를 가리키는 키워드입니다.
//   - this를 사용하면 컨트랙트 자신을 외부에서 호출하는 것과 동일하게 함수 호출이 가능합니다.
//   - 즉, 내부 함수 호출과 달리, this를 사용하면 외부 함수 호출(External Call, 메시지 콜)이 일어납니다.
//   - this.externalFunc()는 외부에서 트랜잭션을 보내는 것과 같은 효과가 있습니다.
//   - 이 방식은 가스비가 더 들고, 재진입(reentrancy) 위험이 있으니 주의해야 합니다.
//   - 주로 컨트랙트 자신에게 이더를 보내거나, 외부 호출이 필요한 특수한 상황에서 사용합니다.
// ------------------------------------------------------
contract This {
    uint public data = 10;

    // 컨트랙트의 주소 반환
    function getThisAddress() public view returns (address) {
        return address(this); // 현재 컨트랙트의 주소
    }

    // 컨트랙트의 잔액 반환
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // 외부에서만 호출 가능한 함수
    function externalFunc() external {
        data = 15;
    }

    // 내부에서만 호출 가능한 함수
    function internalFunc() internal {
        // this를 사용해 외부 함수 호출 (메시지 콜)
        // 아래 코드는 컨트랙트 외부에서 externalFunc()를 호출하는 것과 동일하게 동작합니다.
        // 내부 함수 호출과 달리, 메시지 콜이 발생하며 가스비가 더 들고, 재진입 위험이 있습니다.
        this.externalFunc();
    }

    // public 함수에서 internalFunc 호출 (테스트용)
    function callInternalFunc() public {
        internalFunc();
    }

    // 이더를 받을 수 있도록 payable 함수 추가
    receive() external payable {}
}