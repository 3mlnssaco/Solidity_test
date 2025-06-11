//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ===============================================
// Mapping Contract - 매핑(Mapping) 타입 종합 예제
// ===============================================
// 
// 📌 매핑(Mapping) 개념:
//   - 키-값 쌍을 저장하는 해시테이블 형태의 데이터 구조
//   - 솔리디티에서 가장 중요하고 자주 사용되는 데이터 타입
//   - 키를 통해 O(1) 시간 복잡도로 값에 접근 가능
//   - storage에만 저장 가능 (memory, calldata 불가)
//   - 이터레이션(순회) 불가능 (키 목록을 별도 관리 필요)
//
// 💡 매핑 특징:
//   - 선언: mapping(KeyType => ValueType) public/private 변수명
//   - 기본값: 모든 키에 대해 해당 타입의 기본값 반환
//   - 무한한 키 공간: 존재하지 않는 키도 에러 없이 기본값 반환
//   - 중첩 매핑 가능: mapping(address => mapping(uint => bool))
//   - 동적 크기: 런타임에 키-값 쌍 추가/수정 가능
//
// 🔗 실용적 활용 사례:
//   - 잔액 관리: mapping(address => uint256) balances
//   - 권한 관리: mapping(address => bool) isAdmin
//   - NFT 소유권: mapping(uint256 => address) tokenOwner
//   - 투표 시스템: mapping(address => bool) hasVoted
// ===============================================

/**
 * @title Mapping
 * @dev 매핑의 모든 기능과 활용법을 보여주는 종합 예제 컨트랙트
 * @notice 단순 매핑부터 중첩 매핑까지 다양한 패턴을 시연
 */
