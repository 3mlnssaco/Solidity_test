// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// ===============================================
// Address Contract - 주소(Address) 타입 종합 예제
// ===============================================
// 
// 📌 주소(Address) 개념:
//   - 이더리움 네트워크에서 계정을 식별하는 20바이트 고유 식별자
//   - EOA(외부 소유 계정): 개인 키로 제어되는 사용자 계정
//   - 컨트랙트 계정: 스마트 컨트랙트가 배포된 주소
//   - 모든 거래와 상호작용의 기본 단위
//   - 16진수 형태로 표현 (0x + 40자리)
//
// 💡 Address 타입 특징:
//   - address: 기본 주소 타입 (이더 전송 불가)
//   - address payable: 이더 전송 가능한 주소 타입
//   - .balance: 해당 주소의 이더 잔액 조회
//   - .code: 컨트랙트 코드 조회 (EOA는 빈 코드)
//   - .call(), .delegatecall(), .staticcall(): 저수준 호출
//
// 🔗 이더 전송 방법:
//   1. transfer(): 2300 gas 제한, 실패 시 자동 revert
//   2. send(): 2300 gas 제한, 실패 시 false 반환
//   3. call{value: ...}(): 가스 제한 없음, 가장 안전한 방법
// ===============================================

/**
 * @title Address
 * @dev 주소 타입과 이더 전송 방법들을 보여주는 종합 예제 컨트랙트
 * @notice 다양한 이더 전송 방법과 주소 검증 기능을 시연
 */
