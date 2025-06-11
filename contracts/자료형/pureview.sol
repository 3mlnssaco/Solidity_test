// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// ===============================================
// PureView Contract - 함수 상태 변경성 예제
// ===============================================
// 
// 📌 함수 상태 변경성(State Mutability) 개념:
//   - 솔리디티 함수가 블록체인 상태에 미치는 영향을 명시
//   - 가스 비용과 보안성에 직접적인 영향
//   - 컴파일러 최적화와 정적 분석에 활용
//   - 함수의 의도와 제약사항을 명확히 표현
//
// 💡 상태 변경성 종류:
//   1. view: 상태를 읽을 수 있지만 변경 불가
//   2. pure: 상태를 읽지도 변경하지도 않음
//   3. payable: 이더를 받을 수 있음
//   4. 일반 함수: 상태를 읽고 변경 가능
//
// 🔗 가스 비용:
//   - view/pure 함수: 로컬 호출 시 가스 비용 없음
//   - 트랜잭션에서 view/pure 호출 시 가스 소모
//   - 상태 변경 함수: 항상 가스 소모
//   - 컨트랙트 간 호출 시 모든 함수 가스 소모
// ===============================================

/**
 * @title PureView
 * @dev view와 pure 함수 수식어의 차이점과 활용법을 보여주는 컨트랙트
 * @notice 상태 변경성에 따른 함수 분류와 최적화 방법 시연
 */
