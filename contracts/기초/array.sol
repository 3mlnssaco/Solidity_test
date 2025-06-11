//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ===============================================
// Array Contract - 배열(Array) 타입 종합 예제
// ===============================================
// 
// 📌 배열(Array) 개념:
//   - 같은 타입의 데이터를 순서대로 저장하는 데이터 구조
//   - 인덱스(0부터 시작)로 각 요소에 접근 가능
//   - 동적 배열: 크기가 가변적 (push/pop 가능)
//   - 고정 배열: 크기가 컴파일 시점에 결정됨
//   - 메모리 위치: storage(영구), memory(임시), calldata(읽기전용)
//
// 💡 배열 타입 분류:
//   1. 동적 배열: T[] (예: uint[], string[])
//   2. 고정 배열: T[k] (예: uint[5], bytes32[10])
//   3. 문자열 배열: string[] (UTF-8 지원)
//   4. 바이트 배열: bytes (동적), bytes32 (고정)
//   5. 구조체 배열: Struct[] (복합 데이터)
//
// 🔗 메모리 효율성:
//   - 고정 배열: 컴파일 시점 최적화, 가스 절약
//   - 동적 배열: 런타임 유연성, 약간의 오버헤드
//   - storage vs memory: 영구 저장 vs 임시 저장
//   - 배열 복사 비용 고려하여 참조 전달 활용
// ===============================================

/**
 * @title Array
 * @dev 솔리디티 배열의 모든 기능을 보여주는 종합 예제 컨트랙트
 * @notice 동적/고정 배열, CRUD 연산, 메모리 관리 등을 실습
 */
