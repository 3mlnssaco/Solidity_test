//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ===============================================
// Assert Contract - assert() 함수 사용 예제
// ===============================================
// 
// 📌 assert() 개념:
//   - 내부 에러나 불변성(invariant) 검사에 사용
//   - 절대 실패하면 안 되는 조건을 검사 (예: 오버플로우, 언더플로우)
//   - 실패 시 모든 가스를 소모하고 상태를 롤백
//   - 컨트랙트 내부 로직의 버그를 찾는 용도
//   - require()와 달리 에러 메시지를 제공하지 않음
//
// 🔥 주의사항:
//   - assert()는 절대 실패하면 안 되는 조건에만 사용
//   - 사용자 입력 검증에는 require() 사용 권장
//   - assert() 실패는 심각한 버그를 의미함
// ===============================================

contract Assert{
    // 주문 목록: 주소별 송금액을 저장하는 매핑
    mapping(address => uint256) public orderList;

    /**
     * @dev 주문 함수 - assert()를 사용한 값 검증
     * @notice 이더를 보내면서 주문을 생성하는 함수
     * 
     * assert() 사용 이유:
     * - msg.value가 반드시 0이 아니어야 함
     * - 만약 0 값이 들어오면 컨트랙트 로직에 심각한 문제가 있음을 의미
     */
    function order () external payable{
        // assert: msg.value가 반드시 0이 아니어야 함
        // 실패 시: 모든 가스 소모, 트랜잭션 롤백, 에러 메시지 없음
        assert(msg.value != 0); 
        
        // 조건을 통과하면 주문 목록에 발신자와 송금액 저장
        orderList[msg.sender] = msg.value;
    }
}