contract Address {
    
    // ========== 상태 변수 ==========
    
    /**
     * @dev 실패 예시로 사용할 주소 (임의의 주소)
     * @notice 이더 전송 테스트를 위한 샘플 주소
     * 
     * 주소 특징:
     * - 20바이트 (160비트) 길이
     * - 체크섬 형태로 표현 가능 (대소문자 구분)
     * - 0x 접두사와 함께 16진수로 표현
     */
    address public failUser = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    /**
     * @dev 성공 예시로 사용할 주소 (임의의 주소)
     * @notice 정상적인 이더 전송을 위한 수신자 주소
     */
    address public successUser = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    
    /**
     * @dev 이더를 받을 수 있는 payable address로 변환
     * @notice payable 타입 변환 및 이더 전송 기능 시연
     * 
     * address payable 특징:
     * - 이더 전송 메서드 제공: transfer(), send(), call()
     * - address에서 payable로 명시적 변환 필요
     * - 컨트랙트 주소의 경우 receive/fallback 함수 필요
     */
    address payable public payable_user = payable(successUser);
    
    /**
     * @dev 컨트랙트 소유자 주소
     * @notice 권한 관리를 위한 소유자 정보
     */
    address public owner;
    
    /**
     * @dev 승인된 주소 목록 (화이트리스트)
     * @notice 특정 작업을 수행할 수 있는 주소들
     */
    mapping(address => bool) public approvedAddresses;
    
    /**
     * @dev 주소별 수신된 이더량 기록
     * @notice 각 주소로 전송된 총 이더량 추적
     */
    mapping(address => uint256) public totalSent;
    
    /**
     * @dev 이더 전송 기록 배열
     * @notice 모든 전송 내역을 저장하는 구조체 배열
     */
    TransferRecord[] public transferHistory;
    
    /**
     * @dev 이더 전송 기록을 위한 구조체
     */
    struct TransferRecord {
        address from;           // 발신자
        address to;            // 수신자
        uint256 amount;        // 전송량 (wei)
        uint256 timestamp;     // 전송 시간
        TransferMethod method; // 사용된 전송 방법
        bool success;          // 성공 여부
    }
    
    /**
     * @dev 이더 전송 방법을 나타내는 열거형
     */
    enum TransferMethod { Transfer, Send, Call }
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 이더 전송 시 발생하는 이벤트
     */
    event EtherSent(
        address indexed from, 
        address indexed to, 
        uint256 amount, 
        TransferMethod method, 
        bool success
    );
    
    /**
     * @dev 이더 수신 시 발생하는 이벤트
     */
    event EtherReceived(address indexed from, uint256 amount);
    
    /**
     * @dev 주소 승인 시 발생하는 이벤트
     */
    event AddressApproved(address indexed addr, bool approved);
    
    // ========== 한정자(Modifiers) ==========
    
    /**
     * @dev 소유자만 실행 가능한 한정자
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    /**
     * @dev 승인된 주소만 실행 가능한 한정자
     */
    modifier onlyApproved() {
        require(approvedAddresses[msg.sender], "Address not approved");
        _;
    }
    
    /**
     * @dev 유효한 주소인지 확인하는 한정자
     */
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Invalid address: zero address");
        _;
    }
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 소유자 설정 및 초기 승인 주소 등록
     */
    constructor() {
        owner = msg.sender;
        approvedAddresses[msg.sender] = true; // 소유자를 자동 승인
        emit AddressApproved(msg.sender, true);
    }
    
    // ========== 이더 전송 함수들 ==========
    
    /**
     * @dev 이더를 전송하는 함수 (transfer, send, call 3가지 방법)
     * @notice 각 전송 방법의 특징과 차이점을 보여주는 함수
     * 
     * 이더 전송 방법 비교:
     * 1. transfer(): 안전하지만 경직됨 (2300 gas 제한)
     * 2. send(): 유연하지만 수동 에러 처리 필요
     * 3. call(): 가장 유연하고 권장되는 방법
     */
    function sendEth() public payable {
        require(msg.value > 0, "Must send some ether");
        require(msg.value >= 3000000000000, "Minimum 3000000000000 wei required"); // 약 0.000003 ETH
        
        uint256 sendAmount = 1000000000000; // 각 방법당 전송할 금액
        
        // ========== 방법 1: transfer() ==========
        /**
         * transfer() 특징:
         * - 2300 gas 제한 (재진입 공격 방지)
         * - 실패 시 자동으로 revert (에러 처리 자동)
         * - 간단하고 안전하지만 유연성 부족
         * - receive/fallback이 복잡한 컨트랙트에는 실패 가능
         * - try-catch 사용 불가 (내부 함수 호출이므로)
         */
        payable_user.transfer(sendAmount);
        _recordTransfer(msg.sender, payable_user, sendAmount, TransferMethod.Transfer, true);
        emit EtherSent(msg.sender, payable_user, sendAmount, TransferMethod.Transfer, true);
        
        // ========== 방법 2: send() ==========
        /**
         * send() 특징:
         * - 2300 gas 제한 (transfer와 동일)
         * - 실패 시 false 반환 (자동 revert 없음)
         * - 수동으로 에러 처리 필요
         * - 더 많은 제어권 제공
         */
        bool sent = payable_user.send(sendAmount);
        if (!sent) {
            // send 실패 시 수동으로 revert
            revert("Send failed"); 
        }
        _recordTransfer(msg.sender, payable_user, sendAmount, TransferMethod.Send, sent);
        emit EtherSent(msg.sender, payable_user, sendAmount, TransferMethod.Send, sent);
        
        // ========== 방법 3: call() (권장) ==========
        /**
         * call() 특징:
         * - 가스 제한 없음 (전체 가스 전달 가능)
         * - 실패 시 false 반환 + 에러 데이터 제공
         * - 가장 유연하고 안전한 방법 (Solidity 0.6.0 이후 권장)
         * - 재진입 공격에 주의 필요 (checks-effects-interactions 패턴 사용)
         */
        (bool success, ) = payable_user.call{value: sendAmount}("");
        if (!success) {
            revert("Failed to send Ether"); 
        }
        _recordTransfer(msg.sender, payable_user, sendAmount, TransferMethod.Call, success);
        emit EtherSent(msg.sender, payable_user, sendAmount, TransferMethod.Call, success);
        
        // 총 전송량 업데이트
        totalSent[payable_user] += sendAmount * 3;
    }
    
    /**
     * @dev 특정 주소로 이더 전송 (call 방법 사용)
     * @param _to 수신자 주소
     * @param _amount 전송할 금액 (wei)
     */
    function sendEtherTo(address payable _to, uint256 _amount) external payable validAddress(_to) {
        require(msg.value >= _amount, "Insufficient ether sent");
        require(_amount > 0, "Amount must be greater than 0");
        
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
        
        _recordTransfer(msg.sender, _to, _amount, TransferMethod.Call, true);
        totalSent[_to] += _amount;
        
        emit EtherSent(msg.sender, _to, _amount, TransferMethod.Call, true);
        
        // 잔돈 반환
        if (msg.value > _amount) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: msg.value - _amount}("");
            require(refundSuccess, "Refund failed");
        }
    }
    
    /**
     * @dev 일괄 이더 전송 (여러 주소에 동시 전송)
     * @param _recipients 수신자 주소 배열
     * @param _amounts 각 수신자에게 보낼 금액 배열
     */
    function batchSendEther(
        address payable[] calldata _recipients, 
        uint256[] calldata _amounts
    ) external payable onlyApproved {
        require(_recipients.length == _amounts.length, "Arrays length mismatch");
        require(_recipients.length > 0, "No recipients provided");
        
        uint256 totalAmount = 0;
        
        // 총 필요 금액 계산
        for (uint i = 0; i < _amounts.length; i++) {
            require(_recipients[i] != address(0), "Invalid recipient address");
            require(_amounts[i] > 0, "Amount must be greater than 0");
            totalAmount += _amounts[i];
        }
        
        require(msg.value >= totalAmount, "Insufficient ether for batch transfer");
        
        // 각 주소로 이더 전송
        for (uint i = 0; i < _recipients.length; i++) {
            (bool success, ) = _recipients[i].call{value: _amounts[i]}("");
            
            _recordTransfer(msg.sender, _recipients[i], _amounts[i], TransferMethod.Call, success);
            totalSent[_recipients[i]] += _amounts[i];
            
            emit EtherSent(msg.sender, _recipients[i], _amounts[i], TransferMethod.Call, success);
            
            if (!success) {
                // 하나라도 실패하면 전체 거래 실패
                revert(string(abi.encodePacked("Transfer failed for recipient ", _recipients[i])));
            }
        }
        
        // 잔돈 반환
        if (msg.value > totalAmount) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: msg.value - totalAmount}("");
            require(refundSuccess, "Refund failed");
        }
    }
    
    // ========== 주소 조회 및 검증 함수들 ==========
    
    /**
     * @dev payable_user의 잔액을 조회하는 함수
     * @return uint256 해당 주소의 현재 이더 잔액 (wei 단위)
     * @notice address.balance 속성 사용 예제
     */
    function getBalance() public view returns (uint256) {
        // .balance 속성: 해당 주소의 현재 이더 잔액 조회
        // 모든 address 타입에서 사용 가능
        // 반환값은 wei 단위 (1 ETH = 10^18 wei)
        return payable_user.balance;
    }
    
    /**
     * @dev 특정 주소의 잔액 조회
     * @param _addr 잔액을 조회할 주소
     * @return uint256 해당 주소의 이더 잔액
     */
    function getBalanceOf(address _addr) external view validAddress(_addr) returns (uint256) {
        return _addr.balance;
    }
    
    /**
     * @dev 현재 컨트랙트의 잔액 조회
     * @return uint256 컨트랙트가 보유한 이더 잔액
     */
    function getContractBalance() external view returns (uint256) {
        // address(this): 현재 컨트랙트의 주소
        return address(this).balance;
    }
    
    /**
     * @dev 주소가 컨트랙트인지 확인
     * @param _addr 확인할 주소
     * @return bool 컨트랙트 주소 여부
     * @notice extcodesize를 사용한 컨트랙트 검증
     */
    function isContract(address _addr) public view returns (bool) {
        // extcodesize: 해당 주소에 배포된 코드의 크기 반환
        // EOA는 코드가 없으므로 0 반환
        // 컨트랙트는 코드가 있으므로 0보다 큰 값 반환
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }
    
    /**
     * @dev 주소 유효성 종합 검사
     * @param _addr 검사할 주소
     * @return isValid 기본 유효성 (영주소가 아님)
     * @return isContract_ 컨트랙트 여부
     * @return balance 해당 주소의 잔액
     * @return hasCode 코드 존재 여부
     */
    function validateAddressComprehensive(address _addr) external view returns (
        bool isValid,
        bool isContract_,
        uint256 balance,
        bool hasCode
    ) {
        isValid = _addr != address(0);
        isContract_ = isContract(_addr);
        balance = _addr.balance;
        hasCode = isContract_;
        
        return (isValid, isContract_, balance, hasCode);
    }
    
    // ========== 권한 관리 함수들 ==========
    
    /**
     * @dev 주소 승인/해제
     * @param _addr 승인할 주소
     * @param _approved 승인 여부
     */
    function setAddressApproval(address _addr, bool _approved) external onlyOwner validAddress(_addr) {
        approvedAddresses[_addr] = _approved;
        emit AddressApproved(_addr, _approved);
    }
    
    /**
     * @dev 여러 주소를 일괄 승인
     * @param _addresses 승인할 주소 배열
     * @param _approved 승인 여부
     */
    function batchSetApproval(address[] calldata _addresses, bool _approved) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0), "Invalid address in batch");
            approvedAddresses[_addresses[i]] = _approved;
            emit AddressApproved(_addresses[i], _approved);
        }
    }
    
    /**
     * @dev 소유권 이전
     * @param _newOwner 새로운 소유자 주소
     */
    function transferOwnership(address _newOwner) external onlyOwner validAddress(_newOwner) {
        require(_newOwner != owner, "New owner is the same as current owner");
        
        address oldOwner = owner;
        owner = _newOwner;
        
        // 새 소유자 자동 승인
        approvedAddresses[_newOwner] = true;
        emit AddressApproved(_newOwner, true);
        
        // 이전 소유자 승인 해제 (선택사항)
        // approvedAddresses[oldOwner] = false;
    }
    
    // ========== 내부 함수들 ==========
    
    /**
     * @dev 전송 기록을 저장하는 내부 함수
     */
    function _recordTransfer(
        address _from, 
        address _to, 
        uint256 _amount, 
        TransferMethod _method, 
        bool _success
    ) internal {
        transferHistory.push(TransferRecord({
            from: _from,
            to: _to,
            amount: _amount,
            timestamp: block.timestamp,
            method: _method,
            success: _success
        }));
    }
    
    // ========== 조회 함수들 ==========
    
    /**
     * @dev 전송 기록 조회
     * @return TransferRecord[] 모든 전송 기록
     */
    function getTransferHistory() external view returns (TransferRecord[] memory) {
        return transferHistory;
    }
    
    /**
     * @dev 특정 주소의 전송 기록 조회
     * @param _addr 조회할 주소 (발신자 또는 수신자)
     * @return records 해당 주소와 관련된 전송 기록들
     */
    function getTransferHistoryByAddress(address _addr) external view returns (TransferRecord[] memory records) {
        uint count = 0;
        
        // 관련 기록 개수 계산
        for (uint i = 0; i < transferHistory.length; i++) {
            if (transferHistory[i].from == _addr || transferHistory[i].to == _addr) {
                count++;
            }
        }
        
        // 결과 배열 생성 및 채우기
        records = new TransferRecord[](count);
        uint currentIndex = 0;
        
        for (uint i = 0; i < transferHistory.length; i++) {
            if (transferHistory[i].from == _addr || transferHistory[i].to == _addr) {
                records[currentIndex] = transferHistory[i];
                currentIndex++;
            }
        }
        
        return records;
    }
    
    /**
     * @dev 시스템 통계 조회
     * @return totalTransfers 총 전송 시도 횟수
     * @return successfulTransfers 성공한 전송 횟수
     * @return contractBalance 컨트랙트 잔액
     * @return approvedCount 승인된 주소 수 (추가 구현 필요)
     */
    function getSystemStats() external view returns (
        uint256 totalTransfers,
        uint256 successfulTransfers,
        uint256 contractBalance,
        uint256 approvedCount
    ) {
        totalTransfers = transferHistory.length;
        contractBalance = address(this).balance;
        
        // 성공한 전송 개수 계산
        for (uint i = 0; i < transferHistory.length; i++) {
            if (transferHistory[i].success) {
                successfulTransfers++;
            }
        }
        
        // 승인된 주소 수는 별도 배열로 관리해야 정확히 계산 가능
        approvedCount = 0; // 간단화를 위해 0으로 설정
        
        return (totalTransfers, successfulTransfers, contractBalance, approvedCount);
    }
    
    // ========== 이더 수신 함수들 ==========
    
    /**
     * @dev 이더를 받을 수 있는 receive 함수
     * @notice 단순한 이더 전송 시 호출됨
     */
    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev fallback 함수 (데이터와 함께 이더 전송 시)
     * @notice 존재하지 않는 함수 호출이나 데이터와 함께 이더 전송 시 호출
     */
    fallback() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev 컨트랙트에 저장된 이더 인출 (소유자 전용)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdrawal failed");
    }
    
    /**
     * @dev 특정 금액만 인출
     * @param _amount 인출할 금액 (wei)
     */
    function withdrawAmount(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= _amount, "Insufficient contract balance");
        
        (bool success, ) = payable(owner).call{value: _amount}("");
        require(success, "Withdrawal failed");
    }
}