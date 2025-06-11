pragma solidity ^0.8.20;
// SPDX-License-Identifier: MIT

// ===============================================
// DataType Contract - 솔리디티 자료형 종합 예제
// ===============================================
// 
// 📌 솔리디티 자료형 개념:
//   - 정적 타입 언어: 컴파일 시점에 모든 변수의 타입이 결정됨
//   - 값 타입(Value Types): bool, int, uint, address, bytes, string 등
//   - 참조 타입(Reference Types): arrays, structs, mappings
//   - 메모리 위치: storage(영구 저장), memory(임시 저장), calldata(읽기 전용)
//
// 💡 자료형 분류:
//   1. 불린 타입: true/false 값
//   2. 정수 타입: 부호 있는(int), 부호 없는(uint) 정수
//   3. 주소 타입: 이더리움 주소 (20바이트)
//   4. 바이트 타입: 고정/동적 길이 바이트 배열
//   5. 문자열 타입: UTF-8 인코딩 문자열
//
// 🔗 메모리 효율성:
//   - 적절한 크기의 타입 사용으로 가스 절약
//   - 구조체에서 변수 순서에 따른 패킹 최적화
//   - 상수와 불변 변수 활용으로 저장 비용 절감
// ===============================================

/**
 * @title DataType
 * @dev 솔리디티의 모든 기본 자료형을 보여주는 교육용 컨트랙트
 * @notice 각 자료형의 특징, 범위, 활용법을 실제 예제로 학습
 */