contract PureView {
    
    // ========== 상태 변수 ==========
    
    /**
     * @dev 상태 변수 선언 (private: 외부에서 접근 불가)
     * @notice view 함수에서 읽을 수 있는 상태 데이터
     * 
     * private 특징:
     * - 외부 컨트랙트와 상속받은 컨트랙트에서 접근 불가
     * - 같은 컨트랙트 내부에서만 접근 가능
     * - getter 함수가 자동 생성되지 않음
     * - 가스 효율성과 캡슐화에 유리
     */
    uint8 private data = 255;
    
    /**
     * @dev 추가 상태 변수들 (다양한 예제를 위해)
     */
    string private message = "Hello, Solidity!";
    mapping(address => uint256) private balances;
    uint256[] private numbers;
    bool private isInitialized = true;
    
    /**
     * @dev 상수 선언 (컴파일 타임에 고정)
     * @notice pure 함수에서도 사용 가능한 상수
     */
    uint256 public constant MAX_VALUE = 1000;
    string public constant CONTRACT_NAME = "PureView Example";
    
    /**
     * @dev 불변 변수 (배포 시점에 고정)
     * @notice 생성자에서만 설정 가능
     */
    address public immutable owner;
    uint256 public immutable deploymentTime;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 데이터 변경 시 발생하는 이벤트
     */
    event DataUpdated(uint8 oldValue, uint8 newValue, uint256 timestamp);
    
    /**
     * @dev 함수 호출 시 발생하는 이벤트
     */
    event FunctionCalled(string functionName, uint256 timestamp);
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 불변 변수 초기화
     */
    constructor() {
        owner = msg.sender;
        deploymentTime = block.timestamp;
        
        // 초기 데이터 설정
        numbers.push(1);
        numbers.push(2);
        numbers.push(3);
        balances[msg.sender] = 100;
    }
    
    // ========== VIEW 함수들 ==========
    
    /**
     * @dev 상태값을 조회하는 view 함수 (원본 유지)
     * @return uint8 현재 저장된 데이터 값
     * @notice view 함수의 기본 예제
     * 
     * view 함수 특징:
     * - 상태 변수를 읽을 수 있음
     * - 상태를 변경할 수 없음
     * - 로컬 호출 시 가스 비용 없음
     * - 블록체인 정보 (block, msg) 접근 가능
     * - 다른 view/pure 함수 호출 가능
     */
    function getData() public view returns (uint8) {
        return data; // 상태 변수 읽기
    }
    
    /**
     * @dev 메시지 조회 함수
     * @return string 저장된 메시지
     * @notice 문자열 상태 변수 읽기 예제
     */
    function getMessage() external view returns (string memory) {
        return message; // 문자열 상태 변수 읽기
    }
    
    /**
     * @dev 특정 주소의 잔액 조회
     * @param _address 조회할 주소
     * @return uint256 해당 주소의 잔액
     * @notice 매핑 상태 변수 읽기 예제
     */
    function getBalance(address _address) external view returns (uint256) {
        return balances[_address]; // 매핑에서 값 읽기
    }
    
    /**
     * @dev 배열 전체 조회
     * @return uint256[] 저장된 숫자 배열
     * @notice 배열 상태 변수 읽기 예제
     */
    function getNumbers() external view returns (uint256[] memory) {
        return numbers; // 배열 전체 반환
    }
    
    /**
     * @dev 배열 길이 조회
     * @return uint256 배열의 길이
     * @notice 상태 변수의 속성 읽기 예제
     */
    function getNumbersLength() external view returns (uint256) {
        return numbers.length; // 상태 변수의 속성 접근
    }
    
    /**
     * @dev 블록체인 정보와 상태 변수 조합 조회
     * @return currentData 현재 데이터 값
     * @return contractBalance 컨트랙트 잔액
     * @return blockNumber 현재 블록 번호
     * @return caller 호출자 주소
     * @notice view 함수에서 접근 가능한 정보들
     */
    function getComplexInfo() external view returns (
        uint8 currentData,
        uint256 contractBalance,
        uint256 blockNumber,
        address caller
    ) {
        currentData = data; // 상태 변수
        contractBalance = address(this).balance; // 컨트랙트 잔액
        blockNumber = block.number; // 블록 정보
        caller = msg.sender; // 메시지 정보
        
        return (currentData, contractBalance, blockNumber, caller);
    }
    
    // ========== PURE 함수들 ==========
    
    /**
     * @dev 입력값을 그대로 반환하는 pure 함수 (원본 유지)
     * @param _data 입력받을 문자열
     * @return string 입력받은 문자열 그대로 반환
     * @notice pure 함수의 기본 예제
     * 
     * pure 함수 특징:
     * - 상태 변수를 읽거나 쓸 수 없음
     * - 블록체인 정보 (block, msg) 접근 불가
     * - 오직 입력 매개변수만 사용 가능
     * - 상수(constant)는 사용 가능
     * - 같은 입력에 대해 항상 같은 출력 보장
     * - 가스 효율성 최고
     */
    function getPureData(string memory _data) public pure returns (string memory) {
        return _data; // 입력받은 매개변수만 사용
    }
    
    /**
     * @dev 순수한 수학 계산 함수
     * @param _a 첫 번째 숫자
     * @param _b 두 번째 숫자
     * @return sum 덧셈 결과
     * @return product 곱셈 결과
     * @return difference 절댓값 차이
     * @notice 상태에 의존하지 않는 계산 함수
     */
    function calculatePure(uint256 _a, uint256 _b) external pure returns (
        uint256 sum,
        uint256 product,
        uint256 difference
    ) {
        sum = _a + _b; // 순수 계산
        product = _a * _b; // 순수 계산
        difference = _a > _b ? _a - _b : _b - _a; // 조건부 계산
        
        return (sum, product, difference);
    }
    
    /**
     * @dev 문자열 처리 pure 함수
     * @param _input 입력 문자열
     * @param _prefix 접두사
     * @return length 문자열 길이
     * @return combined 접두사가 추가된 문자열
     * @notice 상태와 무관한 문자열 처리
     */
    function processString(string memory _input, string memory _prefix) external pure returns (
        uint256 length,
        string memory combined
    ) {
        length = bytes(_input).length; // 바이트 길이 계산
        combined = string(abi.encodePacked(_prefix, ": ", _input)); // 문자열 연결
        
        return (length, combined);
    }
    
    /**
     * @dev 상수 사용 pure 함수
     * @param _value 입력 값
     * @return isValid 최대값 이하인지 확인
     * @return percentage 최대값 대비 백분율
     * @return contractName 컨트랙트 이름
     * @notice pure 함수에서 상수 사용 가능
     */
    function useConstants(uint256 _value) external pure returns (
        bool isValid,
        uint256 percentage,
        string memory contractName
    ) {
        isValid = _value <= MAX_VALUE; // 상수 사용 가능
        percentage = (_value * 100) / MAX_VALUE; // 상수를 이용한 계산
        contractName = CONTRACT_NAME; // 상수 반환
        
        return (isValid, percentage, contractName);
    }
    
    /**
     * @dev 복잡한 논리 처리 pure 함수
     * @param _numbers 숫자 배열
     * @return sum 배열 합계
     * @return average 평균값
     * @return max 최대값
     * @return min 최소값
     * @notice 배열 처리를 통한 pure 함수 예제
     */
    function analyzeArray(uint256[] memory _numbers) external pure returns (
        uint256 sum,
        uint256 average,
        uint256 max,
        uint256 min
    ) {
        require(_numbers.length > 0, "Array cannot be empty");
        
        sum = 0;
        max = _numbers[0];
        min = _numbers[0];
        
        // 배열 순회 및 계산
        for (uint256 i = 0; i < _numbers.length; i++) {
            sum += _numbers[i];
            
            if (_numbers[i] > max) {
                max = _numbers[i];
            }
            
            if (_numbers[i] < min) {
                min = _numbers[i];
            }
        }
        
        average = sum / _numbers.length;
        
        return (sum, average, max, min);
    }
    
    // ========== 상태 변경 함수들 ==========
    
    /**
     * @dev 데이터 설정 함수 (상태 변경)
     * @param _newData 새로운 데이터 값
     * @notice 상태를 변경하는 일반 함수 예제
     * 
     * 일반 함수 특징:
     * - 상태 변수를 읽고 쓸 수 있음
     * - 이벤트 발생 가능
     * - 항상 가스 소모
     * - 트랜잭션을 통해서만 호출 가능
     */
    function setData(uint8 _newData) external {
        require(_newData != data, "New data must be different");
        
        uint8 oldData = data;
        data = _newData;
        
        emit DataUpdated(oldData, _newData, block.timestamp);
        emit FunctionCalled("setData", block.timestamp);
    }
    
    /**
     * @dev 메시지 설정 함수
     * @param _newMessage 새로운 메시지
     * @notice 문자열 상태 변경 예제
     */
    function setMessage(string memory _newMessage) external {
        require(bytes(_newMessage).length > 0, "Message cannot be empty");
        message = _newMessage;
        emit FunctionCalled("setMessage", block.timestamp);
    }
    
    /**
     * @dev 잔액 설정 함수
     * @param _address 주소
     * @param _amount 금액
     * @notice 매핑 상태 변경 예제
     */
    function setBalance(address _address, uint256 _amount) external {
        require(_address != address(0), "Invalid address");
        balances[_address] = _amount;
        emit FunctionCalled("setBalance", block.timestamp);
    }
    
    /**
     * @dev 배열에 숫자 추가
     * @param _number 추가할 숫자
     * @notice 배열 상태 변경 예제
     */
    function addNumber(uint256 _number) external {
        numbers.push(_number);
        emit FunctionCalled("addNumber", block.timestamp);
    }
    
    // ========== 함수 유형 비교 ==========
    
    /**
     * @dev 함수 유형별 특징 비교 예제
     * @param _input 테스트 입력값
     * @return viewResult view 함수 결과
     * @return pureResult pure 함수 결과
     * @return stateResult 현재 상태 정보
     * @notice 같은 컨트랙트에서 여러 유형의 함수 호출
     */
    function compareFunctionTypes(uint256 _input) external view returns (
        uint8 viewResult,
        uint256 pureResult,
        string memory stateResult
    ) {
        // view 함수 호출: 상태 읽기 가능
        viewResult = getData();
        
        // pure 함수 호출: 계산만 수행
        (pureResult, , ) = this.calculatePure(_input, 10);
        
        // 상태 정보 조합
        stateResult = isInitialized ? "Initialized" : "Not Initialized";
        
        return (viewResult, pureResult, stateResult);
    }
    
    /**
     * @dev 컨트랙트 상태 요약
     * @return dataValue 현재 데이터 값
     * @return messageValue 현재 메시지
     * @return numbersCount 배열 길이
     * @return ownerAddress 소유자 주소
     * @return deployTime 배포 시간
     * @notice 전체 상태를 한 번에 조회하는 view 함수
     */
    function getContractSummary() external view returns (
        uint8 dataValue,
        string memory messageValue,
        uint256 numbersCount,
        address ownerAddress,
        uint256 deployTime
    ) {
        dataValue = data;
        messageValue = message;
        numbersCount = numbers.length;
        ownerAddress = owner; // immutable 변수 읽기
        deployTime = deploymentTime; // immutable 변수 읽기
        
        return (dataValue, messageValue, numbersCount, ownerAddress, deployTime);
    }
    
    /**
     * @dev 함수 수식어 설명 반환
     * @return explanation 각 수식어의 설명
     * @notice 교육용 정보 제공 함수
     */
    function explainModifiers() external pure returns (string memory explanation) {
        explanation = string(abi.encodePacked(
            "view: Can read state, cannot modify. ",
            "pure: Cannot read or modify state. ",
            "payable: Can receive Ether. ",
            "Default: Can read and modify state."
        ));
        
        return explanation;
    }
}