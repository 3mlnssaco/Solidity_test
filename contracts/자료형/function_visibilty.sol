// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// ===============================================
// Function Visibility Contract - 함수 가시성 예제
// ===============================================
// 
// 📌 함수 가시성(Function Visibility) 개념:
//   - 함수에 접근할 수 있는 범위를 제한하는 메커니즘
//   - 보안성, 캡슐화, 가스 최적화에 직접적인 영향
//   - 컨트랙트 설계의 핵심 요소
//   - 상속과 인터페이스 설계에 중요한 역할
//
// 💡 가시성 수식어 종류:
//   1. public: 모든 곳에서 접근 가능 (내부, 외부, 상속)
//   2. external: 외부에서만 접근 가능 (내부 호출 시 this 필요)
//   3. internal: 내부와 상속된 컨트랙트에서만 접근 가능
//   4. private: 현재 컨트랙트 내부에서만 접근 가능
//
// 🔗 가시성별 특징:
//   - public: 자동 getter 생성(상태변수), 다양한 호출 방식 지원
//   - external: 가스 효율적, calldata 사용 가능
//   - internal: 상속 지원, 내부 로직 구현에 적합
//   - private: 최고 보안성, 완전한 캡슐화
// ===============================================

/**
 * @title FunctionVisibility
 * @dev 솔리디티 함수 가시성 수식어의 차이점과 활용법을 보여주는 컨트랙트
 * @notice 각 가시성 수식어의 접근 범위와 특징을 실제 예제로 시연
 */
