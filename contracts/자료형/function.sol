// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ===============================================
// Function Contract - 솔리디티 함수 기본 개념
// ===============================================
// 
// 📌 함수(Function) 개념:
//   - 솔리디티에서 코드를 재사용 가능한 블록으로 조직화하는 방법
//   - 특정 작업을 수행하거나 값을 반환하는 코드 단위
//   - 매개변수를 받고 결과를 반환할 수 있음
//   - 상태 변경성, 접근성, 실행 컨텍스트를 명시 가능
//
// 💡 함수 구조:
//   function 함수명(매개변수) 접근제한자 상태변경성 returns(반환타입) {
//       // 함수 본문
//       return 반환값;
//   }
//
// 🔗 함수 구성 요소:
//   - 함수명: 식별자, camelCase 권장
//   - 매개변수: 입력 데이터 (타입과 이름 명시)
//   - 접근제한자: public, private, internal, external
//   - 상태변경성: view, pure, payable (생략 시 상태 변경 가능)
//   - 반환타입: 함수가 반환하는 데이터의 타입
//   - 반환값: return 문을 통해 반환되는 실제 데이터
// ===============================================

/**
 * @title Function
 * @dev 솔리디티 함수의 기본 구조와 활용법을 보여주는 교육용 컨트랙트
 * @notice 함수 정의, 호출, 매개변수, 반환값 등 기본 개념 시연
 */
