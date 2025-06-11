//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// Modifier Contract - 함수 수정자(modifier) 사용 예제
// ===============================================
// 
// 📌 Modifier(수정자) 개념:
//   - 함수 실행 전후에 특정 조건을 검사하거나 코드를 실행하는 기능
//   - 코드의 재사용성을 높이고 중복을 줄임
//   - 권한 검사, 입력값 검증, 상태 확인 등에 활용
//   - _;(세미콜론)는 원래 함수의 코드가 실행되는 지점을 의미
//   - 여러 함수에서 동일한 조건 검사를 재사용할 수 있음
//
// 💡 Modifier 활용 패턴:
//   - onlyOwner: 소유자만 실행 가능
//   - onlyWhenActive: 활성화 상태에서만 실행
//   - checkMinAmount: 최소 금액 검증
//   - nonReentrant: 재진입 공격 방지
//   - whenNotPaused: 일시정지 상태가 아닐 때만 실행
// ===============================================

contract Modifier {
    // 최소 가격 설정
    uint public minPrice = 10000;
    
    // 주문 목록: 주소별 주문 금액 저장
    mapping(address => int) public orderList;
    
    // 컨트랙트 소유자
    address public owner;
    
    // 컨트랙트 활성화 상태
    bool public isActive = true;
    
    /**
     * @dev 생성자 - 배포자를 소유자로 설정
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev 최소 가격 검증 수정자
     * @notice 함수 실행 전에 송금액이 최소 가격 이상인지 검증
     * 
     * 수정자 실행 순서:
     * 1. require 조건 검사
     * 2. 조건 통과 시 _;에서 원래 함수 실행
     * 3. 원래 함수 완료 후 수정자의 나머지 부분 실행 (여기서는 없음)
     */
    modifier checkMinPrice() {
        // 최소 가격 조건 검사
        require(msg.value >= minPrice, "Sent amount is below minimum price");
        _; // 이 지점에서 원래 함수가 실행됨
        // 함수 실행 후 추가 로직이 필요하면 여기에 작성
    }
    
    /**
     * @dev 소유자 권한 검증 수정자
     * @notice 함수 호출자가 컨트랙트 소유자인지 검증
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    /**
     * @dev 컨트랙트 활성화 상태 검증 수정자
     * @notice 컨트랙트가 활성화 상태일 때만 함수 실행 허용
     */
    modifier onlyWhenActive() {
        require(isActive, "Contract is currently inactive");
        _;
    }
    
    /**
     * @dev 중복 주문 방지 수정자
     * @notice 이미 주문한 사용자의 중복 주문을 방지
     */
    modifier preventDuplicateOrder() {
        require(orderList[msg.sender] == 0, "You have already placed an order");
        _;
    }
    
    /**
     * @dev 주문 함수 1 - 단일 수정자 사용
     * @notice 최소 가격 조건만 검사하는 주문 함수
     */
    function test1() public payable checkMinPrice {
        // checkMinPrice 수정자가 먼저 실행되어 최소 가격 검증
        orderList[msg.sender] = int(msg.value);
    }
    
    /**
     * @dev 주문 함수 2 - 다중 수정자 사용
     * @notice 여러 조건을 동시에 검사하는 주문 함수
     * 
     * 수정자 실행 순서:
     * 1. onlyWhenActive 실행
     * 2. checkMinPrice 실행  
     * 3. preventDuplicateOrder 실행
     * 4. 모든 조건 통과 시 함수 본문 실행
     */
    function test2() public payable onlyWhenActive checkMinPrice preventDuplicateOrder {
        // 모든 수정자 조건을 통과한 후 실행
        orderList[msg.sender] = int(msg.value);
    }
    
    /**
     * @dev 고급 주문 함수 - 파라미터가 있는 수정자와 함께 사용
     * @param multiplier 가격 승수
     */
    function advancedOrder(uint multiplier) public payable checkMinPrice {
        // 기본 최소 가격 검증 후 추가 로직 수행
        require(multiplier > 0 && multiplier <= 10, "Invalid multiplier");
        
        // 승수를 적용한 주문 금액 저장
        orderList[msg.sender] = int(msg.value * multiplier);
    }
    
    /**
     * @dev 소유자 전용 함수들 - onlyOwner 수정자 사용
     */
    
    // 최소 가격 변경 (소유자만 가능)
    function setMinPrice(uint _newMinPrice) public onlyOwner {
        require(_newMinPrice > 0, "Price must be greater than 0");
        minPrice = _newMinPrice;
    }
    
    // 컨트랙트 활성화/비활성화 토글 (소유자만 가능)
    function toggleContractStatus() public onlyOwner {
        isActive = !isActive;
    }
    
    // 특정 사용자 주문 취소 (소유자만 가능)
    function cancelUserOrder(address user) public onlyOwner {
        require(orderList[user] != 0, "No order found for this user");
        orderList[user] = 0;
    }
    
    /**
     * @dev 복합 조건 수정자 예제
     * @param threshold 임계값
     */
    modifier checkThreshold(uint threshold) {
        require(msg.value >= threshold, "Value below threshold");
        _;
    }
    
    // 동적 임계값을 사용하는 함수
    function orderWithThreshold(uint customThreshold) public payable checkThreshold(customThreshold) {
        orderList[msg.sender] = int(msg.value);
    }
}