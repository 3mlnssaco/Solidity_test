//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ===============================================
// IfElse Contract - 조건문(if/else) 사용 예제
// ===============================================
// 
// 📌 조건문(if/else) 개념:
//   - 특정 조건에 따라 다른 코드를 실행하는 제어 구조
//   - if: 조건이 true일 때 실행
//   - else if: 이전 조건이 false이고 새로운 조건이 true일 때 실행
//   - else: 모든 조건이 false일 때 실행
//   - 스마트 컨트랙트에서 비즈니스 로직 구현에 필수적
//
// 💡 조건문 활용 케이스:
//   - 가격 범위에 따른 다른 처리
//   - 사용자 권한에 따른 접근 제어
//   - 상태에 따른 다른 동작 실행
//   - 입력값 검증 및 분기 처리
// ===============================================

contract IfElse {
    // 최소 허용 가격
    uint public minimalPrice = 1000;
    
    // 최대 허용 가격  
    uint public maxPrice = 100000;

    // 소유권 정보를 저장하는 매핑
    // key: 카테고리 번호, value: 소유자 주소
    mapping(int => address) public owner;

    /**
     * @dev 단순 조건문 예제 (if-else)
     * @param ask_price 요청 가격
     * @notice 가격이 최소값보다 높으면 소유권 부여, 아니면 실패
     * 
     * 단순 이분법 로직:
     * - 조건 만족: 소유권 부여
     * - 조건 불만족: 거부 (revert)
     */
    function conditional(uint ask_price) public {
        // 단순 if-else 구조
        if (ask_price > minimalPrice) {
            // 조건 만족: 카테고리 1의 소유자를 호출자로 설정
            owner[1] = msg.sender;
        } else {
            // 조건 불만족: 트랜잭션 실패 처리
            revert("Price too low");
        }
    }

    /**
     * @dev 다중 조건문 예제 (if-else if-else)
     * @param ask_price 요청 가격
     * @notice 가격 범위에 따라 다른 처리를 수행
     * 
     * 3단계 가격 검증 로직:
     * 1. 너무 높은 가격 → 거부
     * 2. 적정 가격 범위 → 승인
     * 3. 너무 낮은 가격 → 거부
     */
    function conditional2(uint ask_price) public {
        // 다중 조건문 구조 (if-else if-else)
        
        if (ask_price > maxPrice) {
            // 첫 번째 조건: 가격이 너무 높은 경우
            revert("Price too high");
            
        } else if (ask_price > minimalPrice) {
            // 두 번째 조건: 적정 가격 범위인 경우
            // (minimalPrice < ask_price <= maxPrice)
            owner[1] = msg.sender;
            
        } else {
            // 세 번째 조건 (else): 가격이 너무 낮은 경우
            // (ask_price <= minimalPrice)
            revert("Price too low");
        }
    }
    
    /**
     * @dev 복합 조건문 예제 - 논리 연산자 활용
     * @param ask_price 요청 가격
     * @param isVip VIP 사용자 여부
     * @notice VIP 사용자는 가격 조건이 완화됩니다
     */
    function conditionalWithLogic(uint ask_price, bool isVip) public {
        // 논리 연산자(&&, ||)를 활용한 복합 조건
        if (isVip && ask_price > (minimalPrice / 2)) {
            // VIP이면서 최소 가격의 50% 이상인 경우
            owner[2] = msg.sender;
        } else if (!isVip && ask_price > minimalPrice) {
            // 일반 사용자이면서 최소 가격 이상인 경우
            owner[1] = msg.sender;
        } else {
            // 모든 조건을 만족하지 않는 경우
            revert("Conditions not met");
        }
    }
    
    /**
     * @dev 중첩 조건문 예제
     * @param ask_price 요청 가격
     * @param category 카테고리 번호
     */
    function nestedConditional(uint ask_price, int category) public {
        // 외부 조건: 가격 검증
        if (ask_price > minimalPrice) {
            // 내부 조건: 카테고리별 처리
            if (category == 1) {
                owner[1] = msg.sender;
            } else if (category == 2) {
                owner[2] = msg.sender;
            } else {
                revert("Invalid category");
            }
        } else {
            revert("Price too low");
        }
    }
}