contract Array {
    
    // ========== 배열 타입 정의 ==========
    
    /**
     * @dev 동적 정수 배열
     * @notice 크기가 가변적인 정수 배열
     * 
     * 동적 배열 특징:
     * - 크기 제한 없음 (가스 한도 내에서)
     * - push() / pop() 메서드 지원
     * - length 속성으로 크기 확인
     * - 메모리 재할당 가능
     * - storage에 저장 시 해시맵 기반 저장
     */
    int[] public intList;
    
    /**
     * @dev 고정 크기 정수 배열 (3개 요소)
     * @notice 컴파일 시점에 크기가 결정되는 배열
     * 
     * 고정 배열 특징:
     * - 크기 변경 불가 (3개 요소 고정)
     * - push/pop 메서드 없음
     * - 가스 효율적 (사전 할당)
     * - 인덱스 범위 검사 (0-2)
     * - 메모리 레이아웃 최적화
     */
    int[3] public int3List;
    
    /**
     * @dev 동적 문자열 배열
     * @notice 가변 길이 문자열들을 저장하는 배열
     */
    string[] public stringList;
    
    /**
     * @dev 동적 주소 배열
     * @notice 주소들을 저장하는 동적 배열 (화이트리스트 등에 활용)
     */
    address[] public addressList;
    
    /**
     * @dev 고정 크기 주소 배열 (관리자 목록)
     * @notice 최대 5명의 관리자 주소를 저장
     */
    address[5] public adminList;
    
    // ========== 구조체 정의 ==========
    
    /**
     * @dev 상품 정보를 나타내는 구조체
     * @notice 배열에 저장할 복합 데이터 타입
     */
    struct Product {
        string name;        // 상품명
        uint price;         // 가격 (wei 단위)
        bool isAvailable;   // 판매 가능 여부
        address seller;     // 판매자 주소
        uint256 timestamp;  // 등록 시간
    }
    
    /**
     * @dev 동적 상품 배열
     * @notice 구조체를 요소로 하는 동적 배열
     */
    Product[] public products;
    
    /**
     * @dev 고정 크기 상품 배열 (인기 상품 5개)
     * @notice 고정된 개수의 인기 상품 저장
     */
    Product[5] public featuredProducts;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 배열 요소 추가 시 발생하는 이벤트
     */
    event ElementAdded(string indexed arrayType, uint256 newLength);
    
    /**
     * @dev 배열 요소 제거 시 발생하는 이벤트
     */
    event ElementRemoved(string indexed arrayType, uint256 newLength);
    
    /**
     * @dev 상품 등록 시 발생하는 이벤트
     */
    event ProductAdded(string indexed name, uint256 price, address indexed seller);
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 초기 배열 데이터 설정
     * 
     * 생성자에서의 배열 초기화:
     * - 고정 배열: 직접 할당 가능
     * - 동적 배열: push() 메서드 사용
     * - 구조체 배열: 구조체 생성 후 추가
     */
    constructor() {
        // ========== 고정 배열 초기화 ==========
        // 고정 배열에 직접 값 할당
        // 배열 리터럴 사용: [값1, 값2, 값3]
        int3List = [int(1), int(2), int(3)];
        
        // ========== 동적 배열 초기화 ==========
        // push() 메서드로 동적 배열에 요소 추가
        // 각 push()는 배열 끝에 새 요소 추가
        intList.push(1);
        intList.push(2);
        intList.push(3);
        intList.push(4);
        intList.push(5);
        
        // 문자열 배열 초기화
        stringList.push("first");
        stringList.push("second");
        stringList.push("third");
        
        // 주소 배열 초기화 (배포자와 몇 개 테스트 주소)
        addressList.push(msg.sender);
        addressList.push(address(0x1));
        addressList.push(address(0x2));
        
        // 관리자 배열 초기화 (첫 번째 슬롯만)
        adminList[0] = msg.sender;
        
        // ========== 배열 요소 삭제 예제 ==========
        // delete 키워드: 특정 인덱스의 값을 기본값으로 재설정
        // 주의: 배열 크기는 변경되지 않음 (0으로만 설정)
        delete intList[1]; // intList[1]이 0이 됨
        
        // pop() 메서드: 마지막 요소를 완전히 제거
        // 배열 크기도 함께 감소
        intList.pop(); // 마지막 요소(5) 제거, 크기 4로 감소
    }
    
    // ========== 동적 배열 조작 함수들 ==========
    
    /**
     * @dev 정수 배열에 새 요소 추가
     * @param _value 추가할 정수값
     * @notice push() 메서드 사용 예제
     */
    function addToIntList(int _value) external {
        // push(): 배열 끝에 새 요소 추가
        // 배열 크기 자동 증가
        // 반환값: 새로운 배열 길이
        intList.push(_value);
        
        emit ElementAdded("intList", intList.length);
    }
    
    /**
     * @dev 정수 배열의 마지막 요소 제거
     * @return removedValue 제거된 값
     * @notice pop() 메서드 사용 예제
     */
    function removeFromIntList() external returns (int removedValue) {
        require(intList.length > 0, "Array is empty");
        
        // pop(): 마지막 요소 제거 및 반환
        // 배열 크기 자동 감소
        // 빈 배열에서 호출 시 revert
        removedValue = intList[intList.length - 1];
        intList.pop();
        
        emit ElementRemoved("intList", intList.length);
        return removedValue;
    }
    
    /**
     * @dev 특정 인덱스의 요소 삭제 (값만 재설정)
     * @param _index 삭제할 인덱스
     * @notice delete 키워드 사용 예제
     */
    function deleteIntListElement(uint _index) external {
        require(_index < intList.length, "Index out of bounds");
        
        // delete: 해당 인덱스의 값을 기본값(0)으로 설정
        // 배열 크기는 변경되지 않음
        // 메모리에서는 해당 슬롯만 초기화
        delete intList[_index];
    }
    
    /**
     * @dev 문자열 배열에 요소 추가
     * @param _str 추가할 문자열
     */
    function addToStringList(string memory _str) external {
        stringList.push(_str);
        emit ElementAdded("stringList", stringList.length);
    }
    
    /**
     * @dev 주소 배열에 요소 추가
     * @param _addr 추가할 주소
     */
    function addToAddressList(address _addr) external {
        require(_addr != address(0), "Invalid address");
        addressList.push(_addr);
        emit ElementAdded("addressList", addressList.length);
    }
    
    // ========== 고정 배열 조작 함수들 ==========
    
    /**
     * @dev 고정 배열의 특정 인덱스에 값 설정
     * @param _index 설정할 인덱스 (0-2)
     * @param _value 설정할 값
     * @notice 고정 배열은 크기 변경 불가, 인덱스 접근만 가능
     */
    function setInt3ListElement(uint _index, int _value) external {
        require(_index < 3, "Index out of bounds for fixed array");
        
        // 고정 배열 요소 직접 할당
        // push/pop 메서드 없음
        int3List[_index] = _value;
    }
    
    /**
     * @dev 관리자 목록에 새 관리자 추가
     * @param _admin 추가할 관리자 주소
     * @notice 고정 배열에서 빈 슬롯 찾아 할당
     */
    function addAdmin(address _admin) external {
        require(_admin != address(0), "Invalid admin address");
        
        // 고정 배열에서 빈 슬롯 찾기
        for (uint i = 0; i < adminList.length; i++) {
            if (adminList[i] == address(0)) {
                adminList[i] = _admin;
                return;
            }
        }
        
        revert("Admin list is full");
    }
    
    /**
     * @dev 관리자 제거
     * @param _admin 제거할 관리자 주소
     */
    function removeAdmin(address _admin) external {
        for (uint i = 0; i < adminList.length; i++) {
            if (adminList[i] == _admin) {
                adminList[i] = address(0); // 빈 슬롯으로 설정
                return;
            }
        }
        
        revert("Admin not found");
    }
    
    // ========== 구조체 배열 조작 ==========
    
    /**
     * @dev 새 상품 등록
     * @param _name 상품명
     * @param _price 가격 (wei 단위)
     * @notice 구조체를 동적 배열에 추가하는 예제
     */
    function addProduct(string memory _name, uint _price) external {
        require(bytes(_name).length > 0, "Product name cannot be empty");
        require(_price > 0, "Price must be greater than 0");
        
        // 구조체 생성 방법 1: 직접 생성
        Product memory newProduct = Product({
            name: _name,
            price: _price,
            isAvailable: true,
            seller: msg.sender,
            timestamp: block.timestamp
        });
        
        // 구조체를 배열에 추가
        products.push(newProduct);
        
        emit ProductAdded(_name, _price, msg.sender);
    }
    
    /**
     * @dev 상품 정보 업데이트
     * @param _index 업데이트할 상품 인덱스
     * @param _price 새로운 가격
     * @param _isAvailable 판매 가능 여부
     */
    function updateProduct(uint _index, uint _price, bool _isAvailable) external {
        require(_index < products.length, "Product does not exist");
        require(products[_index].seller == msg.sender, "Only seller can update");
        
        // 구조체 필드 직접 접근 및 수정
        products[_index].price = _price;
        products[_index].isAvailable = _isAvailable;
    }
    
    /**
     * @dev 인기 상품으로 설정
     * @param _productIndex 상품 인덱스
     * @param _featuredIndex 인기 상품 슬롯 인덱스 (0-4)
     */
    function setFeaturedProduct(uint _productIndex, uint _featuredIndex) external {
        require(_productIndex < products.length, "Product does not exist");
        require(_featuredIndex < 5, "Featured index out of bounds");
        
        // 구조체 복사 (storage -> storage)
        featuredProducts[_featuredIndex] = products[_productIndex];
    }
    
    // ========== 배열 조회 함수들 ==========
    
    /**
     * @dev 정수 배열의 두 번째 요소 반환
     * @return int 두 번째 요소 값 (인덱스 1)
     * @notice 배열 인덱싱 및 경계 검사 예제
     */
    function getSecondData() public view returns (int) {
        require(intList.length > 1, "Array has less than 2 elements");
        
        // 배열 인덱싱: array[index]
        // 인덱스는 0부터 시작
        return intList[1];
    }
    
    /**
     * @dev 정수 배열의 마지막 요소 반환
     * @return int 마지막 요소 값
     * @notice 동적 배열에서 마지막 요소 접근 방법
     */
    function getLastData() public view returns (int) {
        require(intList.length > 0, "Array is empty");
        
        // 마지막 인덱스: length - 1
        // length 속성: 배열의 현재 크기
        return intList[intList.length - 1];
    }
    
    /**
     * @dev 전체 정수 배열 반환
     * @return int[] 전체 배열 (메모리 복사)
     * @notice 동적 배열 전체를 메모리로 복사하여 반환
     */
    function getIntList() external view returns (int[] memory) {
        // storage 배열을 memory로 복사
        // 큰 배열의 경우 가스 비용 주의
        return intList;
    }
    
    /**
     * @dev 정수 배열 크기 반환
     * @return uint256 배열의 현재 크기
     */
    function getIntListLength() external view returns (uint256) {
        return intList.length;
    }
    
    /**
     * @dev 문자열 배열 전체 반환
     * @return string[] 전체 문자열 배열
     */
    function getStringList() external view returns (string[] memory) {
        return stringList;
    }
    
    /**
     * @dev 주소 배열 전체 반환
     * @return address[] 전체 주소 배열
     */
    function getAddressList() external view returns (address[] memory) {
        return addressList;
    }
    
    /**
     * @dev 관리자 목록 반환
     * @return address[5] 고정 크기 관리자 배열
     */
    function getAdminList() external view returns (address[5] memory) {
        return adminList;
    }
    
    /**
     * @dev 활성 관리자 수 계산
     * @return count 유효한 관리자 주소 개수
     */
    function getActiveAdminCount() external view returns (uint count) {
        for (uint i = 0; i < adminList.length; i++) {
            if (adminList[i] != address(0)) {
                count++;
            }
        }
        return count;
    }
    
    /**
     * @dev 전체 상품 목록 반환
     * @return Product[] 모든 등록된 상품
     */
    function getAllProducts() external view returns (Product[] memory) {
        return products;
    }
    
    /**
     * @dev 판매 가능한 상품만 필터링하여 반환
     * @return availableProducts 판매 가능한 상품들의 배열
     */
    function getAvailableProducts() external view returns (Product[] memory availableProducts) {
        // 1단계: 판매 가능한 상품 개수 계산
        uint availableCount = 0;
        for (uint i = 0; i < products.length; i++) {
            if (products[i].isAvailable) {
                availableCount++;
            }
        }
        
        // 2단계: 메모리 배열 생성
        availableProducts = new Product[](availableCount);
        
        // 3단계: 판매 가능한 상품들을 새 배열에 복사
        uint currentIndex = 0;
        for (uint i = 0; i < products.length; i++) {
            if (products[i].isAvailable) {
                availableProducts[currentIndex] = products[i];
                currentIndex++;
            }
        }
        
        return availableProducts;
    }
    
    /**
     * @dev 특정 판매자의 상품 검색
     * @param _seller 검색할 판매자 주소
     * @return sellerProducts 해당 판매자의 모든 상품
     */
    function getProductsBySeller(address _seller) external view returns (Product[] memory sellerProducts) {
        // 해당 판매자의 상품 개수 계산
        uint sellerProductCount = 0;
        for (uint i = 0; i < products.length; i++) {
            if (products[i].seller == _seller) {
                sellerProductCount++;
            }
        }
        
        // 결과 배열 생성 및 채우기
        sellerProducts = new Product[](sellerProductCount);
        uint currentIndex = 0;
        for (uint i = 0; i < products.length; i++) {
            if (products[i].seller == _seller) {
                sellerProducts[currentIndex] = products[i];
                currentIndex++;
            }
        }
        
        return sellerProducts;
    }
    
    // ========== 유틸리티 함수들 ==========
    
    /**
     * @dev 배열에서 특정 값의 인덱스 찾기
     * @param _value 찾을 값
     * @return found 값이 발견되었는지 여부
     * @return index 발견된 인덱스 (found가 false면 무시)
     */
    function findIntValue(int _value) external view returns (bool found, uint index) {
        for (uint i = 0; i < intList.length; i++) {
            if (intList[i] == _value) {
                return (true, i);
            }
        }
        return (false, 0);
    }
    
    /**
     * @dev 주소가 관리자 목록에 있는지 확인
     * @param _addr 확인할 주소
     * @return bool 관리자 여부
     */
    function isAdmin(address _addr) external view returns (bool) {
        for (uint i = 0; i < adminList.length; i++) {
            if (adminList[i] == _addr) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @dev 배열 통계 정보 반환
     * @return intCount 정수 배열 크기
     * @return stringCount 문자열 배열 크기  
     * @return addressCount 주소 배열 크기
     * @return productCount 상품 배열 크기
     * @return adminCount 활성 관리자 수
     */
    function getArrayStats() external view returns (
        uint intCount,
        uint stringCount,
        uint addressCount,
        uint productCount,
        uint adminCount
    ) {
        intCount = intList.length;
        stringCount = stringList.length;
        addressCount = addressList.length;
        productCount = products.length;
        
        // 활성 관리자 수 계산
        for (uint i = 0; i < adminList.length; i++) {
            if (adminList[i] != address(0)) {
                adminCount++;
            }
        }
        
        return (intCount, stringCount, addressCount, productCount, adminCount);
    }
    
    /**
     * @dev 메모리 배열 생성 및 조작 예제
     * @param _size 생성할 배열 크기
     * @return result 초기화된 메모리 배열
     */
    function createMemoryArray(uint _size) external pure returns (uint[] memory result) {
        // 메모리에서 새 동적 배열 생성
        result = new uint[](_size);
        
        // 메모리 배열 초기화
        for (uint i = 0; i < _size; i++) {
            result[i] = i * 2; // 짝수로 초기화
        }
        
        return result;
    }
    
    /**
     * @dev 배열 요소들의 합계 계산
     * @return sum 정수 배열의 모든 요소 합계
     */
    function calculateSum() external view returns (int sum) {
        for (uint i = 0; i < intList.length; i++) {
            sum += intList[i];
        }
        return sum;
    }
}
