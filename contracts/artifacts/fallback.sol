//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// Fallback Contract - fallback/receive 함수 사용 예제
// ===============================================
// 
// 📌 fallback/receive 함수 개념:
//   - 스마트 컨트랙트가 이더를 받거나 존재하지 않는 함수 호출을 처리하는 특수 함수
//   - receive(): 순수한 이더 전송 시 호출 (msg.data가 비어있을 때)
//   - fallback(): 존재하지 않는 함수 호출 시 또는 msg.data가 있는 이더 전송 시 호출
//   - 둘 다 external이어야 하며, payable로 선언하면 이더를 받을 수 있음
//   - 가스 한도가 낮으므로 복잡한 로직은 피해야 함 (2300 gas)
//
// 🔗 호출 우선순위:
//   1. 정확한 함수 시그니처가 있으면 해당 함수 호출
//   2. msg.data가 비어있고 이더가 전송되면 receive() 호출
//   3. 그 외의 경우 fallback() 호출
//   4. receive()도 fallback()도 없으면 거래 실패
//
// 💡 주요 사용 사례:
//   - 단순 이더 수신 (receive)
//   - 프록시 패턴 구현 (fallback)
//   - 존재하지 않는 함수 호출 로깅 (fallback)
//   - 토큰 스왑이나 DEX 기능 (receive)
//   - 기본 동작 정의 (둘 다)
// ===============================================

contract FallbackDemo {
    // 컨트랙트 상태 변수들
    uint public data = 0;
    uint public receiveCount = 0;      // receive 호출 횟수
    uint public fallbackCount = 0;     // fallback 호출 횟수
    uint public totalReceived = 0;     // 받은 총 이더량
    
    // 이벤트 정의
    event EtherReceived(address sender, uint amount, string method);
    event FunctionCalled(address sender, bytes data);
    event UnknownFunctionCalled(address sender, bytes data);
    
    /**
     * @dev 생성자 - 초기 데이터 설정
     */
    constructor() {
        data = 5;
    }
    
    /**
     * @dev 일반 payable 함수 - 테스트용
     * @notice 이더를 받으면서 데이터를 변경하는 함수
     */
    function order() external payable {
        data = 9;
        totalReceived += msg.value;
        
        emit FunctionCalled(msg.sender, msg.data);
    }
    
    /**
     * @dev receive 함수 - 순수한 이더 전송 시 호출
     * @notice msg.data가 비어있는 이더 전송 시에만 호출됨
     * 
     * 호출 조건:
     * - msg.data.length == 0
     * - msg.value > 0
     * - 직접적인 이더 전송 (call{value: amount}(""))
     * 
     * 주의사항:
     * - 가스 제한 2300 (transfer, send 사용 시)
     * - 복잡한 로직 금지
     * - 상태 변수 수정은 가능하지만 최소한으로
     */
    receive() external payable {
        // 간단한 상태 업데이트만 수행
        receiveCount++;
        totalReceived += msg.value;
        
        // 이벤트 발생 (로깅용)
        emit EtherReceived(msg.sender, msg.value, "receive");
        
        // 특정 조건에서 에러 발생 (예: 너무 적은 금액)
        require(msg.value >= 0.001 ether, "Minimum 0.001 ETH required");
    }
    
    /**
     * @dev fallback 함수 - 기타 모든 호출 처리
     * @notice 존재하지 않는 함수 호출이나 msg.data가 있는 이더 전송 시 호출
     * 
     * 호출 조건:
     * - 존재하지 않는 함수 호출
     * - msg.data.length > 0인 이더 전송
     * - receive() 함수가 없는 경우의 이더 전송
     * 
     * 활용 사례:
     * - 프록시 패턴 (delegate call)
     * - 함수 호출 로깅
     * - 기본 동작 정의
     */
    fallback() external payable {
        fallbackCount++;
        
        // 이더가 전송된 경우
        if (msg.value > 0) {
            totalReceived += msg.value;
            emit EtherReceived(msg.sender, msg.value, "fallback");
        }
        
        // 함수 호출 데이터가 있는 경우 로깅
        if (msg.data.length > 0) {
            emit UnknownFunctionCalled(msg.sender, msg.data);
            
            // 특정 함수 시그니처에 대한 커스텀 처리 예제
            bytes4 sig = bytes4(msg.data);
            
            // 예: getBalance() 함수 시그니처 (0x12065fe0)에 대한 처리
            if (sig == bytes4(keccak256("getBalance()"))) {
                // 원래라면 revert하지만, 여기서는 로깅만 수행
                data = 100; // 특별한 처리
            }
        }
        
        // fallback에서도 최소 금액 요구 (선택사항)
        if (msg.value > 0) {
            require(msg.value >= 0.001 ether, "Minimum 0.001 ETH required in fallback");
        }
    }
    
    /**
     * @dev 컨트랙트 상태 조회 함수
     * @return data_ 현재 데이터 값
     * @return receiveCount_ receive 호출 횟수
     * @return fallbackCount_ fallback 호출 횟수
     * @return totalReceived_ 받은 총 이더량
     * @return balance 현재 컨트랙트 이더 잔액
     */
    function getStatus() external view returns (
        uint data_,
        uint receiveCount_,
        uint fallbackCount_,
        uint totalReceived_,
        uint balance
    ) {
        return (
            data,
            receiveCount,
            fallbackCount,
            totalReceived,
            address(this).balance
        );
    }
    
    /**
     * @dev 이더 출금 함수 (테스트용)
     * @param amount 출금할 금액
     */
    function withdraw(uint amount) external {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(msg.sender).transfer(amount);
    }
    
    /**
     * @dev 존재하지 않는 함수 호출 테스트를 위한 함수
     * @param target 호출할 컨트랙트 주소
     * @param functionData 호출 데이터
     * @return success 호출 성공 여부
     * @return returnData 반환 데이터
     */
    function testUnknownFunction(address target, bytes memory functionData) 
        external 
        payable 
        returns (bool success, bytes memory returnData) 
    {
        // 저수준 call을 사용하여 존재하지 않는 함수 호출
        (success, returnData) = target.call{value: msg.value}(functionData);
    }
    
    /**
     * @dev 상태 변수 리셋 함수 (테스트용)
     */
    function reset() external {
        data = 0;
        receiveCount = 0;
        fallbackCount = 0;
        totalReceived = 0;
    }
}

// ===============================================
// 고급 fallback 패턴 예제 - 프록시 컨트랙트
// ===============================================

/**
 * @dev 간단한 프록시 컨트랙트 예제
 * @notice 모든 호출을 다른 컨트랙트로 위임하는 프록시 패턴
 */
contract SimpleProxy {
    address public implementation; // 구현 컨트랙트 주소
    address public admin;          // 관리자 주소
    
    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }
    
    /**
     * @dev 구현 컨트랙트 주소 변경 (업그레이드)
     */
    function upgrade(address newImplementation) external {
        require(msg.sender == admin, "Only admin");
        implementation = newImplementation;
    }
    
    /**
     * @dev 프록시 fallback - 모든 호출을 구현 컨트랙트로 위임
     */
    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "No implementation set");
        
        // delegatecall을 사용하여 구현 컨트랙트 함수 호출
        assembly {
            // 호출 데이터 복사
            calldatacopy(0, 0, calldatasize())
            
            // delegatecall 실행
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            
            // 반환 데이터 복사
            returndatacopy(0, 0, returndatasize())
            
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    /**
     * @dev 이더 수신 허용
     */
    receive() external payable {}
}