contract Function {
    
    // ========== 상태 변수 ==========
    
    /**
     * @dev 함수 조작을 위한 기본 상태 변수
     * @notice private으로 선언하여 내부에서만 접근 가능
     * 
     * 상태 변수 특징:
     * - 컨트랙트 레벨에서 선언
     * - 블록체인에 영구 저장
     * - 함수를 통해 읽기/쓰기 가능
     * - 가시성 수식어로 접근 제어
     */
    uint8 private data = 255;
    
    /**
     * @dev 함수 호출 횟수 추적
     */
    uint256 private callCount = 0;
    
    /**
     * @dev 함수 호출 기록을 위한 구조체
     */
    struct FunctionCall {
        string functionName;
        uint256 timestamp;
        address caller;
        uint256 inputValue;
    }
    
    /**
     * @dev 모든 함수 호출 기록을 저장하는 배열
     */
    FunctionCall[] private callHistory;
    
    /**
     * @dev 사용자별 데이터 저장 매핑
     */
    mapping(address => uint256) private userData;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 데이터 변경 시 발생하는 이벤트
     * @notice 함수 실행 결과를 외부에 알리는 방법
     */
    event DataChanged(
        address indexed caller,
        uint8 oldValue,
        uint8 newValue,
        uint256 timestamp
    );
    
    /**
     * @dev 함수 호출 시 발생하는 이벤트
     */
    event FunctionExecuted(
        string indexed functionName,
        address indexed caller,
        uint256 timestamp
    );
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자 (특별한 함수)
     * @notice 컨트랙트 배포 시 단 한 번만 실행되는 함수
     * 
     * 생성자 특징:
     * - constructor 키워드 사용
     * - 컨트랙트명과 동일할 필요 없음
     * - 배포 시점에만 실행
     * - 초기화 로직 구현
     * - 매개변수 받을 수 있음
     */
    constructor() {
        // 초기화 로직
        callCount = 0;
        userData[msg.sender] = 100; // 배포자에게 초기값 부여
        
        // 생성자 호출 기록
        callHistory.push(FunctionCall({
            functionName: "constructor",
            timestamp: block.timestamp,
            caller: msg.sender,
            inputValue: 0
        }));
    }
    
    // ========== 기본 함수 예제들 ==========
    
    /**
     * @dev 데이터 설정 함수 (원본 유지)
     * @param _data 설정할 새로운 데이터 값
     * @notice 상태 변수를 수정하는 기본 함수
     * 
     * 함수 기본 구조:
     * 1. function 키워드
     * 2. 함수명 (setData)
     * 3. 매개변수 (uint8 _data)
     * 4. 접근제한자 (public - 누구나 호출 가능)
     * 5. 함수 본문 ({ ... })
     */
    function setData(uint8 _data) public {
        // 입력 검증
        require(_data <= 255, "Data must be within uint8 range");
        require(_data != data, "New data must be different from current");
        
        // 이전 값 저장 (이벤트용)
        uint8 oldData = data;
        
        // 상태 변수 수정
        data = _data;
        
        // 호출 횟수 증가
        callCount++;
        
        // 호출 기록 저장
        _recordFunctionCall("setData", _data);
        
        // 이벤트 발생
        emit DataChanged(msg.sender, oldData, _data, block.timestamp);
        emit FunctionExecuted("setData", msg.sender, block.timestamp);
    }
    
    /**
     * @dev 데이터 조회 함수 (원본 유지)
     * @return uint8 현재 저장된 데이터 값
     * @notice 상태 변수를 읽는 view 함수
     * 
     * view 함수 특징:
     * - 상태를 읽을 수 있음
     * - 상태를 변경할 수 없음
     * - 로컬 호출 시 가스 비용 없음
     * - return 문으로 값 반환
     */
    function getData() public view returns(uint8) {
        return data; // 상태 변수 반환
    }
    
    // ========== 다양한 매개변수 예제 ==========
    
    /**
     * @dev 단일 매개변수 함수
     * @param _value 입력값
     * @return result 입력값의 2배
     * @notice 하나의 매개변수를 받는 함수 예제
     */
    function singleParameter(uint256 _value) external pure returns (uint256 result) {
        result = _value * 2;
        return result;
    }
    
    /**
     * @dev 다중 매개변수 함수
     * @param _a 첫 번째 숫자
     * @param _b 두 번째 숫자
     * @param _operation 연산 종류 (0: 덧셈, 1: 뺄셈, 2: 곱셈)
     * @return result 연산 결과
     * @notice 여러 매개변수를 받는 함수 예제
     */
    function multipleParameters(uint256 _a, uint256 _b, uint8 _operation) 
        external 
        pure 
        returns (uint256 result) 
    {
        if (_operation == 0) {
            result = _a + _b; // 덧셈
        } else if (_operation == 1) {
            result = _a > _b ? _a - _b : 0; // 뺄셈 (언더플로우 방지)
        } else if (_operation == 2) {
            result = _a * _b; // 곱셈
        } else {
            revert("Invalid operation"); // 잘못된 연산
        }
        
        return result;
    }
    
    /**
     * @dev 문자열 매개변수 함수
     * @param _message 입력 메시지
     * @param _prefix 접두사
     * @return combined 결합된 문자열
     * @return length 전체 길이
     * @notice 문자열을 매개변수로 받는 함수 예제
     */
    function stringParameters(string memory _message, string memory _prefix) 
        external 
        pure 
        returns (string memory combined, uint256 length) 
    {
        // 문자열 결합
        combined = string(abi.encodePacked(_prefix, ": ", _message));
        
        // 바이트 길이 계산
        length = bytes(combined).length;
        
        return (combined, length);
    }
    
    /**
     * @dev 배열 매개변수 함수
     * @param _numbers 숫자 배열
     * @return sum 배열 합계
     * @return average 평균값
     * @return count 배열 크기
     * @notice 배열을 매개변수로 받는 함수 예제
     */
    function arrayParameters(uint256[] memory _numbers) 
        external 
        pure 
        returns (uint256 sum, uint256 average, uint256 count) 
    {
        require(_numbers.length > 0, "Array cannot be empty");
        
        count = _numbers.length;
        sum = 0;
        
        // 배열 순회하여 합계 계산
        for (uint256 i = 0; i < _numbers.length; i++) {
            sum += _numbers[i];
        }
        
        // 평균값 계산
        average = sum / count;
        
        return (sum, average, count);
    }
    
    // ========== 다양한 반환값 예제 ==========
    
    /**
     * @dev 단일 반환값 함수
     * @param _input 입력값
     * @return 계산된 결과
     * @notice 하나의 값을 반환하는 함수
     */
    function singleReturn(uint256 _input) external pure returns (uint256) {
        return _input ** 2; // 제곱값 반환
    }
    
    /**
     * @dev 다중 반환값 함수
     * @param _value 입력값
     * @return doubled 2배값
     * @return tripled 3배값
     * @return squared 제곱값
     * @return isEven 짝수 여부
     * @notice 여러 값을 동시에 반환하는 함수
     */
    function multipleReturns(uint256 _value) 
        external 
        pure 
        returns (uint256 doubled, uint256 tripled, uint256 squared, bool isEven) 
    {
        doubled = _value * 2;
        tripled = _value * 3;
        squared = _value ** 2;
        isEven = (_value % 2 == 0);
        
        return (doubled, tripled, squared, isEven);
    }
    
    /**
     * @dev 명명된 반환값 함수
     * @param _a 첫 번째 값
     * @param _b 두 번째 값
     * @return sum 덧셈 결과 (명명된 반환값)
     * @return product 곱셈 결과 (명명된 반환값)
     * @notice 반환값에 이름을 지정하는 함수
     */
    function namedReturns(uint256 _a, uint256 _b) 
        external 
        pure 
        returns (uint256 sum, uint256 product) 
    {
        // 명명된 반환값에 직접 할당
        sum = _a + _b;
        product = _a * _b;
        
        // return 문 생략 가능 (명명된 반환값 사용 시)
        // return (sum, product); // 명시적 반환도 가능
    }
    
    // ========== 상태 변경 함수들 ==========
    
    /**
     * @dev 사용자 데이터 설정
     * @param _value 설정할 값
     * @notice 호출자별로 데이터를 저장하는 함수
     */
    function setUserData(uint256 _value) external {
        require(_value > 0, "Value must be positive");
        
        userData[msg.sender] = _value;
        callCount++;
        
        _recordFunctionCall("setUserData", _value);
        emit FunctionExecuted("setUserData", msg.sender, block.timestamp);
    }
    
    /**
     * @dev 사용자 데이터 조회
     * @param _user 조회할 사용자 주소
     * @return uint256 해당 사용자의 데이터
     * @notice 특정 사용자의 데이터를 조회하는 함수
     */
    function getUserData(address _user) external view returns (uint256) {
        return userData[_user];
    }
    
    /**
     * @dev 내 데이터 조회
     * @return uint256 호출자의 데이터
     * @notice msg.sender를 활용한 호출자 데이터 조회
     */
    function getMyData() external view returns (uint256) {
        return userData[msg.sender];
    }
    
    // ========== 내부 함수 ==========
    
    /**
     * @dev 함수 호출 기록을 저장하는 내부 함수
     * @param _functionName 호출된 함수명
     * @param _inputValue 입력값
     * @notice internal 키워드로 내부에서만 사용 가능
     * 
     * internal 함수 특징:
     * - 같은 컨트랙트에서만 호출 가능
     * - 상속받은 컨트랙트에서도 호출 가능
     * - 외부에서 직접 호출 불가
     * - 코드 재사용과 모듈화에 유용
     */
    function _recordFunctionCall(string memory _functionName, uint256 _inputValue) internal {
        callHistory.push(FunctionCall({
            functionName: _functionName,
            timestamp: block.timestamp,
            caller: msg.sender,
            inputValue: _inputValue
        }));
    }
    
    /**
     * @dev 값이 유효한지 검사하는 내부 함수
     * @param _value 검사할 값
     * @return bool 유효성 여부
     * @notice 입력 검증용 내부 함수
     */
    function _isValidValue(uint256 _value) internal pure returns (bool) {
        return _value > 0 && _value <= 1000000; // 1 ~ 1,000,000 범위
    }
    
    // ========== 조회 함수들 ==========
    
    /**
     * @dev 함수 호출 횟수 조회
     * @return uint256 총 호출 횟수
     * @notice 컨트랙트 사용 통계 조회
     */
    function getCallCount() external view returns (uint256) {
        return callCount;
    }
    
    /**
     * @dev 함수 호출 기록 조회
     * @return FunctionCall[] 모든 호출 기록
     * @notice 함수 실행 이력 조회
     */
    function getCallHistory() external view returns (FunctionCall[] memory) {
        return callHistory;
    }
    
    /**
     * @dev 최근 함수 호출 기록 조회
     * @param _count 조회할 기록 수
     * @return records 최근 호출 기록들
     * @notice 지정된 개수만큼 최근 기록 조회
     */
    function getRecentCalls(uint256 _count) external view returns (FunctionCall[] memory records) {
        uint256 totalCalls = callHistory.length;
        uint256 startIndex = totalCalls > _count ? totalCalls - _count : 0;
        uint256 recordCount = totalCalls - startIndex;
        
        records = new FunctionCall[](recordCount);
        
        for (uint256 i = 0; i < recordCount; i++) {
            records[i] = callHistory[startIndex + i];
        }
        
        return records;
    }
    
    /**
     * @dev 컨트랙트 상태 요약
     * @return currentData 현재 데이터 값
     * @return totalCalls 총 호출 횟수
     * @return myData 호출자의 데이터
     * @return historyLength 기록 개수
     * @notice 전체 상태를 한 번에 조회
     */
    function getContractSummary() external view returns (
        uint8 currentData,
        uint256 totalCalls,
        uint256 myData,
        uint256 historyLength
    ) {
        currentData = data;
        totalCalls = callCount;
        myData = userData[msg.sender];
        historyLength = callHistory.length;
        
        return (currentData, totalCalls, myData, historyLength);
    }
    
    // ========== 고급 함수 예제들 ==========
    
    /**
     * @dev 조건부 실행 함수
     * @param _condition 실행 조건
     * @param _value 처리할 값
     * @return result 실행 결과
     * @return executed 실행 여부
     * @notice 조건에 따라 다른 로직을 실행하는 함수
     */
    function conditionalExecution(bool _condition, uint256 _value) 
        external 
        returns (uint256 result, bool executed) 
    {
        if (_condition && _isValidValue(_value)) {
            userData[msg.sender] += _value;
            result = userData[msg.sender];
            executed = true;
            
            _recordFunctionCall("conditionalExecution", _value);
        } else {
            result = userData[msg.sender]; // 변경 없음
            executed = false;
        }
        
        return (result, executed);
    }
    
    /**
     * @dev 함수 오버로딩 예제 1 (매개변수 개수가 다름)
     * @param _value 단일 값
     * @return uint256 처리된 값
     * @notice 하나의 매개변수를 받는 버전
     */
    function processValue(uint256 _value) external pure returns (uint256) {
        return _value * 10;
    }
    
    /**
     * @dev 함수 오버로딩 예제 2 (매개변수 개수가 다름)
     * @param _value1 첫 번째 값
     * @param _value2 두 번째 값
     * @return uint256 처리된 값
     * @notice 두 개의 매개변수를 받는 버전
     */
    function processValue(uint256 _value1, uint256 _value2) external pure returns (uint256) {
        return (_value1 + _value2) * 5;
    }
    
    /**
     * @dev 함수 설명 정보 반환
     * @return info 함수에 대한 설명
     * @notice 교육용 정보 제공 함수
     */
    function getFunctionInfo() external pure returns (string memory info) {
        info = string(abi.encodePacked(
            "Functions are reusable code blocks. ",
            "They can take parameters, modify state, and return values. ",
            "Access modifiers control who can call them. ",
            "State mutability defines how they interact with blockchain state."
        ));
        
        return info;
    }
}