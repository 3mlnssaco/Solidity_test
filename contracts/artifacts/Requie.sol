//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ===============================================
// Require Contract - require() 함수 사용 예제
// ===============================================
// 
// 📌 require() 개념:
//   - 입력값 검증과 조건부 실행에 가장 많이 사용되는 함수
//   - 조건이 false면 트랜잭션을 롤백하고 에러 메시지 제공
//   - 사용된 가스는 환불됨 (트랜잭션 수수료 제외)
//   - 사용자 입력, 권한 검사, 상태 검증에 주로 사용
//   - 가장 일반적이고 권장되는 에러 처리 방식
//
// 💡 require() vs assert() vs revert():
//   - require(): 입력값/조건 검증 (권장)
//   - assert(): 내부 버그/불변성 검사 (드물게 사용)
//   - revert(): 명시적 실패 처리 (조건부 로직)
// ===============================================

contract Require {
    // 주문 목록: 주소별 송금액을 저장하는 매핑
    mapping(address => uint256) public orderList;
    
    // 최소 주문 금액
    uint256 public minAmount = 0.1 ether;
    
    // 최대 주문 금액  
    uint256 public maxAmount = 10 ether;
    
    // 컨트랙트 소유자
    address public owner;
    
    // 주문 활성화 상태
    bool public isOrderActive = true;
    
    /**
     * @dev 생성자 - 컨트랙트 배포자를 소유자로 설정
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev 주문 함수 - require()를 사용한 다중 조건 검증
     * @notice 여러 조건을 만족해야 주문이 성공됩니다
     * 
     * require() 사용 예시들:
     * 1. 상태 검증: 주문이 활성화되어 있는지
     * 2. 금액 범위 검증: 최소/최대 금액 사이인지  
     * 3. 중복 방지: 이미 주문한 사용자인지
     */
    function order() external payable {
        // 1. 상태 검증: 주문이 활성화되어 있어야 함
        require(isOrderActive, "Orders are currently disabled");
        
        // 2. 최소 금액 검증: 송금액이 최소값 이상이어야 함
        require(msg.value >= minAmount, "Amount is below minimum required");
        
        // 3. 최대 금액 검증: 송금액이 최대값 이하여야 함
        require(msg.value <= maxAmount, "Amount exceeds maximum allowed");
        
        // 4. 중복 주문 방지: 이미 주문한 사용자는 불가
        require(orderList[msg.sender] == 0, "You have already placed an order");
        
        // 모든 조건을 통과하면 주문 목록에 저장
        orderList[msg.sender] = msg.value;
    }
    
    /**
     * @dev 주문 취소 함수 - 권한 검증 예시
     * @param user 취소할 사용자 주소
     */
    function cancelOrder(address user) external {
        // 권한 검증: 소유자만 주문을 취소할 수 있음
        require(msg.sender == owner, "Only owner can cancel orders");
        
        // 주문 존재 검증: 해당 사용자가 주문을 했는지 확인
        require(orderList[user] > 0, "No order found for this user");
        
        // 주문 취소 (값을 0으로 설정)
        orderList[user] = 0;
    }
    
    /**
     * @dev 주문 활성화/비활성화 토글 - 소유자 전용
     */
    function toggleOrderStatus() external {
        require(msg.sender == owner, "Only owner can toggle order status");
        isOrderActive = !isOrderActive;
    }
    
    /**
     * @dev 설정 변경 함수 - 최소/최대 금액 설정
     */
    function updateLimits(uint256 _minAmount, uint256 _maxAmount) external {
        require(msg.sender == owner, "Only owner can update limits");
        require(_minAmount > 0, "Minimum amount must be greater than 0");
        require(_maxAmount > _minAmount, "Maximum must be greater than minimum");
        
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }
} 