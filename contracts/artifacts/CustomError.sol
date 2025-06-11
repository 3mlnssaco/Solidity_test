//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// CustomError Contract - 커스텀 에러 사용 예제
// ===============================================
// 
// 📌 커스텀 에러(Custom Error) 개념:
//   - Solidity 0.8.4부터 도입된 새로운 에러 처리 방식
//   - 기존 require(condition, "string")보다 가스 효율적
//   - 더 구체적이고 구조화된 에러 정보 제공 가능
//   - revert CustomErrorName() 형태로 사용
//   - 매개변수를 포함하여 더 상세한 에러 정보 전달 가능
//
// 💡 커스텀 에러의 장점:
//   - 가스 비용 절약 (문자열 저장 없음)
//   - 타입 안전성 (컴파일 시 검증)
//   - 구조화된 에러 데이터
//   - 더 명확한 에러 식별
//   - ABI에 포함되어 프론트엔드에서 처리 용이
//
// 🔗 사용 패턴:
//   - error ErrorName(): 단순 에러
//   - error ErrorName(type param): 매개변수가 있는 에러
//   - if (condition) revert ErrorName(): 조건부 에러 발생
// ===============================================

// 커스텀 에러 정의 (컨트랙트 외부에서 정의 가능)
error ZeroValueError(); // 0값 에러
error BelowMinimumError(uint256 sent, uint256 minimum); // 최소값 미달 에러
error UnauthorizedAccess(address caller, address owner); // 권한 없는 접근 에러
error InsufficientBalance(uint256 available, uint256 required); // 잔액 부족 에러
error InvalidAddress(address provided); // 잘못된 주소 에러

contract CustomErrorDemo {
    // 주문 목록: 주소별 주문 금액 저장
    mapping(address => uint256) public orderList;
    
    // 최소 주문 금액
    uint256 public minPrice = 0.01 ether;
    
    // 컨트랙트 소유자
    address public owner;
    
    // 컨트랙트 잔액
    uint256 public contractBalance;
    
    /**
     * @dev 생성자 - 소유자 설정
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev 기본 주문 함수 - 단순 커스텀 에러 사용
     * @notice 0이 아닌 이더를 보내야 주문 생성 가능
     * 
     * 기존 방식: require(msg.value != 0, "Value cannot be zero");
     * 새로운 방식: if (msg.value == 0) revert ZeroValueError();
     */
    function order() external payable {
        // 커스텀 에러 사용: 0값 검사
        if (msg.value == 0) {
            revert ZeroValueError(); // 단순 커스텀 에러 발생
        }
        
        // 주문 저장
        orderList[msg.sender] = msg.value;
        contractBalance += msg.value;
    }
    
    /**
     * @dev 고급 주문 함수 - 매개변수가 있는 커스텀 에러 사용
     * @notice 최소 금액 이상의 이더를 보내야 주문 생성 가능
     * 
     * 매개변수가 있는 커스텀 에러로 더 상세한 정보 제공
     */
    function advancedOrder() external payable {
        // 0값 검사
        if (msg.value == 0) {
            revert ZeroValueError();
        }
        
        // 최소 금액 검사 (매개변수가 있는 커스텀 에러)
        if (msg.value < minPrice) {
            revert BelowMinimumError(msg.value, minPrice);
        }
        
        // 중복 주문 방지
        if (orderList[msg.sender] > 0) {
            revert("Duplicate order not allowed"); // 일반 문자열 에러도 혼용 가능
        }
        
        // 주문 저장
        orderList[msg.sender] = msg.value;
        contractBalance += msg.value;
    }
    
    /**
     * @dev 소유자 전용 함수 - 권한 검사 커스텀 에러
     * @param newMinPrice 새로운 최소 가격
     */
    function setMinPrice(uint256 newMinPrice) external {
        // 권한 검사 (매개변수로 호출자와 소유자 정보 제공)
        if (msg.sender != owner) {
            revert UnauthorizedAccess(msg.sender, owner);
        }
        
        // 유효성 검사
        if (newMinPrice == 0) {
            revert ZeroValueError();
        }
        
        minPrice = newMinPrice;
    }
    
    /**
     * @dev 이더 출금 함수 - 잔액 부족 커스텀 에러
     * @param amount 출금할 금액
     * @param to 받을 주소
     */
    function withdraw(uint256 amount, address payable to) external {
        // 권한 검사
        if (msg.sender != owner) {
            revert UnauthorizedAccess(msg.sender, owner);
        }
        
        // 주소 유효성 검사
        if (to == address(0)) {
            revert InvalidAddress(to);
        }
        
        // 잔액 검사 (현재 잔액과 요청 금액을 매개변수로 제공)
        if (contractBalance < amount) {
            revert InsufficientBalance(contractBalance, amount);
        }
        
        // 실제 컨트랙트 이더 잔액 확인
        if (address(this).balance < amount) {
            revert InsufficientBalance(address(this).balance, amount);
        }
        
        // 출금 실행
        contractBalance -= amount;
        to.transfer(amount);
    }
    
    /**
     * @dev 주문 취소 함수 - 다양한 커스텀 에러 조합
     * @param user 취소할 사용자 주소
     */
    function cancelOrder(address user) external {
        // 권한 검사
        if (msg.sender != owner) {
            revert UnauthorizedAccess(msg.sender, owner);
        }
        
        // 주소 유효성 검사
        if (user == address(0)) {
            revert InvalidAddress(user);
        }
        
        // 주문 존재 검사
        uint256 orderAmount = orderList[user];
        if (orderAmount == 0) {
            revert("No order found for user"); // 일반 문자열 에러
        }
        
        // 주문 취소
        orderList[user] = 0;
        contractBalance -= orderAmount;
    }
    
    /**
     * @dev 조건부 에러 발생 테스트 함수
     * @param errorType 발생시킬 에러 타입 (1-5)
     */
    function triggerCustomError(uint8 errorType) external view {
        if (errorType == 1) {
            revert ZeroValueError();
        } else if (errorType == 2) {
            revert BelowMinimumError(100, 1000);
        } else if (errorType == 3) {
            revert UnauthorizedAccess(msg.sender, owner);
        } else if (errorType == 4) {
            revert InsufficientBalance(500, 1000);
        } else if (errorType == 5) {
            revert InvalidAddress(address(0));
        } else {
            revert("Invalid error type");
        }
    }
    
    /**
     * @dev 컨트랙트 정보 조회 함수
     * @return minPrice_ 최소 가격
     * @return contractBalance_ 컨트랙트 잔액
     * @return actualBalance 실제 이더 잔액
     * @return owner_ 소유자 주소
     */
    function getContractInfo() external view returns (
        uint256 minPrice_,
        uint256 contractBalance_,
        uint256 actualBalance,
        address owner_
    ) {
        return (
            minPrice,
            contractBalance,
            address(this).balance,
            owner
        );
    }
    
    /**
     * @dev 이더를 받을 수 있도록 함
     */
    receive() external payable {
        contractBalance += msg.value;
    }
}