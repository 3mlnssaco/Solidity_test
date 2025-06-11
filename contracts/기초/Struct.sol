//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ===============================================
// Struct Contract - 구조체(Structure) 타입 예제
// ===============================================
// 
// 📌 구조체(Struct) 개념:
//   - 여러 다른 타입의 변수를 하나의 단위로 묶는 사용자 정의 타입
//   - 객체지향 프로그래밍의 클래스와 유사하지만 함수는 포함하지 않음
//   - 관련된 데이터를 논리적으로 그룹화하여 코드 가독성 향상
//   - 복잡한 데이터 구조를 표현하는 데 최적화됨
//   - 매핑, 배열 등과 함께 사용하여 고급 데이터 구조 구현
//
// 💡 구조체 특징:
//   - 메모리 효율적인 데이터 패킹
//   - 참조 타입 (storage, memory, calldata 위치 지정 필요)
//   - 중첩 구조체 가능 (구조체 안에 다른 구조체)
//   - 생성자와 같은 초기화 문법 지원
//   - 함수 매개변수 및 반환값으로 사용 가능
//
// 🔗 실용적 활용 사례:
//   - 사용자 프로필: 이름, 나이, 주소, 등급 등
//   - 상품 정보: 이름, 가격, 카테고리, 재고 등
//   - 거래 기록: 발신자, 수신자, 금액, 시간 등
//   - NFT 메타데이터: 토큰ID, 소유자, 속성, URI 등
// ===============================================

/**
 * @title Struct
 * @dev 구조체를 활용한 상품 관리 시스템 예제 컨트랙트
 * @notice 구조체 정의, 생성, 조작, 저장 등의 모든 기능을 시연
 */
