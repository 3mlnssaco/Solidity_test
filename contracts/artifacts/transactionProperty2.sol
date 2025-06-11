//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// Transaction Property 2 - 트랜잭션 속성 고급 예제
// ===============================================
// 
// 📌 트랜잭션 속성 심화 개념:
//   - msg.sender: 함수를 호출한 주체의 주소
//   - msg.value: 트랜잭션과 함께 전송된 이더의 양 (wei 단위)
//   - 함수 시그니처(selector): 함수의 고유 식별자 (keccak256 해시의 첫 4바이트)
//   - mapping: 키-값 쌍을 저장하는 해시테이블 형태의 데이터 구조
//   - bytes4: 4바이트 고정 길이 바이트 배열 (함수 시그니처에 사용)
//
// 💡 함수 시그니처 개념:
//   - 함수명과 매개변수 타입을 조합한 문자열의 keccak256 해시값
//   - 예: "transfer(address,uint256)" → keccak256 → 첫 4바이트 추출
//   - 스마트 컨트랙트에서 호출할 함수를 식별하는 데 사용
//   - EVM에서 함수 호출 시 calldata의 첫 4바이트로 전송됨
//
// 🔗 실용적 활용 사례:
//   - 주문 시스템: 사용자별 주문 금액 추적
//   - 권한 검증: 특정 함수 호출 권한 확인
//   - 결제 시스템: 최소 금액 요구사항 검증
//   - 메타트랜잭션: 함수 시그니처 기반 검증
// ===============================================

/**
 * @title TransactionProperty2
 * @dev 트랜잭션 속성과 함수 시그니처를 활용한 고급 예제 컨트랙트
 * @notice 주문 관리, 함수 시그니처 검증, 금액 확인 기능 제공
 */
