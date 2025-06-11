//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// TransactionProperty Contract - 트랜잭션 속성(Transaction Properties) 사용 예제
// ===============================================
// 
// 📌 트랜잭션 속성(Transaction Properties) 개념:
//   - 현재 트랜잭션과 관련된 정보에 접근할 수 있는 전역 변수들
//   - 각 트랜잭션마다 고유한 값을 가짐
//   - 호출자 정보, 전송 값, 함수 식별자 등 트랜잭션 컨텍스트 제공
//   - 스마트 컨트랙트의 접근 제어와 비즈니스 로직에 핵심적으로 사용
//
// 🔗 주요 트랜잭션 속성들:
//   - gasleft(): 남은 가스량 (함수)
//   - msg.data: 트랜잭션에 포함된 전체 호출 데이터 (바이트 배열)
//   - msg.sender: 트랜잭션 발신자 주소 (직접 호출자)
//   - msg.sig: 호출된 함수의 식별자 (함수 시그니처의 첫 4바이트)
//   - msg.value: 트랜잭션과 함께 전송된 이더 값 (wei 단위)
//   - tx.origin: 트랜잭션 최초 발신자 (EOA, 중간 컨트랙트 호출 무관)
//   - tx.gasprice: 트랜잭션의 가스 가격
//
// 💡 활용 사례:
//   - 접근 제어 (msg.sender 기반)
//   - 결제 시스템 (msg.value 기반)
//   - 함수 식별 (msg.sig 기반)
//   - 가스 최적화 (gasleft() 기반)
//   - 호출 체인 추적 (tx.origin vs msg.sender)
// ===============================================

contract TransactionProperty {
    // 🏷️ 각 트랜잭션 속성을 저장할 public 변수들
    
    /**
     * @dev 남은 가스량 (Gas Left)
     * - 현재 시점에서 남은 가스량을 저장
     * - 함수 실행 중 가스 소모량 추적 가능
     * - 가스 최적화 및 복잡한 계산의 실행 가능성 판단에 활용
     */
    uint public msg1;
    
    /**
     * @dev 호출 데이터 (Call Data) 
     * - 트랜잭션에 포함된 전체 바이트 데이터
     * - 함수 시그니처 + 매개변수 인코딩 데이터
     * - 저수준 호출이나 프록시 패턴에서 활용
     */
    bytes public msg2;
    
    /**
     * @dev 발신자 주소 (Sender Address)
     * - 현재 함수를 직접 호출한 주소 (EOA 또는 컨트랙트)
     * - 접근 제어의 핵심 요소
     * - 컨트랙트 간 호출 시 중간 컨트랙트 주소가 됨
     */
    address public msg3;
    
    /**
     * @dev 함수 시그니처 (Function Signature)
     * - 호출된 함수의 고유 식별자 (첫 4바이트)
     * - 함수명과 매개변수 타입으로 계산됨
     * - 프록시 패턴이나 동적 함수 호출에 활용
     */
    bytes4 public msg4;
    
    /**
     * @dev 전송된 이더 값 (Ether Value)
     * - 트랜잭션과 함께 전송된 이더량 (wei 단위)
     * - payable 함수에서만 0이 아닌 값 가능
     * - 결제 및 입금 로직의 핵심 데이터
     */
    uint public msg5;
    
    /**
     * @dev 트랜잭션 속성 업데이트 함수
     * @notice 호출 시점의 모든 트랜잭션 속성을 상태 변수에 저장
     * 
     * 이 함수를 호출할 때마다 해당 시점의 트랜잭션 정보가
     * 상태 변수들에 업데이트됩니다.
     */
    function updateProperties() external payable {
        // 현재 남은 가스량 저장
        msg1 = gasleft();
        
        // 호출 데이터 저장 (함수 시그니처 + 매개변수)
        msg2 = msg.data;
        
        // 직접 호출자 주소 저장
        msg3 = msg.sender;
        
        // 함수 시그니처 저장 (이 함수의 경우 updateProperties()의 시그니처)
        msg4 = msg.sig;
        
        // 전송된 이더 값 저장
        msg5 = msg.value;
    }
    
    /**
     * @dev 전송 값 확인 및 반환 함수
     * @return value 현재 트랜잭션으로 전송된 이더 값
     * @notice msg.value를 직접 반환하는 간단한 예제
     * 
     * payable 함수로 이더를 받을 수 있으며,
     * 전송된 값을 즉시 확인할 수 있습니다.
     */
    function checkValue() external payable returns (uint) {
        uint value = msg.value;  // 지역 변수에 저장
        return value;            // 전송된 이더 값 반환
    }
    
    /**
     * @dev 발신자 검증 함수 예제
     * @param expectedSender 예상 발신자 주소
     * @return bool 실제 발신자가 예상 발신자와 같은지 여부
     */
    function verifySender(address expectedSender) external view returns (bool) {
        return msg.sender == expectedSender;
    }
    
    /**
     * @dev 함수 시그니처 비교 함수 예제  
     * @param expectedSig 예상 함수 시그니처
     * @return bool 현재 함수 시그니처가 예상과 같은지 여부
     */
    function verifySignature(bytes4 expectedSig) external pure returns (bool) {
        return expectedSig == bytes4(keccak256("verifySignature(bytes4)"));
    }
    
    /**
     * @dev 최소 이더 값 검증 함수 예제
     * @param minValue 최소 요구 이더 값 (wei)
     * @return bool 전송된 값이 최소값 이상인지 여부
     */
    function checkMinValue(uint minValue) external payable returns (bool) {
        return msg.value >= minValue;
    }
    
    /**
     * @dev 가스 사용량 추적 함수 예제
     * @return startGas 함수 시작 시 가스량
     * @return endGas 함수 종료 시 가스량  
     * @return usedGas 사용된 가스량
     */
    function trackGasUsage() external view returns (uint startGas, uint endGas, uint usedGas) {
        startGas = gasleft();           // 시작 시점 가스량
        
        // 임시 계산 작업 (가스 소모)
        uint temp = 0;
        for(uint i = 0; i < 100; i++) {
            temp += i;
        }
        
        endGas = gasleft();             // 종료 시점 가스량  
        usedGas = startGas - endGas;    // 사용된 가스량 계산
        
        return (startGas, endGas, usedGas);
    }
    
    /**
     * @dev 트랜잭션 전체 정보 조회 함수
     * @return gasLeft 남은 가스량
     * @return sender 발신자 주소
     * @return value 전송된 이더 값
     * @return signature 함수 시그니처
     * @return dataLength 호출 데이터 길이
     */
         function getTransactionInfo() external payable returns (
        uint gasLeft,
        address sender, 
        uint value,
        bytes4 signature,
        uint dataLength
    ) {
        return (
            gasleft(),          // 현재 남은 가스량
            msg.sender,         // 발신자 주소
            msg.value,          // 전송된 이더 값
            msg.sig,           // 함수 시그니처
            msg.data.length    // 호출 데이터 길이
        );
    }
}