contract Struct {
    // ========== 구조체 정의 ==========
    
    /**
     * @dev 상품 정보를 나타내는 기본 구조체
     * @notice 전자상거래에서 상품을 표현하는 데이터 구조
     * 
     * 구조체 설계 원칙:
     * - 관련 데이터를 논리적으로 그룹화
     * - 적절한 타입 선택으로 메모리 효율성 확보
     * - 확장 가능성을 고려한 구조 설계
     * - 검증 가능한 데이터 필드 포함
     */
    struct Product {
        string name;            // 상품명 (동적 크기)
        uint price;            // 가격 (wei 단위)
        string category;       // 카테고리 (의류, 전자제품 등)
        bool isAvailable;      // 판매 가능 여부
        address seller;        // 판매자 주소
        uint256 stock;         // 재고 수량
        uint256 createdAt;     // 등록 시간
        uint256 updatedAt;     // 최종 수정 시간
    }
    
    /**
     * @dev 사용자 정보를 나타내는 구조체
     * @notice 사용자 프로필 및 권한 관리용 데이터 구조
     */
    struct User {
        string username;       // 사용자명
        string email;         // 이메일 주소
        bool isActive;        // 활성 상태
        uint256 joinedAt;     // 가입 시간
        uint256 totalPurchases; // 총 구매 금액
        UserLevel level;      // 사용자 등급 (enum 활용)
    }
    
    /**
     * @dev 사용자 등급을 나타내는 열거형
     * @notice 구조체와 enum의 조합 예제
     */
    enum UserLevel { Bronze, Silver, Gold, Platinum }
    
    /**
     * @dev 주문 정보를 나타내는 중첩 구조체
     * @notice 다른 구조체를 포함하는 복합 구조체 예제
     */
    struct Order {
        uint256 orderId;      // 주문 ID
        address buyer;        // 구매자 주소
        Product product;      // 주문한 상품 정보 (중첩 구조체)
        uint256 quantity;     // 주문 수량
        uint256 totalPrice;   // 총 주문 금액
        OrderStatus status;   // 주문 상태
        uint256 orderDate;    // 주문 일시
        string deliveryAddress; // 배송 주소
    }
    
    /**
     * @dev 주문 상태를 나타내는 열거형
     */
    enum OrderStatus { Pending, Confirmed, Shipped, Delivered, Cancelled }
    
    /**
     * @dev 배송 정보 구조체
     * @notice 주문과 연관된 배송 추적 정보
     */
    struct DeliveryInfo {
        uint256 orderId;      // 연관된 주문 ID
        string trackingNumber; // 송장 번호
        address courier;      // 배송업체 주소
        uint256 shippedAt;    // 발송 시간
        uint256 estimatedDelivery; // 예상 배송 시간
        bool isDelivered;     // 배송 완료 여부
    }
    
    // ========== 상태 변수 ==========
    
    /**
     * @dev 메인 상품 (단일 구조체 인스턴스)
     * @notice 구조체의 기본 사용법 시연용
     */
    Product public mainProduct;
    
    /**
     * @dev 모든 상품을 저장하는 동적 배열
     * @notice 구조체 배열 사용 예제
     */
    Product[] public products;
    
    /**
     * @dev 상품 ID별 상품 정보 매핑
     * @notice 구조체와 매핑의 조합 사용
     */
    mapping(uint256 => Product) public productById;
    
    /**
     * @dev 사용자 주소별 사용자 정보 매핑
     */
    mapping(address => User) public users;
    
    /**
     * @dev 주문 ID별 주문 정보 매핑
     */
    mapping(uint256 => Order) public orders;
    
    /**
     * @dev 주문 ID별 배송 정보 매핑
     */
    mapping(uint256 => DeliveryInfo) public deliveries;
    
    /**
     * @dev 최대 상품 개수 제한
     * @notice 원래 코드의 변수를 유지하되 용도 명확화
     */
    uint public maxProductCount;
    
    /**
     * @dev 다음 상품 ID (자동 증가)
     */
    uint256 public nextProductId = 1;
    
    /**
     * @dev 다음 주문 ID (자동 증가)
     */
    uint256 public nextOrderId = 1;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 새 상품 등록 시 발생하는 이벤트
     */
    event ProductCreated(uint256 indexed productId, string name, uint256 price, address indexed seller);
    
    /**
     * @dev 상품 정보 업데이트 시 발생하는 이벤트
     */
    event ProductUpdated(uint256 indexed productId, string name, uint256 price);
    
    /**
     * @dev 새 사용자 등록 시 발생하는 이벤트
     */
    event UserRegistered(address indexed user, string username, UserLevel level);
    
    /**
     * @dev 새 주문 생성 시 발생하는 이벤트
     */
    event OrderCreated(uint256 indexed orderId, address indexed buyer, uint256 indexed productId, uint256 quantity);
    
    /**
     * @dev 주문 상태 변경 시 발생하는 이벤트
     */
    event OrderStatusChanged(uint256 indexed orderId, OrderStatus oldStatus, OrderStatus newStatus);
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 초기 설정 및 기본 데이터 생성
     * 
     * 구조체 초기화 방법들:
     * 1. 생성자 문법: Product({필드명: 값, ...})
     * 2. 순서대로 할당: Product(값1, 값2, ...)
     * 3. 필드별 개별 할당: product.name = "값"
     */
    constructor() { 
        // 최대 상품 개수 초기화 (원래 코드 유지)
        maxProductCount = 1000;
        
        // 컨트랙트 배포자를 첫 번째 사용자로 등록
        _registerUser(msg.sender, "Admin", "admin@example.com", UserLevel.Platinum);
        
        // 초기 메인 상품 설정 (원래 코드 개선)
        initProduct();
    }
    
    // ========== 구조체 생성 및 조작 함수들 ==========
    
    /**
     * @dev 메인 상품을 초기화하는 함수 (원래 코드 개선)
     * @notice 구조체 생성자 문법 사용 예제
     */
    function initProduct() public {
        // 구조체 생성 방법 1: 생성자 문법 (권장)
        // 필드명을 명시하여 가독성과 안전성 확보
        Product memory firstProduct = Product({
            name: "toy1",
            price: 10,
            category: "Toys",
            isAvailable: true,
            seller: msg.sender,
            stock: 100,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });
        
        // storage에 할당
        mainProduct = firstProduct;
    }
    
    /**
     * @dev 메인 상품 정보 설정 함수 (원래 코드 개선)
     * @param _name 상품명
     * @param _price 가격
     * @notice 구조체 필드 직접 접근 및 수정
     */
    function setMainProduct(string memory _name, uint _price) public {
        require(bytes(_name).length > 0, "Product name cannot be empty");
        require(_price > 0, "Price must be greater than 0");
        
        // 구조체 필드 직접 수정
        mainProduct.name = _name;
        mainProduct.price = _price;
        mainProduct.updatedAt = block.timestamp; // 수정 시간 갱신
    }
    
    /**
     * @dev 메인 상품 가격 반환 함수 (원래 코드 유지)
     * @return uint 메인 상품의 현재 가격
     */
    function getMainProductPrice() public view returns (uint) {
        return mainProduct.price;
    }
    
    /**
     * @dev 새로운 상품 등록
     * @param _name 상품명
     * @param _price 가격 (wei 단위)
     * @param _category 카테고리
     * @param _stock 초기 재고
     * @return productId 생성된 상품의 ID
     */
    function createProduct(
        string memory _name, 
        uint _price, 
        string memory _category, 
        uint256 _stock
    ) external returns (uint256 productId) {
        require(bytes(_name).length > 0, "Product name required");
        require(_price > 0, "Price must be positive");
        require(_stock > 0, "Stock must be positive");
        require(products.length < maxProductCount, "Maximum product limit reached");
        
        productId = nextProductId++;
        
        // 새 상품 구조체 생성
        Product memory newProduct = Product({
            name: _name,
            price: _price,
            category: _category,
            isAvailable: true,
            seller: msg.sender,
            stock: _stock,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });
        
        // 배열과 매핑에 동시 저장
        products.push(newProduct);
        productById[productId] = newProduct;
        
        emit ProductCreated(productId, _name, _price, msg.sender);
        return productId;
    }
    
    /**
     * @dev 사용자 등록
     * @param _username 사용자명
     * @param _email 이메일
     * @param _level 사용자 등급
     */
    function registerUser(string memory _username, string memory _email, UserLevel _level) external {
        require(!users[msg.sender].isActive, "User already registered");
        _registerUser(msg.sender, _username, _email, _level);
    }
    
    /**
     * @dev 내부 사용자 등록 함수
     */
    function _registerUser(address _user, string memory _username, string memory _email, UserLevel _level) internal {
        users[_user] = User({
            username: _username,
            email: _email,
            isActive: true,
            joinedAt: block.timestamp,
            totalPurchases: 0,
            level: _level
        });
        
        emit UserRegistered(_user, _username, _level);
    }
    
    /**
     * @dev 상품 주문 생성
     * @param _productId 주문할 상품 ID
     * @param _quantity 주문 수량
     * @param _deliveryAddress 배송 주소
     * @return orderId 생성된 주문 ID
     */
    function createOrder(
        uint256 _productId, 
        uint256 _quantity, 
        string memory _deliveryAddress
    ) external payable returns (uint256 orderId) {
        require(users[msg.sender].isActive, "User not registered");
        require(_quantity > 0, "Quantity must be positive");
        require(bytes(_deliveryAddress).length > 0, "Delivery address required");
        
        Product storage product = productById[_productId];
        require(product.isAvailable, "Product not available");
        require(product.stock >= _quantity, "Insufficient stock");
        
        uint256 totalPrice = product.price * _quantity;
        require(msg.value >= totalPrice, "Insufficient payment");
        
        orderId = nextOrderId++;
        
        // 주문 정보 생성 (중첩 구조체 사용)
        orders[orderId] = Order({
            orderId: orderId,
            buyer: msg.sender,
            product: product, // 구조체 복사
            quantity: _quantity,
            totalPrice: totalPrice,
            status: OrderStatus.Pending,
            orderDate: block.timestamp,
            deliveryAddress: _deliveryAddress
        });
        
        // 재고 차감
        productById[_productId].stock -= _quantity;
        
        // 사용자 구매 금액 누적
        users[msg.sender].totalPurchases += totalPrice;
        
        // 잔돈 반환
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
        
        emit OrderCreated(orderId, msg.sender, _productId, _quantity);
        return orderId;
    }
    
    /**
     * @dev 주문 상태 변경
     * @param _orderId 주문 ID
     * @param _newStatus 새로운 상태
     */
    function updateOrderStatus(uint256 _orderId, OrderStatus _newStatus) external {
        require(orders[_orderId].orderId != 0, "Order does not exist");
        require(
            orders[_orderId].product.seller == msg.sender, 
            "Only seller can update order status"
        );
        
        OrderStatus oldStatus = orders[_orderId].status;
        orders[_orderId].status = _newStatus;
        
        emit OrderStatusChanged(_orderId, oldStatus, _newStatus);
    }
    
    /**
     * @dev 배송 정보 등록
     * @param _orderId 주문 ID
     * @param _trackingNumber 송장 번호
     * @param _estimatedDelivery 예상 배송 시간
     */
    function createDeliveryInfo(
        uint256 _orderId,
        string memory _trackingNumber,
        uint256 _estimatedDelivery
    ) external {
        require(orders[_orderId].orderId != 0, "Order does not exist");
        require(
            orders[_orderId].product.seller == msg.sender,
            "Only seller can create delivery info"
        );
        require(orders[_orderId].status == OrderStatus.Confirmed, "Order must be confirmed first");
        
        deliveries[_orderId] = DeliveryInfo({
            orderId: _orderId,
            trackingNumber: _trackingNumber,
            courier: msg.sender,
            shippedAt: block.timestamp,
            estimatedDelivery: _estimatedDelivery,
            isDelivered: false
        });
        
        // 주문 상태를 배송 중으로 변경
        orders[_orderId].status = OrderStatus.Shipped;
    }
    
    // ========== 조회 함수들 ==========
    
    /**
     * @dev 메인 상품 전체 정보 조회
     * @return Product 메인 상품 구조체 전체
     */
    function getMainProduct() external view returns (Product memory) {
        return mainProduct;
    }
    
    /**
     * @dev 특정 상품 정보 조회
     * @param _productId 상품 ID
     * @return Product 해당 상품의 구조체 정보
     */
    function getProduct(uint256 _productId) external view returns (Product memory) {
        require(productById[_productId].seller != address(0), "Product does not exist");
        return productById[_productId];
    }
    
    /**
     * @dev 사용자 정보 조회
     * @param _user 사용자 주소
     * @return User 해당 사용자의 구조체 정보
     */
    function getUser(address _user) external view returns (User memory) {
        require(users[_user].isActive, "User not found");
        return users[_user];
    }
    
    /**
     * @dev 주문 정보 조회
     * @param _orderId 주문 ID
     * @return Order 해당 주문의 구조체 정보
     */
    function getOrder(uint256 _orderId) external view returns (Order memory) {
        require(orders[_orderId].orderId != 0, "Order does not exist");
        return orders[_orderId];
    }
    
    /**
     * @dev 전체 상품 목록 조회
     * @return Product[] 모든 상품의 배열
     */
    function getAllProducts() external view returns (Product[] memory) {
        return products;
    }
    
    /**
     * @dev 판매 가능한 상품만 필터링하여 조회
     * @return availableProducts 판매 가능한 상품들의 배열
     */
    function getAvailableProducts() external view returns (Product[] memory availableProducts) {
        // 판매 가능한 상품 개수 계산
        uint availableCount = 0;
        for (uint i = 0; i < products.length; i++) {
            if (products[i].isAvailable && products[i].stock > 0) {
                availableCount++;
            }
        }
        
        // 결과 배열 생성
        availableProducts = new Product[](availableCount);
        uint currentIndex = 0;
        
        for (uint i = 0; i < products.length; i++) {
            if (products[i].isAvailable && products[i].stock > 0) {
                availableProducts[currentIndex] = products[i];
                currentIndex++;
            }
        }
        
        return availableProducts;
    }
    
    /**
     * @dev 특정 카테고리의 상품 검색
     * @param _category 검색할 카테고리
     * @return categoryProducts 해당 카테고리의 상품들
     */
    function getProductsByCategory(string memory _category) external view returns (Product[] memory categoryProducts) {
        uint categoryCount = 0;
        
        // 카테고리별 상품 개수 계산
        for (uint i = 0; i < products.length; i++) {
            if (keccak256(abi.encodePacked(products[i].category)) == keccak256(abi.encodePacked(_category))) {
                categoryCount++;
            }
        }
        
        // 결과 배열 생성 및 채우기
        categoryProducts = new Product[](categoryCount);
        uint currentIndex = 0;
        
        for (uint i = 0; i < products.length; i++) {
            if (keccak256(abi.encodePacked(products[i].category)) == keccak256(abi.encodePacked(_category))) {
                categoryProducts[currentIndex] = products[i];
                currentIndex++;
            }
        }
        
        return categoryProducts;
    }
    
    /**
     * @dev 사용자별 주문 이력 조회
     * @param _user 사용자 주소
     * @return userOrders 해당 사용자의 모든 주문
     */
    function getUserOrders(address _user) external view returns (Order[] memory userOrders) {
        uint userOrderCount = 0;
        
        // 사용자 주문 개수 계산
        for (uint256 i = 1; i < nextOrderId; i++) {
            if (orders[i].buyer == _user) {
                userOrderCount++;
            }
        }
        
        // 결과 배열 생성 및 채우기
        userOrders = new Order[](userOrderCount);
        uint currentIndex = 0;
        
        for (uint256 i = 1; i < nextOrderId; i++) {
            if (orders[i].buyer == _user) {
                userOrders[currentIndex] = orders[i];
                currentIndex++;
            }
        }
        
        return userOrders;
    }
    
    // ========== 유틸리티 함수들 ==========
    
    /**
     * @dev 구조체 필드별 업데이트 예제
     * @param _productId 상품 ID
     * @param _name 새 상품명
     * @param _price 새 가격
     * @param _stock 새 재고
     */
    function updateProductDetails(
        uint256 _productId,
        string memory _name,
        uint _price,
        uint256 _stock
    ) external {
        require(productById[_productId].seller == msg.sender, "Only seller can update");
        
        // 구조체 필드 개별 업데이트
        productById[_productId].name = _name;
        productById[_productId].price = _price;
        productById[_productId].stock = _stock;
        productById[_productId].updatedAt = block.timestamp;
        
        emit ProductUpdated(_productId, _name, _price);
    }
    
    /**
     * @dev 구조체 간 데이터 복사 예제
     * @param _sourceId 원본 상품 ID
     * @param _newName 새 상품명
     * @return newProductId 복사된 새 상품 ID
     */
    function cloneProduct(uint256 _sourceId, string memory _newName) external returns (uint256 newProductId) {
        require(productById[_sourceId].seller != address(0), "Source product does not exist");
        
        // 구조체 전체 복사 후 일부 필드 수정
        Product memory clonedProduct = productById[_sourceId];
        clonedProduct.name = _newName;
        clonedProduct.seller = msg.sender;
        clonedProduct.createdAt = block.timestamp;
        clonedProduct.updatedAt = block.timestamp;
        
        newProductId = nextProductId++;
        productById[newProductId] = clonedProduct;
        products.push(clonedProduct);
        
        emit ProductCreated(newProductId, _newName, clonedProduct.price, msg.sender);
        return newProductId;
    }
    
    /**
     * @dev 시스템 통계 정보 조회
     * @return totalProducts 총 상품 수
     * @return totalUsers 총 사용자 수
     * @return totalOrders 총 주문 수
     * @return activeProducts 활성 상품 수
     */
    function getSystemStats() external view returns (
        uint256 totalProducts,
        uint256 totalUsers,
        uint256 totalOrders,
        uint256 activeProducts
    ) {
        totalProducts = products.length;
        totalOrders = nextOrderId - 1;
        
        // 활성 상품 개수 계산
        for (uint i = 0; i < products.length; i++) {
            if (products[i].isAvailable && products[i].stock > 0) {
                activeProducts++;
            }
        }
        
        // 참고: 사용자 수는 등록된 사용자를 별도 배열로 관리해야 정확히 계산 가능
        // 여기서는 간단화를 위해 0으로 반환
        totalUsers = 0;
        
        return (totalProducts, totalUsers, totalOrders, activeProducts);
    }
    
    /**
     * @dev 메모리 vs Storage 구조체 사용법 비교
     * @param _productId 상품 ID
     * @return memoryProduct 메모리 복사본
     * @notice 구조체 위치 지정자의 차이점 설명
     */
    function demonstrateMemoryVsStorage(uint256 _productId) external view returns (Product memory memoryProduct) {
        // Storage 참조: 원본 데이터를 직접 참조 (읽기 전용에서는 storage 사용 불가)
        // Product storage storageProduct = productById[_productId]; // view 함수에서는 불가
        
        // Memory 복사: 데이터를 메모리로 복사
        memoryProduct = productById[_productId];
        
        // Memory에서 수정해도 원본에는 영향 없음
        memoryProduct.name = "Modified in memory";
        
        return memoryProduct;
    }
}



 