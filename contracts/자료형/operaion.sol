// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ===============================================
// Operation Contract - 솔리디티 연산자 종합 예제
// ===============================================
// 
// 📌 연산자(Operators) 개념:
//   - 솔리디티에서 데이터를 조작하고 계산하는 기본 도구
//   - 산술, 논리, 비교, 비트, 할당 연산자로 분류
//   - 가스 효율성과 오버플로우/언더플로우 고려 필요
//   - Solidity 0.8.0+ 에서 자동 오버플로우 검사 제공
//
// 💡 연산자 종류:
//   1. 산술 연산자: +, -, *, /, %, **, ++, --
//   2. 논리 연산자: &&, ||, !, ==, !=, <, >, <=, >=
//   3. 비트 연산자: &, |, ^, ~, <<, >>
//   4. 할당 연산자: =, +=, -=, *=, /=, %=
//   5. 삼항 연산자: condition ? true_value : false_value
//
// 🔗 실용적 활용:
//   - 토큰 계산: 전송량, 수수료 계산
//   - 시간 계산: 만료일, 기간 검증
//   - 권한 검증: 다중 조건 확인
//   - 가격 계산: 할인, 세금, 환율 적용
// ===============================================

/**
 * @title Operation
 * @dev 솔리디티의 모든 연산자 유형을 보여주는 교육용 컨트랙트
 * @notice 산술, 논리, 비트 연산과 안전한 계산 방법을 시연
 */
