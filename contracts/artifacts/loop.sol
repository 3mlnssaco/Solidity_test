//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// Loop Contract - 반복문(for/while/do-while) 사용 예제
// ===============================================
// 
// 📌 반복문(Loop) 개념:
//   - 특정 조건이 만족될 때까지 코드 블록을 반복 실행하는 제어 구조
//   - for: 반복 횟수가 정해진 경우 사용 (초기화, 조건, 증감)
//   - while: 조건이 true인 동안 반복 (조건 먼저 검사)
//   - do-while: 최소 1번은 실행 후 조건 검사 (실행 후 조건 검사)
//   - break: 반복문을 즉시 종료
//   - continue: 현재 반복을 건너뛰고 다음 반복으로 이동
//
// ⚠️ 가스 사용량 주의사항:
//   - 반복문은 많은 가스를 소모할 수 있음
//   - 무한 루프는 가스 한도로 인해 트랜잭션 실패 야기
//   - 반복 횟수를 제한하거나 최적화 필요
//   - 큰 배열 처리나 복잡한 계산 시 특히 주의
// ===============================================

contract Loopf {
    
    /**
     * @dev for 반복문 예제 - 1부터 10까지의 합계 계산
     * @return sum 계산된 합계 (1+2+3+...+10 = 55)
     * 
     * for 반복문 구조:
     * for (초기화; 조건; 증감) { 실행할 코드 }
     * - 초기화: uint8 i = 1 (시작값)
     * - 조건: i < 11 (계속 조건)  
     * - 증감: i++ (매 반복마다 i를 1씩 증가)
     */
    function forLoop() public pure returns (uint8) {
        uint8 sum = 0; // 합계를 저장할 변수
        
        // for 반복문: i가 1부터 10까지 반복
        for (uint8 i = 1; i < 11; i++) {
            sum += i; // 현재 i 값을 합계에 추가
        }
        
        return sum; // 최종 합계 반환 (55)
    }

    /**
     * @dev while 반복문 예제 - 동일한 계산을 while로 구현
     * @return sum 계산된 합계
     * 
     * while 반복문 특징:
     * - 조건을 먼저 검사한 후 실행
     * - 조건이 false가 될 때까지 반복
     * - 초기화와 증감을 수동으로 관리해야 함
     */
    function whileLoop() public pure returns (uint8) {
        uint8 sum = 0;  // 합계 변수
        uint8 i = 1;    // 카운터 변수 (수동 초기화)
        
        // while 반복문: i가 11 미만인 동안 반복
        while (i < 11) {
            sum += i;   // 현재 i 값을 합계에 추가
            i++;        // 카운터 수동 증가 (중요!)
        }
        
        return sum;     // 최종 합계 반환
    }

    /**
     * @dev do-while 반복문 예제 - 최소 1번은 실행 보장
     * @return sum 계산된 합계
     * 
     * do-while 반복문 특징:
     * - 실행한 후 조건을 검사
     * - 조건이 false여도 최소 1번은 실행됨
     * - 사용 빈도는 낮지만 특정 상황에서 유용
     */
    function doWhileLoop() public pure returns (uint8) {
        uint8 sum = 0;  // 합계 변수
        uint8 i = 1;    // 카운터 변수
        
        // do-while 반복문: 먼저 실행하고 조건 검사
        do {
            sum += i;   // 현재 i 값을 합계에 추가
            i++;        // 카운터 증가
        } while (i < 11); // 조건: i가 11 미만
        
        return sum;     // 최종 합계 반환
    }

    /**
     * @dev break 키워드 사용 예제 - 반복문 조기 종료
     * @return sum 계산된 합계
     * 
     * break 사용법:
     * - 특정 조건에서 반복문을 즉시 종료
     * - 반복문을 완전히 빠져나감
     * - 여기서는 i > 10 조건이지만 실제로는 도달하지 않음
     */
    function loopbreak() public pure returns (uint8) {
        uint8 sum = 0;
        
        for (uint8 i = 1; i < 11; i++) {
            // 조건 검사: i가 10보다 크면 반복문 종료
            if (i > 10) {
                break; // 반복문 즉시 종료 (실제로는 i<11 조건으로 인해 실행 안됨)
            }
            sum += i; // i 값을 합계에 추가
        }
        
        return sum; // 결과: 55 (1+2+...+10)
    }

    /**
     * @dev continue 키워드 사용 예제 - 특정 반복 건너뛰기
     * @return sum 계산된 합계 (5를 제외한 합계)
     * 
     * continue 사용법:
     * - 현재 반복을 건너뛰고 다음 반복으로 이동
     * - 반복문은 계속 진행됨 (break와 다름)
     * - 특정 값을 제외하거나 조건부 처리 시 유용
     */
    function loopcontinue() public pure returns (uint8) {
        uint8 sum = 0;
        
        for (uint8 i = 1; i < 11; i++) {
            // 조건 검사: i가 5면 현재 반복을 건너뛰기
            if (i == 5) {
                continue; // 5를 건너뛰고 다음 반복(i=6)으로 이동
            }
            sum += i; // 5를 제외한 나머지 값들을 합계에 추가
        }
        
        return sum; // 결과: 50 (1+2+3+4+6+7+8+9+10)
    }
    
    /**
     * @dev 중첩 반복문 예제 - 구구단 일부 계산
     * @return result 2단부터 4단까지의 합계
     * 
     * 중첩 반복문 주의사항:
     * - 가스 사용량이 급격히 증가 (O(n²))
     * - 외부 루프 × 내부 루프 만큼 실행됨
     * - 큰 데이터셋에서는 가스 한도 초과 위험
     */
    function nestedLoop() public pure returns (uint16) {
        uint16 result = 0;
        
        // 외부 반복문: 2단부터 4단까지
        for (uint8 i = 2; i <= 4; i++) {
            // 내부 반복문: 각 단의 1부터 5까지
            for (uint8 j = 1; j <= 5; j++) {
                result += i * j; // 구구단 결과를 누적
            }
        }
        
        return result; // 2×(1+2+3+4+5) + 3×(1+2+3+4+5) + 4×(1+2+3+4+5)
    }
    
    /**
     * @dev 배열 처리 반복문 예제
     * @param numbers 처리할 숫자 배열
     * @return sum 배열 원소들의 합계
     * 
     * 배열 반복 처리 패턴:
     * - 배열.length를 사용해 동적 크기 처리
     * - 인덱스 기반 접근으로 각 원소 처리
     * - 큰 배열의 경우 가스 사용량 주의 필요
     */
    function processArray(uint8[] memory numbers) public pure returns (uint16) {
        uint16 sum = 0;
        
        // 배열의 모든 원소를 순회
        for (uint i = 0; i < numbers.length; i++) {
            sum += numbers[i]; // 각 원소를 합계에 추가
        }
        
        return sum; // 배열 원소들의 총합
    }
}