contract Mapping {
    
    // ========== 기본 매핑 예제 ==========
    
    /**
     * @dev 주소별 잔액을 저장하는 기본 매핑 (원본 코드 유지)
     * @notice 가장 기본적인 매핑 사용 예제
     * 
     * 매핑 기본 문법:
     * - mapping(KeyType => ValueType) visibility variableName
     * - KeyType: address, uint, bytes32 등 (참조 타입 제외)
     * - ValueType: 모든 타입 가능 (구조체, 배열, 매핑 포함)
     * - public: 자동 getter 함수 생성
     */
    mapping(address => int) public balance;
    
    /**
     * @dev 주소별 사용자 이름 저장
     * @notice 문자열 값을 저장하는 매핑 예제
     */
    mapping(address => string) public userNames;
    
    /**
     * @dev 주소별 활성 상태 저장
     * @notice 불린 값을 저장하는 매핑 예제
     */
    mapping(address => bool) public isActive;
    
    /**
     * @dev 주소별 등록 시간 저장
     * @notice 타임스탬프를 저장하는 매핑 예제
     */
    mapping(address => uint256) public registrationTime;
    
    // ========== 중첩 매핑 예제 ==========
    
    /**
     * @dev 2차원 매핑: 소유자 -> 승인자 -> 권한 여부
     * @notice ERC20 토큰의 allowance 패턴
     * 
     * 중첩 매핑 특징:
     * - mapping 안에 또 다른 mapping 포함
     * - 2차원 테이블과 유사한 구조
     * - allowances[owner][spender] 형태로 접근
     */
    mapping(address => mapping(address => uint256)) public allowances;
    
    /**
     * @dev 3차원 매핑: 사용자 -> 카테고리 -> 아이템 -> 수량
     * @notice 복잡한 게임 아이템 인벤토리 시스템
     */
    mapping(address => mapping(string => mapping(uint256 => uint256))) public inventory;
    
    /**
     * @dev 매핑과 구조체 조합: 주소별 사용자 정보
     * @notice 복합 데이터를 값으로 사용하는 매핑
     */
    mapping(address => UserInfo) public users;
    
    /**
     * @dev 사용자 정보 구조체
     */
    struct UserInfo {
        string name;           // 사용자명
        uint256 level;        // 레벨
        uint256 experience;   // 경험치
        bool isPremium;       // 프리미엄 여부
        uint256[] ownedItems; // 소유 아이템 목록
    }
    
    // ========== 매핑과 배열 조합 ==========
    
    /**
     * @dev 매핑의 모든 키를 추적하는 배열
     * @notice 매핑 순회를 위한 키 목록 관리
     * 
     * 매핑 한계 해결:
     * - 매핑은 이터레이션 불가능
     * - 별도 배열로 키 목록 관리
     * - 키 추가/제거 시 배열도 동기화 필요
     */
    address[] public allUsers;
    
    /**
     * @dev 사용자가 등록되었는지 확인하는 매핑
     * @notice 중복 등록 방지용
     */
    mapping(address => bool) public isRegistered;
    
    /**
     * @dev 주소별 배열 인덱스 저장
     * @notice 배열에서 빠른 제거를 위한 인덱스 추적
     */
    mapping(address => uint256) public userIndex;
    
    // ========== 고급 매핑 패턴 ==========
    
    /**
     * @dev 매핑을 값으로 사용하는 매핑
     * @notice 각 사용자별로 개별 잔액 장부 관리
     */
    mapping(address => mapping(address => uint256)) public personalLedger;
    
    /**
     * @dev 동적 키를 위한 bytes32 매핑
     * @notice 문자열이나 복합 데이터를 키로 사용
     */
    mapping(bytes32 => uint256) public dynamicStorage;
    
    /**
     * @dev 열거형을 키로 사용하는 매핑
     * @notice 상태별 카운터 관리
     */
    enum UserStatus { Inactive, Active, Suspended, Banned }
    mapping(UserStatus => uint256) public statusCounts;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 잔액 변경 시 발생하는 이벤트
     */
    event BalanceUpdated(address indexed user, int oldBalance, int newBalance);
    
    /**
     * @dev 사용자 등록 시 발생하는 이벤트
     */
    event UserRegistered(address indexed user, string name);
    
    /**
     * @dev 권한 승인 시 발생하는 이벤트
     */
    event AllowanceSet(address indexed owner, address indexed spender, uint256 amount);
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 초기 데이터 설정 및 배포자 등록
     */
    constructor() {
        // 배포자를 첫 번째 사용자로 등록
        _registerUser(msg.sender, "Contract Owner");
        
        // 초기 잔액 설정
        balance[msg.sender] = 1000;
        
        // 상태별 카운터 초기화
        statusCounts[UserStatus.Active] = 1;
    }
    
    // ========== 기본 매핑 조작 함수들 ==========
    
    /**
     * @dev 특정 주소의 잔액 설정 함수 (원본 코드 개선)
     * @param _addr 잔액을 설정할 주소
     * @param _value 설정할 잔액 값
     * @notice 매핑 값 설정의 기본 패턴
     */
    function setBalance(address _addr, int _value) public {
        require(_addr != address(0), "Invalid address");
        
        int oldBalance = balance[_addr];
        balance[_addr] = _value; // 매핑에 값 할당
        
        emit BalanceUpdated(_addr, oldBalance, _value);
    }
    
    /**
     * @dev 특정 주소의 잔액 조회 함수 (원본 코드 유지)
     * @param _addr 잔액을 조회할 주소
     * @return int 해당 주소의 잔액
     * @notice 매핑 값 조회의 기본 패턴 (public 매핑이므로 선택사항)
     */
    function getBalance(address _addr) public view returns (int) {
        // 매핑에서 값 조회
        // 존재하지 않는 키는 기본값(0) 반환
        return balance[_addr];
    }
    
    /**
     * @dev 잔액 증가
     * @param _addr 대상 주소
     * @param _amount 증가할 금액
     */
    function increaseBalance(address _addr, int _amount) external {
        require(_addr != address(0), "Invalid address");
        require(_amount > 0, "Amount must be positive");
        
        int oldBalance = balance[_addr];
        balance[_addr] += _amount;
        
        emit BalanceUpdated(_addr, oldBalance, balance[_addr]);
    }
    
    /**
     * @dev 잔액 감소
     * @param _addr 대상 주소
     * @param _amount 감소할 금액
     */
    function decreaseBalance(address _addr, int _amount) external {
        require(_addr != address(0), "Invalid address");
        require(_amount > 0, "Amount must be positive");
        require(balance[_addr] >= _amount, "Insufficient balance");
        
        int oldBalance = balance[_addr];
        balance[_addr] -= _amount;
        
        emit BalanceUpdated(_addr, oldBalance, balance[_addr]);
    }
    
    // ========== 사용자 관리 함수들 ==========
    
    /**
     * @dev 새 사용자 등록
     * @param _name 사용자명
     * @notice 매핑과 배열 동기화 패턴
     */
    function registerUser(string memory _name) external {
        require(!isRegistered[msg.sender], "User already registered");
        require(bytes(_name).length > 0, "Name cannot be empty");
        
        _registerUser(msg.sender, _name);
    }
    
    /**
     * @dev 내부 사용자 등록 함수
     * @param _user 등록할 사용자 주소
     * @param _name 사용자명
     */
    function _registerUser(address _user, string memory _name) internal {
        // 1. 매핑에 데이터 저장
        userNames[_user] = _name;
        isActive[_user] = true;
        registrationTime[_user] = block.timestamp;
        isRegistered[_user] = true;
        
        // 2. 구조체 초기화
        users[_user] = UserInfo({
            name: _name,
            level: 1,
            experience: 0,
            isPremium: false,
            ownedItems: new uint256[](0)
        });
        
        // 3. 키 배열에 추가 (순회를 위해)
        userIndex[_user] = allUsers.length;
        allUsers.push(_user);
        
        emit UserRegistered(_user, _name);
    }
    
    /**
     * @dev 사용자 정보 업데이트
     * @param _level 새로운 레벨
     * @param _experience 새로운 경험치
     * @param _isPremium 프리미엄 여부
     */
    function updateUserInfo(uint256 _level, uint256 _experience, bool _isPremium) external {
        require(isRegistered[msg.sender], "User not registered");
        
        // 구조체 필드 개별 업데이트
        users[msg.sender].level = _level;
        users[msg.sender].experience = _experience;
        users[msg.sender].isPremium = _isPremium;
    }
    
    /**
     * @dev 사용자 아이템 추가
     * @param _itemId 아이템 ID
     */
    function addUserItem(uint256 _itemId) external {
        require(isRegistered[msg.sender], "User not registered");
        
        // 구조체 내 배열에 요소 추가
        users[msg.sender].ownedItems.push(_itemId);
    }
    
    // ========== 중첩 매핑 조작 함수들 ==========
    
    /**
     * @dev 권한 승인 설정 (ERC20 allowance 패턴)
     * @param _spender 승인받을 주소
     * @param _amount 승인할 금액
     * @notice 2차원 매핑 사용 패턴
     */
    function approve(address _spender, uint256 _amount) external {
        require(_spender != address(0), "Invalid spender address");
        
        // 중첩 매핑에 값 설정
        // allowances[msg.sender][_spender] = _amount
        allowances[msg.sender][_spender] = _amount;
        
        emit AllowanceSet(msg.sender, _spender, _amount);
    }
    
    /**
     * @dev 권한 조회
     * @param _owner 소유자 주소
     * @param _spender 승인받은 주소
     * @return uint256 승인된 금액
     */
    function getAllowance(address _owner, address _spender) external view returns (uint256) {
        return allowances[_owner][_spender];
    }
    
    /**
     * @dev 인벤토리 아이템 설정 (3차원 매핑)
     * @param _category 카테고리 (예: "weapons", "armor")
     * @param _itemId 아이템 ID
     * @param _quantity 수량
     */
    function setInventoryItem(string memory _category, uint256 _itemId, uint256 _quantity) external {
        require(isRegistered[msg.sender], "User not registered");
        require(bytes(_category).length > 0, "Category cannot be empty");
        
        // 3차원 매핑에 값 설정
        inventory[msg.sender][_category][_itemId] = _quantity;
    }
    
    /**
     * @dev 인벤토리 아이템 조회
     * @param _user 사용자 주소
     * @param _category 카테고리
     * @param _itemId 아이템 ID
     * @return uint256 아이템 수량
     */
    function getInventoryItem(address _user, string memory _category, uint256 _itemId) external view returns (uint256) {
        return inventory[_user][_category][_itemId];
    }
    
    // ========== 동적 키 매핑 함수들 ==========
    
    /**
     * @dev 문자열 키로 데이터 저장
     * @param _key 문자열 키
     * @param _value 저장할 값
     * @notice 문자열을 bytes32로 변환하여 키로 사용
     */
    function setDynamicData(string memory _key, uint256 _value) external {
        bytes32 hashedKey = keccak256(abi.encodePacked(_key));
        dynamicStorage[hashedKey] = _value;
    }
    
    /**
     * @dev 문자열 키로 데이터 조회
     * @param _key 문자열 키
     * @return uint256 저장된 값
     */
    function getDynamicData(string memory _key) external view returns (uint256) {
        bytes32 hashedKey = keccak256(abi.encodePacked(_key));
        return dynamicStorage[hashedKey];
    }
    
    /**
     * @dev 복합 키로 데이터 저장
     * @param _addr 주소
     * @param _id ID
     * @param _value 저장할 값
     * @notice 여러 값을 조합하여 고유 키 생성
     */
    function setCompositeData(address _addr, uint256 _id, uint256 _value) external {
        bytes32 compositeKey = keccak256(abi.encodePacked(_addr, _id));
        dynamicStorage[compositeKey] = _value;
    }
    
    /**
     * @dev 복합 키로 데이터 조회
     * @param _addr 주소
     * @param _id ID
     * @return uint256 저장된 값
     */
    function getCompositeData(address _addr, uint256 _id) external view returns (uint256) {
        bytes32 compositeKey = keccak256(abi.encodePacked(_addr, _id));
        return dynamicStorage[compositeKey];
    }
    
    // ========== 매핑 순회 및 통계 함수들 ==========
    
    /**
     * @dev 등록된 모든 사용자 주소 반환
     * @return address[] 사용자 주소 배열
     * @notice 매핑 키 목록 조회 패턴
     */
    function getAllUsers() external view returns (address[] memory) {
        return allUsers;
    }
    
    /**
     * @dev 등록된 사용자 수 반환
     * @return uint256 총 사용자 수
     */
    function getUserCount() external view returns (uint256) {
        return allUsers.length;
    }
    
    /**
     * @dev 활성 사용자 수 계산
     * @return uint256 활성 상태인 사용자 수
     * @notice 매핑 값 기반 필터링 패턴
     */
    function getActiveUserCount() external view returns (uint256) {
        uint256 activeCount = 0;
        
        for (uint256 i = 0; i < allUsers.length; i++) {
            if (isActive[allUsers[i]]) {
                activeCount++;
            }
        }
        
        return activeCount;
    }
    
    /**
     * @dev 모든 사용자의 총 잔액 계산
     * @return int 전체 잔액 합계
     */
    function getTotalBalance() external view returns (int) {
        int total = 0;
        
        for (uint256 i = 0; i < allUsers.length; i++) {
            total += balance[allUsers[i]];
        }
        
        return total;
    }
    
    /**
     * @dev 특정 조건을 만족하는 사용자 목록 반환
     * @param _minBalance 최소 잔액 조건
     * @return qualifiedUsers 조건을 만족하는 사용자들
     */
    function getUsersByMinBalance(int _minBalance) external view returns (address[] memory qualifiedUsers) {
        // 1단계: 조건 만족하는 사용자 수 계산
        uint256 qualifiedCount = 0;
        for (uint256 i = 0; i < allUsers.length; i++) {
            if (balance[allUsers[i]] >= _minBalance) {
                qualifiedCount++;
            }
        }
        
        // 2단계: 결과 배열 생성 및 채우기
        qualifiedUsers = new address[](qualifiedCount);
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < allUsers.length; i++) {
            if (balance[allUsers[i]] >= _minBalance) {
                qualifiedUsers[currentIndex] = allUsers[i];
                currentIndex++;
            }
        }
        
        return qualifiedUsers;
    }
    
    // ========== 고급 매핑 패턴 함수들 ==========
    
    /**
     * @dev 사용자별 개인 장부에 기록 추가
     * @param _counterparty 거래 상대방
     * @param _amount 거래 금액
     */
    function addPersonalLedgerEntry(address _counterparty, uint256 _amount) external {
        require(_counterparty != address(0), "Invalid counterparty");
        require(_counterparty != msg.sender, "Cannot trade with yourself");
        
        personalLedger[msg.sender][_counterparty] += _amount;
    }
    
    /**
     * @dev 개인 장부 조회
     * @param _owner 장부 소유자
     * @param _counterparty 거래 상대방
     * @return uint256 거래 총액
     */
    function getPersonalLedgerEntry(address _owner, address _counterparty) external view returns (uint256) {
        return personalLedger[_owner][_counterparty];
    }
    
    /**
     * @dev 매핑 키 존재 여부 확인 패턴
     * @param _addr 확인할 주소
     * @return bool 해당 키가 의미있는 값을 가지는지 여부
     * @notice 기본값과 실제 설정값 구분하는 패턴
     */
    function hasUserData(address _addr) external view returns (bool) {
        // 등록 시간이 0이 아니면 실제 등록된 사용자
        return registrationTime[_addr] != 0;
    }
    
    /**
     * @dev 매핑 값 삭제 (기본값으로 재설정)
     * @param _addr 삭제할 사용자 주소
     * @notice delete 키워드 사용 패턴
     */
    function deleteUser(address _addr) external {
        require(isRegistered[_addr], "User not registered");
        
        // 매핑에서 값 삭제 (기본값으로 재설정)
        delete balance[_addr];
        delete userNames[_addr];
        delete isActive[_addr];
        delete registrationTime[_addr];
        delete isRegistered[_addr];
        delete users[_addr];
        
        // 배열에서 제거 (비효율적이지만 예시용)
        _removeFromArray(_addr);
    }
    
    /**
     * @dev 배열에서 요소 제거 내부 함수
     * @param _addr 제거할 주소
     */
    function _removeFromArray(address _addr) internal {
        uint256 index = userIndex[_addr];
        require(index < allUsers.length, "Invalid index");
        
        // 마지막 요소를 현재 위치로 이동
        address lastUser = allUsers[allUsers.length - 1];
        allUsers[index] = lastUser;
        userIndex[lastUser] = index;
        
        // 배열 크기 감소
        allUsers.pop();
        delete userIndex[_addr];
    }
    
    // ========== 유틸리티 함수들 ==========
    
    /**
     * @dev 매핑 사용법 데모 함수
     * @return myBalance 호출자의 잔액
     * @return myName 호출자의 이름
     * @return myActiveStatus 호출자의 활성 상태
     * @return myRegistrationTime 호출자의 등록 시간
     * @return amIRegistered 호출자의 등록 여부
     */
    function demonstrateMappingUsage() external view returns (
        int myBalance,
        string memory myName,
        bool myActiveStatus,
        uint256 myRegistrationTime,
        bool amIRegistered
    ) {
        myBalance = balance[msg.sender];
        myName = userNames[msg.sender];
        myActiveStatus = isActive[msg.sender];
        myRegistrationTime = registrationTime[msg.sender];
        amIRegistered = isRegistered[msg.sender];
        
        return (myBalance, myName, myActiveStatus, myRegistrationTime, amIRegistered);
    }
    
    /**
     * @dev 시스템 통계 정보
     * @return totalUsers 총 사용자 수
     * @return activeUsers 활성 사용자 수
     * @return totalBalance 전체 잔액 합계
     * @return totalAllowances 총 권한 승인 수
     */
    function getSystemStats() external view returns (
        uint256 totalUsers,
        uint256 activeUsers,
        int totalBalance,
        uint256 totalAllowances
    ) {
        totalUsers = allUsers.length;
        activeUsers = this.getActiveUserCount();
        totalBalance = this.getTotalBalance();
        
        // 권한 승인 총 개수 계산 (예시)
        totalAllowances = 0; // 실제로는 별도 카운터 필요
        
        return (totalUsers, activeUsers, totalBalance, totalAllowances);
    }
    
    /**
     * @dev 매핑 타입별 예제 값들 반환
     * @return balanceExample 샘플 사용자의 잔액
     * @return nameExample 샘플 사용자의 이름
     * @return activeExample 샘플 사용자의 활성 상태
     * @return allowanceExample 샘플 권한 승인량
     * @return inventoryExample 샘플 인벤토리 아이템
     */
    function getMappingExamples() external view returns (
        int balanceExample,
        string memory nameExample,
        bool activeExample,
        uint256 allowanceExample,
        uint256 inventoryExample
    ) {
        address sampleUser = allUsers.length > 0 ? allUsers[0] : msg.sender;
        
        balanceExample = balance[sampleUser];
        nameExample = userNames[sampleUser];
        activeExample = isActive[sampleUser];
        allowanceExample = allowances[sampleUser][msg.sender];
        inventoryExample = inventory[sampleUser]["weapons"][1];
        
        return (balanceExample, nameExample, activeExample, allowanceExample, inventoryExample);
    }
}