contract Operation {
    
    // ========== 상태 변수 ==========
    
    /**
     * @dev 산술 연산 테스트용 정수
     * @notice 다양한 산술 연산의 결과를 저장
     */
    uint public intData;
    
    /**
     * @dev 문자열 연산 테스트용 변수
     * @notice 문자열 연결과 비교 연산 시연
     */
    string public stringData;
    
    /**
     * @dev 오버플로우 테스트용 작은 정수
     * @notice uint8 범위에서의 오버플로우 시연
     */
    uint8 public smallInt = 255; // 최대값
    
    /**
     * @dev 연산 기록을 위한 구조체
     */
    struct CalculationRecord {
        uint256 operand1;
        uint256 operand2;
        uint256 result;
        string operation;
        uint256 timestamp;
    }
    
    /**
     * @dev 모든 계산 기록을 저장하는 배열
     */
    CalculationRecord[] public calculationHistory;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 연산 수행 시 발생하는 이벤트
     */
    event OperationPerformed(
        string indexed operationType,
        uint256 operand1,
        uint256 operand2,
        uint256 result,
        uint256 timestamp
    );
    
    /**
     * @dev 논리 연산 결과 이벤트
     */
    event LogicalResult(
        bool result,
        string operation,
        uint256 timestamp
    );
    
    // ========== 산술 연산 함수들 ==========
    
    /**
     * @dev 기본 산술 연산들을 수행하는 함수
     * @notice 덧셈, 뺄셈, 곱셈, 나눗셈, 나머지 연산과 할당 연산자 시연
     * 
     * 산술 연산 특징:
     * - Solidity 0.8.0+ 자동 오버플로우/언더플로우 검사
     * - 0으로 나누기 시 자동 revert
     * - 정수 나눗셈은 소수점 이하 버림
     * - 할당 연산자로 코드 간소화 가능
     */
    function math() public {
        uint256 initialValue = intData;
        
        // ========== 덧셈 연산 ==========
        intData = intData + 1; // 기본 덧셈
        _recordCalculation(initialValue, 1, intData, "addition");
        
        intData += 1; // 할당 덧셈 (더 효율적)
        _recordCalculation(intData - 1, 1, intData, "compound_add");
        
        // ========== 뺄셈 연산 ==========
        intData = intData - 1; // 기본 뺄셈
        _recordCalculation(intData + 1, 1, intData, "subtraction");
        
        intData -= 1; // 할당 뺄셈
        _recordCalculation(intData + 1, 1, intData, "compound_subtract");
        
        // ========== 곱셈 연산 ==========
        intData = intData * 2; // 기본 곱셈
        _recordCalculation(intData / 2, 2, intData, "multiplication");
        
        intData *= 2; // 할당 곱셈
        _recordCalculation(intData / 2, 2, intData, "compound_multiply");
        
        // ========== 나눗셈 연산 ==========
        intData = intData / 2; // 기본 나눗셈 (정수 나눗셈, 소수점 버림)
        _recordCalculation(intData * 2, 2, intData, "division");
        
        intData /= 2; // 할당 나눗셈
        _recordCalculation(intData * 2, 2, intData, "compound_divide");
        
        // ========== 나머지 연산 ==========
        intData = intData % 2; // 나머지 연산 (모듈로)
        _recordCalculation(intData, 2, intData % 2, "modulo");
        
        intData %= 2; // 할당 나머지
        _recordCalculation(intData, 2, intData, "compound_modulo");
        
        emit OperationPerformed("math_operations", initialValue, 0, intData, block.timestamp);
    }
    
    /**
     * @dev 고급 산술 연산들
     * @param _a 첫 번째 피연산자
     * @param _b 두 번째 피연산자
     * @return sum 덧셈 결과
     * @return difference 뺄셈 결과 (절댓값)
     * @return product 곱셈 결과
     * @return quotient 나눗셈 결과
     * @return remainder 나머지 결과
     * @return power 거듭제곱 결과
     */
    function advancedMath(uint256 _a, uint256 _b) external pure returns (
        uint256 sum,
        uint256 difference,
        uint256 product,
        uint256 quotient,
        uint256 remainder,
        uint256 power
    ) {
        require(_b != 0, "Division by zero"); // 0으로 나누기 방지
        
        sum = _a + _b;
        difference = _a > _b ? _a - _b : _b - _a; // 절댓값 차이
        product = _a * _b;
        quotient = _a / _b;
        remainder = _a % _b;
        power = _a ** 2; // 거듭제곱 (가스 비용 주의)
        
        return (sum, difference, product, quotient, remainder, power);
    }
    
    /**
     * @dev 증감 연산자 사용 예제
     * @notice ++, -- 연산자의 전위/후위 차이점 시연
     */
    function incrementDecrement() external {
        uint256 value = 10;
        
        // 전위 증가: 값을 먼저 증가시킨 후 반환
        uint256 preIncrement = ++value; // value = 11, preIncrement = 11
        
        // 후위 증가: 현재 값을 반환한 후 증가
        uint256 postIncrement = value++; // postIncrement = 11, value = 12
        
        // 전위 감소: 값을 먼저 감소시킨 후 반환
        uint256 preDecrement = --value; // value = 11, preDecrement = 11
        
        // 후위 감소: 현재 값을 반환한 후 감소
        uint256 postDecrement = value--; // postDecrement = 11, value = 10
        
        intData = value; // 최종 결과 저장
        
        emit OperationPerformed("increment_decrement", preIncrement, postDecrement, value, block.timestamp);
    }
    
    // ========== 이더 단위 변환 ==========
    
    /**
     * @dev wei를 이더로 변환하는 함수
     * @return ethValue ETH 단위로 변환된 값
     * @notice 이더리움 단위 변환과 정밀도 처리 예제
     * 
     * 이더리움 단위:
     * - 1 wei = 1 (가장 작은 단위)
     * - 1 gwei = 10^9 wei (가스 가격 단위)
     * - 1 ether = 10^18 wei (기본 화폐 단위)
     * - 1 finney = 10^15 wei
     * - 1 szabo = 10^12 wei
     */
    function weiToEth() public pure returns (uint256 ethValue) {
        uint256 wei_data = 1 wei; // 1 wei
        
        // 1 wei = 10^-18 ETH이므로, 1 ETH = 10^18 wei
        // wei를 ETH로 변환: wei_amount / 10^18
        ethValue = wei_data / (10**18); // 결과: 0 (정수 나눗셈으로 인한 소수점 버림)
        
        return ethValue;
    }
    
    /**
     * @dev 다양한 이더 단위 변환 예제
     * @param _weiAmount wei 단위 입력값
     * @return inGwei gwei 단위 변환 결과
     * @return inEther ether 단위 변환 결과
     * @return remainderWei 변환 후 나머지 wei
     */
    function convertEtherUnits(uint256 _weiAmount) external pure returns (
        uint256 inGwei,
        uint256 inEther,
        uint256 remainderWei
    ) {
        // gwei 변환 (10^9 wei = 1 gwei)
        inGwei = _weiAmount / 1e9;
        
        // ether 변환 (10^18 wei = 1 ether)
        inEther = _weiAmount / 1e18;
        
        // ether 변환 후 남은 wei
        remainderWei = _weiAmount % 1e18;
        
        return (inGwei, inEther, remainderWei);
    }
    
    // ========== 논리 연산 함수들 ==========
    
    /**
     * @dev 논리 연산들을 수행하는 함수
     * @return andResult AND 연산 결과
     * @return orResult OR 연산 결과
     * @return equalResult 동등 비교 결과
     * @return notEqualResult 부등 비교 결과
     * @notice 불린 값들의 논리 연산과 조건문 사용법 시연
     * 
     * 논리 연산자 특징:
     * - && (AND): 모든 조건이 true일 때만 true
     * - || (OR): 하나 이상의 조건이 true이면 true
     * - ! (NOT): 논리값 반전
     * - == (Equal): 값이 같으면 true
     * - != (Not Equal): 값이 다르면 true
     * - 단축 평가(Short-circuit): && 앞이 false면 뒤 평가 안 함
     */
    function logical() public pure returns (bool andResult, bool orResult, bool equalResult, bool notEqualResult) {
        bool true_data = true;
        bool false_data = false;
        
        // ========== 조건문 기본 구조 ==========
        if (true_data) {
            // true인 경우 실행되는 블록
            // 실제 로직 구현 위치
        } else {
            // false인 경우 실행되는 블록
            // 대안 로직 구현 위치
        }
        
        // ========== 논리 연산 예제 ==========
        
        // AND 연산: 두 조건이 모두 true여야 true
        andResult = true_data && false_data; // false (true && false = false)
        
        // OR 연산: 하나 이상의 조건이 true이면 true  
        orResult = true_data || false_data; // true (true || false = true)
        
        // 동등 비교: 두 값이 같은지 확인
        equalResult = true_data == false_data; // false (true == false = false)
        
        // 부등 비교: 두 값이 다른지 확인
        notEqualResult = true_data != false_data; // true (true != false = true)
        
        // ========== 복합 조건문 예제 ==========
        
        // AND 조건: 모든 조건이 만족해야 실행
        if (true_data && false_data) {
            // 실행되지 않음 (false && true = false)
        }
        
        // OR 조건: 하나 이상의 조건이 만족하면 실행  
        if (true_data || false_data) {
            // 실행됨 (true || false = true)
        }
        
        return (andResult, orResult, equalResult, notEqualResult);
    }
    
    /**
     * @dev 고급 논리 연산과 비교 연산
     * @param _a 첫 번째 숫자
     * @param _b 두 번째 숫자
     * @return isEqual 같은지 여부
     * @return isGreater _a가 더 큰지 여부
     * @return isLessOrEqual _a가 작거나 같은지 여부
     * @return isInRange _a가 특정 범위 내에 있는지 여부
     */
    function compareNumbers(uint256 _a, uint256 _b) external pure returns (
        bool isEqual,
        bool isGreater,
        bool isLessOrEqual,
        bool isInRange
    ) {
        // 기본 비교 연산
        isEqual = (_a == _b);
        isGreater = (_a > _b);
        isLessOrEqual = (_a <= _b);
        
        // 범위 검사 (0 <= _a <= 100)
        isInRange = (_a >= 0 && _a <= 100);
        
        return (isEqual, isGreater, isLessOrEqual, isInRange);
    }
    
    /**
     * @dev 복잡한 조건 로직 예제
     * @param _age 나이
     * @param _hasLicense 라이선스 보유 여부
     * @param _isVip VIP 여부
     * @return canDrive 운전 가능 여부
     * @return getDiscount 할인 적용 여부
     * @return accessLevel 접근 권한 레벨
     */
    function complexLogic(uint256 _age, bool _hasLicense, bool _isVip) external pure returns (
        bool canDrive,
        bool getDiscount,
        uint256 accessLevel
    ) {
        // 복합 조건: 18세 이상이면서 라이선스가 있어야 운전 가능
        canDrive = (_age >= 18) && _hasLicense;
        
        // 할인 조건: 65세 이상이거나 VIP인 경우
        getDiscount = (_age >= 65) || _isVip;
        
        // 삼항 연산자를 사용한 접근 권한 계산
        // 조건 ? 참일_때_값 : 거짓일_때_값
        accessLevel = _isVip ? 3 : (_age >= 18 ? 2 : 1);
        
        return (canDrive, getDiscount, accessLevel);
    }
    
    // ========== 비트 연산 함수들 ==========
    
    /**
     * @dev 비트 연산 예제
     * @param _a 첫 번째 값
     * @param _b 두 번째 값
     * @return bitwiseAnd 비트 AND 결과
     * @return bitwiseOr 비트 OR 결과
     * @return bitwiseXor 비트 XOR 결과
     * @return bitwiseNot 비트 NOT 결과
     * @return leftShift 왼쪽 시프트 결과
     * @return rightShift 오른쪽 시프트 결과
     * @notice 비트 수준에서의 연산과 최적화 기법
     */
    function bitwiseOperations(uint8 _a, uint8 _b) external pure returns (
        uint8 bitwiseAnd,
        uint8 bitwiseOr,
        uint8 bitwiseXor,
        uint8 bitwiseNot,
        uint8 leftShift,
        uint8 rightShift
    ) {
        // 비트 AND (&): 두 비트가 모두 1일 때만 1
        bitwiseAnd = _a & _b;
        
        // 비트 OR (|): 두 비트 중 하나라도 1이면 1
        bitwiseOr = _a | _b;
        
        // 비트 XOR (^): 두 비트가 다르면 1, 같으면 0
        bitwiseXor = _a ^ _b;
        
        // 비트 NOT (~): 모든 비트 반전
        bitwiseNot = ~_a;
        
        // 왼쪽 시프트 (<<): 비트를 왼쪽으로 이동 (2배씩 증가)
        leftShift = _a << 1;
        
        // 오른쪽 시프트 (>>): 비트를 오른쪽으로 이동 (2로 나누기)
        rightShift = _a >> 1;
        
        return (bitwiseAnd, bitwiseOr, bitwiseXor, bitwiseNot, leftShift, rightShift);
    }
    
    // ========== 안전한 연산 함수들 ==========
    
    /**
     * @dev 안전한 덧셈 (오버플로우 체크)
     * @param _a 첫 번째 값
     * @param _b 두 번째 값
     * @return result 덧셈 결과
     * @notice Solidity 0.8.0+ 이전 버전에서 필요한 안전 장치
     */
    function safeAdd(uint256 _a, uint256 _b) external pure returns (uint256 result) {
        result = _a + _b;
        require(result >= _a, "Addition overflow"); // 0.8.0+ 에서는 자동 체크
        return result;
    }
    
    /**
     * @dev 백분율 계산 함수
     * @param _amount 기준 금액
     * @param _percentage 백분율 (예: 15 = 15%)
     * @return result 백분율 적용 결과
     * @notice 정수 연산에서의 정밀도 처리 방법
     */
    function calculatePercentage(uint256 _amount, uint256 _percentage) external pure returns (uint256 result) {
        require(_percentage <= 100, "Invalid percentage");
        
        // 백분율 계산: (금액 * 백분율) / 100
        result = (_amount * _percentage) / 100;
        
        return result;
    }
    
    // ========== 내부 함수 ==========
    
    /**
     * @dev 계산 기록을 저장하는 내부 함수
     * @param _operand1 첫 번째 피연산자
     * @param _operand2 두 번째 피연산자  
     * @param _result 연산 결과
     * @param _operation 연산 종류
     */
    function _recordCalculation(
        uint256 _operand1,
        uint256 _operand2,
        uint256 _result,
        string memory _operation
    ) internal {
        calculationHistory.push(CalculationRecord({
            operand1: _operand1,
            operand2: _operand2,
            result: _result,
            operation: _operation,
            timestamp: block.timestamp
        }));
    }
    
    // ========== 조회 함수들 ==========
    
    /**
     * @dev 계산 기록 조회
     * @return CalculationRecord[] 모든 계산 기록
     */
    function getCalculationHistory() external view returns (CalculationRecord[] memory) {
        return calculationHistory;
    }
    
    /**
     * @dev 최근 계산 기록 조회
     * @param _count 조회할 기록 수
     * @return records 최근 계산 기록들
     */
    function getRecentCalculations(uint256 _count) external view returns (CalculationRecord[] memory records) {
        uint256 length = calculationHistory.length;
        uint256 start = length > _count ? length - _count : 0;
        
        records = new CalculationRecord[](_count);
        uint256 index = 0;
        
        for (uint256 i = start; i < length; i++) {
            records[index] = calculationHistory[i];
            index++;
        }
        
        return records;
    }
    
    /**
     * @dev 연산자 사용법 데모
     * @return currentIntData 현재 정수 데이터 값
     * @return calculationCount 계산 기록 수
     * @return sampleLogic 샘플 논리 연산 결과
     * @return sampleBitwise 샘플 비트 연산 결과
     */
    function demonstrateOperators() external view returns (
        uint256 currentIntData,
        uint256 calculationCount,
        bool sampleLogic,
        uint256 sampleBitwise
    ) {
        currentIntData = intData;
        calculationCount = calculationHistory.length;
        sampleLogic = (intData > 0) && (intData < 1000);
        sampleBitwise = intData & 255; // 하위 8비트만 추출
        
        return (currentIntData, calculationCount, sampleLogic, sampleBitwise);
    }
}