contract FunctionVisibility {
    
    // ========== 상태 변수 (가시성별 예제) ==========
    
    /**
     * @dev private 상태 변수
     * @notice 가장 제한적인 접근 범위
     * 
     * private 특징:
     * - 같은 컨트랙트 내부에서만 접근 가능
     * - 상속받은 컨트랙트에서도 접근 불가
     * - getter 함수 자동 생성 안됨
     * - 가장 안전한 데이터 보호
     */
    uint8 private data = 255;
    
    /**
     * @dev internal 상태 변수
     * @notice 상속을 고려한 제한적 접근
     */
    uint8 internal data2 = 255;
    
    /**
     * @dev public 상태 변수 (자동 getter 생성)
     * @notice 가장 개방적인 접근, 자동 getter 함수 생성
     */
    uint8 public data3 = 255;
    
    /**
     * @dev external 함수 전용 상태 변수
     * @notice external 함수의 특징 시연을 위한 변수
     */
    uint8 public data4 = 255;
    
    /**
     * @dev 함수 호출 기록을 위한 구조체
     */
    struct CallRecord {
        string functionName;
        string visibility;
        address caller;
        uint256 timestamp;
        uint256 gasUsed;
    }
    
    /**
     * @dev 함수 호출 기록 배열
     */
    CallRecord[] private callRecords;
    
    /**
     * @dev 사용자별 호출 횟수 추적
     */
    mapping(address => uint256) private userCallCounts;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 함수 호출 시 발생하는 이벤트
     */
    event FunctionCalled(
        string indexed functionName,
        string visibility,
        address indexed caller,
        uint256 timestamp
    );
    
    /**
     * @dev 데이터 변경 시 발생하는 이벤트
     */
    event DataUpdated(
        string dataName,
        uint8 oldValue,
        uint8 newValue,
        address indexed updater
    );
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 초기 상태 설정 및 로깅
     */
    constructor() {
        // 생성자 호출 기록
        _recordCall("constructor", "internal", 0);
        userCallCounts[msg.sender] = 1;
    }
    
    // ========== PRIVATE 함수들 ==========
    
    /**
     * @dev private 데이터 설정 함수 (원본 주석 반영)
     * @param _data 설정할 새로운 데이터 값
     * @notice private: 외부에서 접근 불가, 상속된 자식에서도 접근 불가, 내부에서만 접근 가능
     * 
     * private 함수 특징:
     * - 가장 제한적인 접근 범위
     * - 같은 컨트랙트 내부에서만 호출 가능
     * - 상속받은 컨트랙트에서 접근 불가
     * - 외부 호출 완전 차단
     * - 내부 로직 구현에 주로 사용
     * - 가스 효율성 높음 (함수 시그니처 불필요)
     */
    function setData(uint8 _data) private {
        require(_data != data, "New data must be different");
        
        uint8 oldData = data;
        data = _data;
        
        _recordCall("setData", "private", uint256(_data));
        emit DataUpdated("data (private)", oldData, _data, msg.sender);
    }
    
    /**
     * @dev private 데이터 조회 함수
     * @return uint8 현재 private 데이터 값
     * @notice private 데이터에 접근하는 내부 함수
     */
    function _getPrivateData() private view returns (uint8) {
        return data;
    }
    
    /**
     * @dev 복잡한 내부 계산을 수행하는 private 함수
     * @param _input 계산 입력값
     * @return result 계산 결과
     * @notice 내부 로직을 캡슐화하는 private 함수 예제
     */
    function _complexCalculation(uint256 _input) private pure returns (uint256 result) {
        // 복잡한 계산 로직 (예: 해시, 암호화 등)
        result = (_input * 17 + 42) % 1000;
        return result;
    }
    
    // ========== INTERNAL 함수들 ==========
    
    /**
     * @dev internal 데이터 설정 함수 (원본 주석 반영)
     * @param _data 설정할 새로운 데이터 값
     * @notice internal: 외부에서 접근 불가, 상속된 자식에서 접근 가능, 내부에서 접근 가능
     * 
     * internal 함수 특징:
     * - 현재 컨트랙트와 상속받은 컨트랙트에서 접근 가능
     * - 외부에서 직접 호출 불가
     * - 상속 구조에서 중요한 역할
     * - 라이브러리 함수와 유사한 활용
     * - 코드 재사용성 높음
     */
    function setData2(uint8 _data) internal {
        require(_data != data2, "New data must be different");
        require(_data <= 255, "Data must be within uint8 range");
        
        uint8 oldData = data2;
        data2 = _data;
        
        _recordCall("setData2", "internal", uint256(_data));
        emit DataUpdated("data2 (internal)", oldData, _data, msg.sender);
    }
    
    /**
     * @dev internal 데이터 조회 함수
     * @return uint8 현재 internal 데이터 값
     * @notice 상속된 컨트랙트에서도 사용 가능한 함수
     */
    function _getInternalData() internal view returns (uint8) {
        return data2;
    }
    
    /**
     * @dev 입력값 검증을 위한 internal 함수
     * @param _value 검증할 값
     * @return bool 유효성 여부
     * @notice 상속받은 컨트랙트에서 공통으로 사용할 수 있는 검증 로직
     */
    function _isValidInput(uint256 _value) internal pure returns (bool) {
        return _value > 0 && _value <= 10000;
    }
    
    /**
     * @dev 권한 확인을 위한 internal 함수
     * @param _user 확인할 사용자 주소
     * @return bool 권한 여부
     * @notice 상속 구조에서 공통 권한 로직
     */
    function _hasPermission(address _user) internal view returns (bool) {
        return userCallCounts[_user] > 0; // 한 번 이상 호출한 사용자
    }
    
    // ========== PUBLIC 함수들 ==========
    
    /**
     * @dev public 데이터 설정 함수 (원본 주석 반영)  
     * @param _data 설정할 새로운 데이터 값
     * @notice public: 외부에서 접근 가능, 상속된 자식에서 접근 가능, 내부에서 접근 가능
     * 
     * public 함수 특징:
     * - 가장 개방적인 접근 범위
     * - 내부, 외부, 상속된 컨트랙트 모든 곳에서 호출 가능
     * - 트랜잭션과 로컬 호출 모두 지원
     * - 함수 시그니처가 ABI에 포함됨
     * - 다양한 호출 방식 지원 (직접 호출, this 호출 등)
     */
    function setData3(uint8 _data) public {
        require(_data != data3, "New data must be different");
        require(_data <= 255, "Data must be within uint8 range");
        
        uint8 oldData = data3;
        data3 = _data;
        
        // internal 함수 호출 예제
        if (_isValidInput(uint256(_data))) {
            _recordCall("setData3", "public", uint256(_data));
        }
        
        // private 함수 호출 예제 (같은 컨트랙트 내부에서만 가능)
        uint256 calculation = _complexCalculation(uint256(_data));
        
        emit DataUpdated("data3 (public)", oldData, _data, msg.sender);
        emit FunctionCalled("setData3", "public", msg.sender, block.timestamp);
    }
    
    /**
     * @dev 모든 데이터를 한 번에 설정하는 public 함수
     * @param _value1 private 데이터용 값
     * @param _value2 internal 데이터용 값
     * @param _value3 public 데이터용 값
     * @notice 다양한 가시성 함수들을 내부에서 호출하는 예제
     */
    function setAllData(uint8 _value1, uint8 _value2, uint8 _value3) public {
        // private 함수 호출 (같은 컨트랙트 내부에서만 가능)
        setData(_value1);
        
        // internal 함수 호출 (현재 컨트랙트와 상속에서 가능)
        setData2(_value2);
        
        // public 함수 호출 (어디서든 가능)
        setData3(_value3);
        
        _recordCall("setAllData", "public", 0);
        userCallCounts[msg.sender]++;
    }
    
    /**
     * @dev 모든 데이터 조회를 위한 public 함수
     * @return privateData private 데이터 값
     * @return internalData internal 데이터 값  
     * @return publicData public 데이터 값
     * @notice 다양한 가시성의 데이터를 한 번에 조회
     */
    function getAllData() public view returns (
        uint8 privateData,
        uint8 internalData,
        uint8 publicData
    ) {
        privateData = _getPrivateData(); // private 함수 호출
        internalData = _getInternalData(); // internal 함수 호출
        publicData = data3; // public 변수 직접 접근
        
        return (privateData, internalData, publicData);
    }
    
    // ========== EXTERNAL 함수들 ==========
    
    /**
     * @dev external 데이터 설정 함수 (원본 주석 반영)
     * @param _data 설정할 새로운 데이터 값
     * @notice external: 외부에서 접근 가능, 상속된 자식에서 접근 불가, 내부에서 접근 불가
     * 
     * external 함수 특징:
     * - 외부에서만 호출 가능 (트랜잭션 또는 다른 컨트랙트)
     * - 내부에서 직접 호출 불가 (this.함수명() 으로만 가능)
     * - calldata 사용으로 가스 효율적
     * - 인터페이스 정의에 주로 사용
     * - 대용량 데이터 처리에 유리
     */
    function setData4(uint8 _data) external {
        require(_data != data4, "New data must be different");
        require(_data <= 255, "Data must be within uint8 range");
        
        uint8 oldData = data4;
        data4 = _data;
        
        _recordCall("setData4", "external", uint256(_data));
        userCallCounts[msg.sender]++;
        
        emit DataUpdated("data4 (external)", oldData, _data, msg.sender);
        emit FunctionCalled("setData4", "external", msg.sender, block.timestamp);
    }
    
    /**
     * @dev 대용량 배열 처리를 위한 external 함수
     * @param _numbers 처리할 숫자 배열 (calldata 사용)
     * @return sum 배열 합계
     * @return average 평균값
     * @notice calldata 사용으로 가스 효율성을 보여주는 예제
     */
    function processLargeArray(uint256[] calldata _numbers) 
        external 
        pure 
        returns (uint256 sum, uint256 average) 
    {
        require(_numbers.length > 0, "Array cannot be empty");
        
        sum = 0;
        for (uint256 i = 0; i < _numbers.length; i++) {
            sum += _numbers[i];
        }
        
        average = sum / _numbers.length;
        return (sum, average);
    }
    
    /**
     * @dev 복잡한 문자열 처리를 위한 external 함수
     * @param _data 처리할 문자열 데이터 (calldata 사용)
     * @return length 문자열 길이
     * @return hash 문자열 해시값
     * @notice 대용량 문자열 처리의 가스 효율성 시연
     */
    function processStringData(string calldata _data) 
        external 
        pure 
        returns (uint256 length, bytes32 hash) 
    {
        length = bytes(_data).length;
        hash = keccak256(bytes(_data));
        return (length, hash);
    }
    
    /**
     * @dev 외부 호출 전용 인터페이스 함수
     * @param _user 조회할 사용자
     * @return callCount 해당 사용자의 호출 횟수
     * @return hasPermission 권한 보유 여부
     * @return lastCallTime 마지막 호출 시간 (추정)
     * @notice 외부 시스템과의 인터페이스 역할
     */
    function getUserStats(address _user) 
        external 
        view 
        returns (uint256 callCount, bool hasPermission, uint256 lastCallTime) 
    {
        callCount = userCallCounts[_user];
        hasPermission = _hasPermission(_user); // internal 함수 호출 가능
        lastCallTime = callRecords.length > 0 ? callRecords[callRecords.length - 1].timestamp : 0;
        
        return (callCount, hasPermission, lastCallTime);
    }
    
    // ========== 가시성 비교 및 테스트 함수들 ==========
    
    /**
     * @dev 내부에서 다양한 함수 호출을 시도하는 테스트 함수
     * @param _testValue 테스트용 값
     * @return results 각 호출의 성공 여부와 결과
     * @notice 함수 가시성의 차이점을 실제로 보여주는 테스트
     */
    function testVisibilityFromInside(uint8 _testValue) public returns (string memory results) {
        // 1. private 함수 호출 - 성공
        setData(_testValue);
        
        // 2. internal 함수 호출 - 성공  
        setData2(_testValue);
        
        // 3. public 함수 호출 - 성공
        setData3(_testValue);
        
        // 4. external 함수 호출 - 내부에서 직접 호출 불가
        // setData4(_testValue); // 컴파일 에러!
        
        // 5. external 함수를 this를 통해 호출 - 성공 (외부 호출)
        this.setData4(_testValue);
        
        results = "private: OK, internal: OK, public: OK, external: OK (with this)";
        _recordCall("testVisibilityFromInside", "public", uint256(_testValue));
        
        return results;
    }
    
    /**
     * @dev 가시성별 접근 가능 범위 정보 제공
     * @return info 각 가시성 수식어의 접근 범위 설명
     * @notice 교육용 정보 제공 함수
     */
    function getVisibilityInfo() external pure returns (string memory info) {
        info = string(abi.encodePacked(
            "private: Current contract only. ",
            "internal: Current + inherited contracts. ",
            "public: All (internal + external + inherited). ",
            "external: External calls only (use 'this' for internal calls)."
        ));
        
        return info;
    }
    
    /**
     * @dev 가스 효율성 비교를 위한 함수들
     * @param _data 테스트 데이터
     * @return gasEstimate 예상 가스 사용량 정보
     * @notice 각 가시성별 가스 사용량 특징 설명
     */
    function compareGasEfficiency(bytes calldata _data) 
        external 
        pure 
        returns (string memory gasEstimate) 
    {
        // calldata 사용 (external 함수의 장점)
        uint256 dataLength = _data.length;
        
        gasEstimate = string(abi.encodePacked(
            "external with calldata: Most efficient for large data. ",
            "Data length: ", 
            _uint2str(dataLength),
            " bytes. ",
            "public with memory: Higher gas cost. ",
            "private/internal: No external call overhead."
        ));
        
        return gasEstimate;
    }
    
    // ========== 내부 유틸리티 함수들 ==========
    
    /**
     * @dev 함수 호출을 기록하는 private 함수
     * @param _functionName 호출된 함수명
     * @param _visibility 가시성 타입
     * @param _gasUsed 사용된 가스 (간단한 예제용)
     * @notice 호출 기록 관리를 위한 내부 함수
     */
    function _recordCall(
        string memory _functionName, 
        string memory _visibility, 
        uint256 _gasUsed
    ) private {
        callRecords.push(CallRecord({
            functionName: _functionName,
            visibility: _visibility,
            caller: msg.sender,
            timestamp: block.timestamp,
            gasUsed: _gasUsed
        }));
    }
    
    /**
     * @dev 숫자를 문자열로 변환하는 내부 함수
     * @param _i 변환할 숫자
     * @return str 문자열 결과
     * @notice 유틸리티 함수 예제
     */
    function _uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(j - j / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            j /= 10;
        }
        
        str = string(bstr);
        return str;
    }
    
    // ========== 조회 함수들 ==========
    
    /**
     * @dev 모든 호출 기록 조회
     * @return CallRecord[] 전체 호출 기록
     * @notice 함수 사용 통계 조회
     */
    function getCallRecords() external view returns (CallRecord[] memory) {
        return callRecords;
    }
    
    /**
     * @dev 특정 사용자의 호출 횟수 조회  
     * @param _user 조회할 사용자 주소
     * @return uint256 해당 사용자의 총 호출 횟수
     * @notice 사용자별 활동 통계
     */
    function getUserCallCount(address _user) external view returns (uint256) {
        return userCallCounts[_user];
    }
    
    /**
     * @dev 컨트랙트 전체 상태 요약
     * @return summary 각 데이터와 통계 정보
     * @notice 전체 상태를 한 번에 확인하는 함수
     */
    function getContractSummary() external view returns (string memory summary) {
        summary = string(abi.encodePacked(
            "Private data: ", _uint2str(data), ", ",
            "Internal data: ", _uint2str(data2), ", ",
            "Public data: ", _uint2str(data3), ", ",
            "External data: ", _uint2str(data4), ", ",
            "Total calls: ", _uint2str(callRecords.length)
        ));
        
        return summary;
    }
}

