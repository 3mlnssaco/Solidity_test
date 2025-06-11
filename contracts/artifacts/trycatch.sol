//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// TryCatch Contract - try-catch 문 사용 예제
// ===============================================
// 
// 📌 try-catch 개념:
//   - 외부 컨트랙트 호출이나 컨트랙트 생성 시 발생할 수 있는 오류를 처리
//   - Solidity 0.6.0부터 도입된 에러 처리 메커니즘
//   - 실패한 외부 호출로 인해 전체 트랜잭션이 revert되는 것을 방지
//   - 더 세밀한 에러 처리와 복구 로직 구현 가능
//
// 🔗 try-catch 사용 가능한 경우:
//   - 외부 컨트랙트 함수 호출
//   - 새 컨트랙트 생성 (new 키워드)
//   - bytes 데이터로 함수 호출
//
// 💡 catch 블록 종류:
//   - catch Error(string memory reason): require 실패
//   - catch Panic(uint errorCode): assert 실패, 오버플로우 등
//   - catch (bytes memory lowLevelData): 저수준 에러
//   - catch: 모든 에러 처리 (범용)
// ===============================================

// 수학 연산을 수행하는 보조 컨트랙트
contract Mathf {
    /**
     * @dev 두 수를 더하는 함수
     * @param a 첫 번째 숫자
     * @param b 두 번째 숫자
     * @return uint 두 수의 합
     * 
     * 의도적으로 특정 조건에서 실패하도록 설계
     */
    function plusData(uint a, uint b) external pure returns(uint) {
        // 의도적 실패 조건: 두 수가 모두 0인 경우
        require(a > 0 || b > 0, "Both numbers cannot be zero");
        
        // 오버플로우 방지를 위한 검사
        require(a + b >= a, "Addition overflow");
        
        return a + b;
    }
    
    /**
     * @dev 나눗셈 함수 - assert 실패 예제용
     * @param a 피제수
     * @param b 제수
     * @return uint 나눗셈 결과
     */
    function divideData(uint a, uint b) external pure returns(uint) {
        // assert로 0으로 나누기 방지 (Panic 에러 발생)
        assert(b != 0);
        return a / b;
    }
}

// try-catch를 사용하는 메인 컨트랙트
contract Trycatchf {
    // Math 컨트랙트 인스턴스
    Mathf public math;
    
    // 이더 전송을 위한 주소
    address payable public tempAddress;
    
    // 결과 저장용 변수들
    uint public lastResult;
    string public lastError;
    uint public errorCount;
    
    /**
     * @dev 생성자 - Math 컨트랙트 인스턴스 생성
     */
    constructor() {
        math = new Mathf();
        tempAddress = payable(msg.sender);
    }
    
    /**
     * @dev 외부 컨트랙트 호출 with try-catch - 기본 예제
     * @param to 이더를 전송받을 주소
     * @notice Math 컨트랙트의 plusData 함수를 호출하고 결과에 따라 이더 전송
     */
    function callOtherContract(address payable to) external payable {
        // 주소 유효성 검사
        require(to != address(0), "Invalid address");
        
        // try: Math 컨트랙트의 plusData(6, 4) 호출 시도
        try math.plusData(6, 4) returns(uint result) {
            // 성공 시: 결과를 저장하고 이더 전송
            lastResult = result;
            lastError = "";
            
            // 결과만큼 wei 전송 (충분한 이더가 있는 경우에만)
            if (address(this).balance >= result) {
                to.transfer(result);
            }
            
        } catch Error(string memory reason) {
            // require 실패 시: 에러 메시지 저장
            lastError = reason;
            errorCount++;
            
            // 기본값으로 처리
            lastResult = 0;
            
        } catch Panic(uint errorCode) {
            // assert 실패나 오버플로우 등 시스템 에러
            lastError = string(abi.encodePacked("Panic error code: ", errorCode));
            errorCount++;
            lastResult = 0;
            
        } catch (bytes memory /* lowLevelData */) {
            // 기타 저수준 에러
            lastError = "Low level error occurred";
            errorCount++;
            lastResult = 0;
        }
    }
    
    /**
     * @dev 다양한 매개변수로 테스트하는 함수
     * @param a 첫 번째 숫자
     * @param b 두 번째 숫자
     * @return success 성공 여부
     * @return result 계산 결과 (실패 시 0)
     */
    function testMathOperation(uint a, uint b) external returns(bool success, uint result) {
        try math.plusData(a, b) returns(uint calculatedResult) {
            // 성공 시
            lastResult = calculatedResult;
            lastError = "";
            return (true, calculatedResult);
            
        } catch Error(string memory reason) {
            // require 실패 시
            lastError = reason;
            errorCount++;
            return (false, 0);
            
        } catch {
            // 모든 다른 에러들
            lastError = "Unknown error occurred";
            errorCount++;
            return (false, 0);
        }
    }
    
    /**
     * @dev 나눗셈 테스트 - Panic 에러 발생 가능
     * @param a 피제수
     * @param b 제수
     * @return success 성공 여부
     * @return result 나눗셈 결과
     */
    function testDivision(uint a, uint b) external returns(bool success, uint result) {
        try math.divideData(a, b) returns(uint divisionResult) {
            lastResult = divisionResult;
            lastError = "";
            return (true, divisionResult);
            
        } catch Panic(uint errorCode) {
            // Panic 에러 (0으로 나누기 등)
            lastError = string(abi.encodePacked("Division panic: ", errorCode));
            errorCount++;
            return (false, 0);
            
        } catch {
            // 기타 에러
            lastError = "Division error";
            errorCount++;
            return (false, 0);
        }
    }
    
    /**
     * @dev 새 컨트랙트 생성 with try-catch
     * @return success 생성 성공 여부
     * @return newMathAddress 새로 생성된 컨트랙트 주소
     */
    function createNewMathContract() external returns(bool success, address newMathAddress) {
        try new Mathf() returns(Mathf newMath) {
            // 성공 시: 새 컨트랙트 주소 반환
            return (true, address(newMath));
            
        } catch {
            // 생성 실패 시
            lastError = "Contract creation failed";
            errorCount++;
            return (false, address(0));
        }
    }
    
    /**
     * @dev 에러 정보 조회 함수
     * @return result 마지막 성공한 결과
     * @return error 마지막 에러 메시지
     * @return count 총 에러 발생 횟수
     */
    function getErrorInfo() external view returns(uint result, string memory error, uint count) {
        return (lastResult, lastError, errorCount);
    }
    
    /**
     * @dev 컨트랙트가 이더를 받을 수 있도록 함
     */
    receive() external payable {}
    
    /**
     * @dev 컨트랙트의 이더 잔액 조회
     * @return uint 현재 컨트랙트의 이더 잔액 (wei)
     */
    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}