contract TransactionProperty2 {
    // ========== 상태 변수 ==========
    
    /**
     * @dev 사용자별 주문 금액을 저장하는 매핑
     * @notice key: 사용자 주소, value: 주문 금액 (wei 단위)
     * 
     * 매핑(Mapping) 특징:
     * - 키-값 쌍을 저장하는 해시테이블
     * - 가스 효율적인 데이터 저장/조회 (O(1) 시간복잡도)
     * - 기본값은 해당 타입의 초기값 (uint의 경우 0)
     * - 키가 존재하지 않아도 에러 없이 기본값 반환
     * - 이터레이션(순회) 불가능 (키 목록을 별도 관리해야 함)
     */
    mapping(address => uint) private orderList;
    
    /**
     * @dev 함수 시그니처 검증용 변수
     * @notice 특정 함수의 selector를 저장하여 비교 검증에 사용
     * 
     * bytes4 타입:
     * - 4바이트(32비트) 고정 길이 바이트 배열
     * - 함수 시그니처 저장에 최적화됨
     * - keccak256 해시의 첫 4바이트를 저장
     * - 메모리 효율적 (uint32와 동일한 크기)
     */
    bytes4 private checkFunction;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 새로운 주문이 생성될 때 발생하는 이벤트
     * @param sender 주문자 주소
     * @param amount 주문 금액 (wei 단위)
     * @param timestamp 주문 생성 시간
     */
    event OrderCreated(address indexed sender, uint amount, uint timestamp);
    
    /**
     * @dev 함수 시그니처 검증 결과 이벤트
     * @param caller 호출자 주소
     * @param expectedSelector 예상 시그니처
     * @param actualSelector 실제 시그니처
     * @param isMatch 일치 여부
     */
    event SignatureVerified(
        address indexed caller, 
        bytes4 expectedSelector, 
        bytes4 actualSelector, 
        bool isMatch
    );
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 검증할 함수 시그니처를 미리 설정
     */
    constructor() {
        // "newOrderList()" 함수의 시그니처를 미리 계산하여 저장
        // keccak256("newOrderList()") → 첫 4바이트 추출
        checkFunction = bytes4(keccak256("newOrderList()"));
    }
    
    // ========== 주요 함수들 ==========
    
    /**
     * @dev 새로운 주문을 생성하는 함수
     * @notice 호출자의 주소와 전송된 이더량을 기록
     * 
     * payable 한정자:
     * - 함수가 이더를 받을 수 있음을 의미
     * - payable 없이는 msg.value가 0이어야 함
     * - 이더를 받는 모든 함수는 payable로 선언 필수
     * 
     * external 가시성:
     * - 외부에서만 호출 가능 (다른 컨트랙트나 EOA에서)
     * - 내부에서는 this.functionName() 형태로만 호출 가능
     * - public보다 가스 효율적 (calldata 직접 사용)
     */
    function newOrderList() external payable {
        // msg.sender: 현재 함수를 호출한 주체의 주소
        // - EOA(개인 지갑)이면 지갑 주소
        // - 다른 컨트랙트면 그 컨트랙트 주소
        // - 트랜잭션 원본 발신자는 tx.origin으로 확인 가능
        
        // msg.value: 이 트랜잭션과 함께 전송된 이더량 (wei 단위)
        // - 1 ETH = 10^18 wei
        // - payable 함수에서만 0이 아닌 값 가능
        // - 함수 실행 중에는 변경되지 않는 상수값
        
        orderList[msg.sender] = msg.value;
        
        // 이벤트 발생으로 주문 생성 로깅
        emit OrderCreated(msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @dev 함수 시그니처 검증 함수
     * @return bool 저장된 시그니처와 일치하는지 여부
     * @notice 함수 시그니처 검증 로직 데모
     * 
     * view 한정자:
     * - 상태를 읽기만 하고 변경하지 않음
     * - 가스 소모 없음 (로컬에서 실행)
     * - storage 변수 읽기는 가능하지만 쓰기 불가
     * - pure와 달리 상태 변수 접근 가능
     */
    function newCheckFunction() external view returns (bool) {
        // 함수 시그니처 계산 과정:
        // 1. 함수명과 매개변수 타입을 문자열로 조합
        // 2. keccak256 해시 함수 적용
        // 3. 결과의 첫 4바이트 추출
        bytes4 selector = bytes4(keccak256("newOrderList()"));
        
        // 실제 프로젝트에서는 다음과 같은 용도로 활용:
        // - 메타트랜잭션에서 호출 함수 검증
        // - 프록시 패턴에서 함수 라우팅
        // - 권한 관리 시스템에서 함수별 접근 제어
        // - 업그레이드 가능한 컨트랙트에서 함수 호환성 검사
        
        bool isMatch = (selector == checkFunction);
        
        // 주의: view 함수에서는 이벤트 발생 불가 (상태 변경으로 간주)
        // 검증 결과를 확인하려면 별도의 non-view 함수 사용 필요
        
        return isMatch;
    }
    
    /**
     * @dev 함수 시그니처 검증 및 이벤트 로깅 (상태 변경 함수)
     * @return bool 저장된 시그니처와 일치하는지 여부
     * @notice 검증 결과를 이벤트로 기록하는 버전
     */
    function verifyAndLogSignature() external returns (bool) {
        bytes4 selector = bytes4(keccak256("newOrderList()"));
        bool isMatch = (selector == checkFunction);
        
        // 검증 결과 로깅 (상태 변경 함수에서만 가능)
        emit SignatureVerified(msg.sender, checkFunction, selector, isMatch);
        
        return isMatch;
    }
    
    /**
     * @dev 특정 사용자의 주문 금액이 요구사항을 만족하는지 확인
     * @param sender 확인할 사용자 주소
     * @param price 요구되는 최소 금액 (wei 단위)
     * @return bool 사용자의 주문 금액이 요구 금액 이상인지 여부
     * @notice 결제 검증, 권한 확인 등에 활용 가능
     * 
     * 매개변수 설계 원칙:
     * - sender: 검증 대상 주소 (msg.sender와 다를 수 있음)
     * - price: 비교 기준값 (wei 단위로 정밀한 계산)
     * 
     * 활용 사례:
     * - VIP 회원 자격 확인 (최소 구매 금액)
     * - 할인 혜택 적용 기준
     * - 참여 권한 검증 (최소 스테이킹 금액)
     * - 보상 지급 조건 확인
     */
    function checkOrderFunction(address sender, uint price) external view returns (bool) {
        // 매핑에서 값 조회:
        // - 존재하지 않는 키의 경우 기본값(0) 반환
        // - 별도의 존재 여부 확인이 필요한 경우 추가 로직 구현
        uint userOrderAmount = orderList[sender];
        
        // 논리 연산자 활용:
        // >= : 크거나 같음 (최소 조건 만족 확인)
        // > : 초과 (엄격한 조건)
        // == : 정확히 일치 (특정 금액)
        return userOrderAmount >= price;
    }
    
    // ========== 유틸리티 함수들 ==========
    
    /**
     * @dev 특정 사용자의 주문 금액 조회
     * @param sender 조회할 사용자 주소
     * @return uint 해당 사용자의 주문 금액 (wei 단위)
     * @notice 투명성을 위한 데이터 접근 함수
     */
    function getOrderAmount(address sender) external view returns (uint) {
        return orderList[sender];
    }
    
    /**
     * @dev 현재 설정된 체크 함수 시그니처 조회
     * @return bytes4 저장된 함수 시그니처
     * @notice 디버깅 및 검증용 함수
     */
    function getCheckFunctionSelector() external view returns (bytes4) {
        return checkFunction;
    }
    
    /**
     * @dev 호출자의 주문 금액 조회 (편의 함수)
     * @return uint 호출자의 주문 금액 (wei 단위)
     * @notice msg.sender를 자동으로 사용하는 편의 함수
     */
    function getMyOrderAmount() external view returns (uint) {
        return orderList[msg.sender];
    }
    
    /**
     * @dev 컨트랙트가 보유한 총 이더량 조회
     * @return uint 컨트랙트 잔액 (wei 단위)
     * @notice 컨트랙트 재정 상태 확인용
     */
    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }
    
    /**
     * @dev 임의의 함수 시그니처 계산 유틸리티
     * @param functionSignature 함수 시그니처 문자열 (예: "transfer(address,uint256)")
     * @return bytes4 계산된 함수 선택자
     * @notice 개발 및 테스트용 유틸리티 함수
     */
    function calculateSelector(string memory functionSignature) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(functionSignature)));
    }
    
    // ========== 관리자 함수들 ==========
    
    /**
     * @dev 컨트랙트 소유자가 이더를 인출하는 함수 (기본 구현)
     * @notice 실제 프로덕션에서는 접근 제어 추가 필요
     */
    function withdraw() external {
        // 실제 구현에서는 onlyOwner 등의 접근 제어 추가
        require(msg.sender != address(0), "Invalid caller");
        
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        // call을 사용한 안전한 이더 전송
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Withdraw failed");
    }
}
    