contract DataType{

    // ========== 불린 타입 (Boolean Type) ==========
    /**
     * @dev 불린 타입 예제
     * @notice true 또는 false 값만 가질 수 있는 논리 타입
     * 
     * 불린 타입 특징:
     * - 기본값: false
     * - 저장 공간: 1비트 (하지만 EVM에서는 1바이트로 저장)
     * - 논리 연산자: && (AND), || (OR), ! (NOT), == (같음), != (다름)
     * - 조건문과 반복문에서 주로 사용
     * - 스마트 컨트랙트에서 상태 플래그로 활용
     */
    bool public data1 = false;

    // ========== 정수 타입 (Integer Types) ==========
    
    /**
     * @dev 부호 있는 정수 타입 (int)
     * @notice 음수와 양수를 모두 표현할 수 있는 정수 타입
     * 
     * int 타입 특징:
     * - int는 int256과 동일 (256비트)
     * - 범위: -2^255 ~ 2^255-1
     * - 기본값: 0
     * - 음수 표현: 2의 보수법 사용
     * - 사용 예: 잔액 변화량, 점수 차이 등
     */
    int public data2 = -10;
    
    /**
     * @dev 부호 없는 정수 타입 (uint)
     * @notice 0 이상의 양의 정수만 표현하는 타입
     * 
     * uint 타입 특징:
     * - uint는 uint256과 동일 (256비트)
     * - 범위: 0 ~ 2^256-1 (약 1.15×10^77)
     * - 기본값: 0
     * - 언더플로우 주의: 0에서 1을 빼면 매우 큰 양수가 됨
     * - 사용 예: 토큰 양, 시간(timestamp), 개수 등
     */
    uint public data3 = 10;
    
    /**
     * @dev 256비트 부호 없는 정수 (명시적 크기 지정)
     * @notice 가장 큰 범위의 부호 없는 정수 타입
     * 
     * uint256 활용:
     * - 이더량 표현 (wei 단위, 1 ETH = 10^18 wei)
     * - 토큰 총 공급량
     * - 해시값 저장
     * - 큰 수의 계산
     */
    uint256 public data4 = 10000000000; // 0~2^256-1 
    
    /**
     * @dev 256비트 부호 있는 정수 (명시적 크기 지정)
     * @notice 가장 큰 범위의 부호 있는 정수 타입
     * 
     * int256 활용:
     * - 손익 계산 (음수/양수 구분)
     * - 온도나 고도 등 음수 가능한 값
     * - 수학적 계산 결과
     */
    int256 public data5 = -10000000000; // -2^255~2^255-1

    // ========== 정수 타입 (Integer Types) ==========
    
    /**
     * @dev 8비트 부호 없는 정수
     * @notice 메모리 효율적인 작은 정수 타입
     * 
     * uint8 특징:
     * - 범위: 0 ~ 255 (2^8-1)
     * - 저장 공간: 1바이트
     * - 가스 효율성: 작은 값에 적합
     * - 사용 예: 백분율, 등급, 작은 개수
     * - 오버플로우 주의: 255 + 1 = 0
     */
    uint8 public data6 =100; //  0 ~ 2^256 - 1 
    
    /**
     * @dev 8비트 부호 있는 정수
     * @notice 작은 범위의 음수/양수 표현
     * 
     * int8 특징:
     * - 범위: -128 ~ 127
     * - 저장 공간: 1바이트
     * - 사용 예: 온도, 작은 증감값, 레벨 차이
     */
    int8 public data7 = -100;  

    // ========== 문자열 타입 (String Type) ==========
    
    /**
     * @dev 동적 길이 문자열 타입
     * @notice UTF-8 인코딩을 지원하는 가변 길이 문자열
     * 
     * string 타입 특징:
     * - 동적 크기 배열로 구현됨
     * - UTF-8 인코딩 지원 (한글, 이모지 등)
     * - 길이 제한 없음 (가스 비용은 증가)
     * - 바이트 단위 접근 불가 (bytes로 변환 필요)
     * - 문자열 비교 시 keccak256 해시 사용
     * - 사용 예: 이름, 설명, 메타데이터
     */
    string public data8 = "fastcampus";
    
    // ========== 바이트 타입 (Bytes Types) ==========
    
    /**
     * @dev 동적 길이 바이트 배열
     * @notice 임의의 바이너리 데이터를 저장하는 타입
     * 
     * bytes 타입 특징:
     * - 동적 크기 바이트 배열
     * - 바이트 단위 접근 가능 (인덱싱)
     * - 문자열보다 가스 효율적
     * - 암호화 데이터, 시그니처 등에 사용
     * - push(), pop() 메서드 지원
     */
    bytes public data9 = "fastcampus";
    
    /**
     * @dev 20바이트 고정 길이 바이트 배열
     * @notice 이더리움 주소와 같은 크기의 고정 바이트 배열
     * 
     * bytes20 특징:
     * - 고정 크기: 정확히 20바이트
     * - 이더리움 주소와 호환 (address ↔ bytes20 변환 가능)
     * - 저장 효율성: 동적 배열보다 가스 절약
     * - 사용 예: 주소 저장, 해시 일부, 고정 ID
     */
    bytes20 public data = bytes20(0); //address
    
    /**
     * @dev 32바이트 고정 길이 바이트 배열
     * @notice 해시값과 같은 크기의 고정 바이트 배열
     * 
     * bytes32 특징:
     * - 고정 크기: 정확히 32바이트
     * - keccak256, sha256 해시 결과와 동일 크기
     * - 가장 효율적인 저장 단위 (EVM 워드 크기)
     * - 사용 예: 해시값, 키, 고유 식별자, 머클 트리 노드
     */
    bytes32 public data10 = bytes32(0); //hash

    // ========== 주소 타입 (Address Types) ==========
    
    /**
     * @dev 기본 주소 타입
     * @notice 이더리움 주소를 저장하는 20바이트 타입
     * 
     * address 타입 특징:
     * - 크기: 20바이트 (160비트)
     * - 기본값: 0x0000000000000000000000000000000000000000
     * - EOA(외부 소유 계정) 또는 컨트랙트 주소 저장
     * - balance 속성: 해당 주소의 이더 잔액 조회
     * - code 속성: 컨트랙트 코드 존재 여부 확인
     * - 이더 전송 불가 (payable 변환 필요)
     */
    address public data11 = address(0);
    
    /**
     * @dev 실제 주소 예제
     * @notice 실제 이더리움 주소를 저장하는 예제
     * 
     * 주소 형식:
     * - 16진수 42자리 (0x + 40자리)
     * - 체크섬 적용 가능 (대소문자 구분)
     * - 주소 유효성 검증 권장
     */
    address public data12 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    
    // ========== 추가 예제 변수들 ==========
    
    /**
     * @dev payable 주소 타입 예제
     * @notice 이더를 받을 수 있는 주소 타입
     * 
     * address payable 특징:
     * - 이더 전송 가능: transfer(), send(), call{value: ...}()
     * - address에서 payable로 명시적 변환 필요
     * - 컨트랙트 주소의 경우 receive/fallback 함수 필요
     */
    address payable public payableAddress;
    
    /**
     * @dev 고정 배열 예제
     * @notice 고정 크기 배열의 메모리 효율성 시연
     */
    uint8[3] public fixedArray = [1, 2, 3]; // 3개 요소 고정
    
    /**
     * @dev 열거형 예제
     * @notice 상태나 옵션을 표현하는 사용자 정의 타입
     */
    enum Status { Pending, Active, Inactive, Completed }
    Status public currentStatus = Status.Pending;
    
    // ========== 상수 및 불변 변수 ==========
    
    /**
     * @dev 컴파일 타임 상수
     * @notice 배포 전에 값이 결정되는 상수
     * 
     * constant 특징:
     * - 컴파일 시점에 바이트코드에 직접 삽입
     * - 저장 슬롯 사용 안 함 (가스 절약)
     * - 반드시 선언 시점에 초기화
     */
    uint256 public constant MAX_SUPPLY = 1000000 * 10**18; // 100만 토큰
    string public constant CONTRACT_NAME = "DataType Demo";
    
    /**
     * @dev 런타임 불변 변수
     * @notice 생성자에서 한 번만 설정 가능한 변수
     * 
     * immutable 특징:
     * - 생성자에서만 설정 가능
     * - 배포 후 변경 불가
     * - constant보다 유연함 (생성자 매개변수 사용 가능)
     */
    address public immutable deployer;
    uint256 public immutable deploymentTime;
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 불변 변수 초기화 및 payable 주소 설정
     */
    constructor() {
        deployer = msg.sender; // 배포자 주소 저장
        deploymentTime = block.timestamp; // 배포 시간 저장
        payableAddress = payable(msg.sender); // payable 주소 설정
    }
    
    // ========== 유틸리티 함수들 ==========
    
    /**
     * @dev 자료형 크기 정보 반환
     * @return boolSize 불린 타입의 비트 크기
     * @return uint8Size uint8 타입의 비트 크기
     * @return uint256Size uint256 타입의 비트 크기
     * @return addressSize address 타입의 비트 크기
     * @return bytes32Size bytes32 타입의 비트 크기
     * @notice 교육 목적의 자료형 크기 확인 함수
     */
    function getTypeSizes() external pure returns (
        uint8 boolSize,
        uint16 uint8Size,
        uint16 uint256Size,
        uint16 addressSize,
        uint16 bytes32Size
    ) {
        // 비트 단위 크기 반환
        return (1, 8, 256, 160, 256);
    }
    
    /**
     * @dev 정수 타입 범위 정보
     * @return uint8Max uint8 타입의 최대값
     * @return int8Min int8 타입의 최소값
     * @return int8Max int8 타입의 최대값
     * @return uint256Max uint256 타입의 최대값
     */
    function getIntegerRanges() external pure returns (
        uint8 uint8Max,
        int8 int8Min,
        int8 int8Max,
        uint256 uint256Max
    ) {
        return (
            type(uint8).max,    // 255
            type(int8).min,     // -128
            type(int8).max,     // 127
            type(uint256).max   // 2^256 - 1
        );
    }
    
    /**
     * @dev 주소 유효성 검사
     * @param _addr 검사할 주소
     * @return isValid 유효한 주소인지 여부
     * @return isContract 컨트랙트 주소인지 여부
     */
    function validateAddress(address _addr) external view returns (bool isValid, bool isContract) {
        isValid = _addr != address(0); // 영주소가 아닌지 확인
        
        // 컨트랙트 주소 확인 (코드 크기 > 0)
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        isContract = codeSize > 0;
    }
    
    /**
     * @dev 문자열과 바이트 변환 예제
     * @param _str 변환할 문자열
     * @return bytesData 바이트로 변환된 데이터
     * @return length 바이트 길이
     */
    function stringToBytes(string memory _str) external pure returns (bytes memory bytesData, uint256 length) {
        bytesData = bytes(_str);
        length = bytesData.length;
    }
    
    /**
     * @dev 타입 변환 예제 함수
     * @param _value 변환할 값
     * @return toUint8 uint8로 변환된 값
     * @return toInt256 int256으로 변환된 값
     * @return toBytes32 bytes32로 변환된 값
     * @return toAddress address로 변환된 값
     */
    function typeConversions(uint256 _value) external pure returns (
        uint8 toUint8,
        int256 toInt256,
        bytes32 toBytes32,
        address toAddress
    ) {
        // 명시적 타입 변환 (값 손실 주의)
        toUint8 = uint8(_value);           // 하위 8비트만 유지
        toInt256 = int256(_value);         // 부호 있는 정수로 변환
        toBytes32 = bytes32(_value);       // 32바이트로 변환
        toAddress = address(uint160(_value)); // 하위 160비트로 주소 생성
    }
    
    /**
     * @dev 배열 조작 예제
     * @notice 동적 배열의 기본 조작 방법들
     */
    function arrayOperations() external pure returns (uint[] memory result) {
        // 메모리에서 동적 배열 생성
        result = new uint[](3);
        result[0] = 10;
        result[1] = 20;
        result[2] = 30;
        
        // 배열 길이: result.length
        // 배열 요소 접근: result[index]
        
        return result;
    }
    
    /**
     * @dev 현재 컨트랙트 상태 요약
     * @return bool_value 불린 데이터 값
     * @return int_value 정수 데이터 값
     * @return uint_value 부호 없는 정수 값
     * @return string_value 문자열 데이터 값
     * @return deployer_address 배포자 주소
     * @return deployment_time 배포 시간
     * @return status 현재 상태
     */
    function getContractState() external view returns (
        bool bool_value,
        int int_value,
        uint uint_value,
        string memory string_value,
        address deployer_address,
        uint256 deployment_time,
        Status status
    ) {
        return (
            data1,
            data2,
            data3,
            data8,
            deployer,
            deploymentTime,
            currentStatus
        );
    }
}