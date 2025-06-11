//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// Inheritance Contract - 상속 개념 종합 예제
// ===============================================
// 
// 📌 상속(Inheritance) 개념:
//   - 기존 컨트랙트의 속성과 메서드를 다른 컨트랙트가 물려받는 것
//   - 코드 재사용성을 높이고 중복을 줄임
//   - is 키워드를 사용하여 상속 관계 정의
//   - 부모 컨트랙트의 생성자 호출 가능
//   - 함수 오버라이딩을 통한 기능 확장/변경 가능
//
// 🔗 상속 종류:
//   - 단일 상속: 하나의 부모 컨트랙트만 상속
//   - 다중 상속: 여러 부모 컨트랙트 동시 상속
//   - 계층적 상속: 상속받은 컨트랙트가 다시 상속됨
//   - 하이브리드 상속: 위 방식들의 조합
//
// 💡 주요 키워드:
//   - virtual: 함수가 오버라이드 가능함을 표시
//   - override: 부모 함수를 재정의함을 표시
//   - super: 부모 컨트랙트의 함수 호출
//   - abstract: 추상 컨트랙트 (인스턴스 생성 불가)
//   - interface: 인터페이스 정의 (구현체 없음)
// ===============================================

/**
 * @dev 기본 차량 부모 컨트랙트
 * @notice 모든 차량의 공통 속성과 기능을 정의
 */
contract Car {
    // 상태 변수들
    string internal vehicleType;    // internal: 상속받은 컨트랙트에서 접근 가능
    uint8 internal doorCount;
    address public owner;           // public: 모든 곳에서 접근 가능
    uint256 public price;
    bool public isRunning;
    
    // 이벤트 정의
    event CarStarted(address indexed owner, string vehicleType);
    event CarStopped(address indexed owner, string vehicleType);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev 생성자 - 차량 기본 정보 설정
     * @param _vehicleType 차량 타입 (예: "sedan", "suv", "hatchback")
     * @param _doorCount 문 개수
     * @param _price 차량 가격 (wei 단위)
     */
    constructor(string memory _vehicleType, uint8 _doorCount, uint256 _price) {
        require(_doorCount > 0 && _doorCount <= 10, "Invalid door count");
        require(_price > 0, "Price must be greater than 0");
        require(bytes(_vehicleType).length > 0, "Vehicle type cannot be empty");
        
        vehicleType = _vehicleType;
        doorCount = _doorCount;
        price = _price;
        owner = msg.sender;
        isRunning = false;
        
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    /**
     * @dev 차량 시동 걸기 (가상 함수 - 오버라이드 가능)
     * @notice 소유자만 시동을 걸 수 있음
     */
    function startEngine() public virtual {
        require(msg.sender == owner, "Only owner can start the engine");
        require(!isRunning, "Engine is already running");
        
        isRunning = true;
        emit CarStarted(owner, vehicleType);
    }
    
    /**
     * @dev 차량 시동 끄기 (가상 함수 - 오버라이드 가능)
     */
    function stopEngine() public virtual {
        require(msg.sender == owner, "Only owner can stop the engine");
        require(isRunning, "Engine is already stopped");
        
        isRunning = false;
        emit CarStopped(owner, vehicleType);
    }
    
    /**
     * @dev 문 개수 조회 함수
     * @return doorCount 차량의 문 개수
     */
    function getDoorCount() public view returns (uint8) {
        return doorCount;
    }
    
    /**
     * @dev 차량 타입 조회 함수
     * @return vehicleType 차량 타입
     */
    function getVehicleType() public view returns (string memory) {
        return vehicleType;
    }
    
    /**
     * @dev 차량 정보 요약 조회
     * @return vehicleType_ 차량 타입
     * @return doorCount_ 문 개수
     * @return price_ 가격
     * @return isRunning_ 시동 상태
     */
    function getCarInfo() public view virtual returns (
        string memory vehicleType_,
        uint8 doorCount_,
        uint256 price_,
        bool isRunning_
    ) {
        return (vehicleType, doorCount, price, isRunning);
    }
    
    /**
     * @dev 소유권 이전 함수
     * @param newOwner 새로운 소유자 주소
     */
    function transferOwnership(address newOwner) public virtual {
        require(msg.sender == owner, "Only current owner can transfer ownership");
        require(newOwner != address(0), "New owner cannot be zero address");
        require(!isRunning, "Cannot transfer while engine is running");
        
        address previousOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}

/**
 * @dev 벤츠 컨트랙트 - Car 컨트랙트를 상속
 * @notice 벤츠 특화 기능들을 추가로 구현
 */
contract Benz is Car {
    // 벤츠 특화 상태 변수들
    string public model;
    bool public hasAutoPilot;
    uint256 public mileage;
    
    // 벤츠 전용 이벤트
    event AutoPilotActivated(address indexed owner, string model);
    event MileageUpdated(uint256 oldMileage, uint256 newMileage);
    
    /**
     * @dev 벤츠 생성자
     * @param _model 벤츠 모델명 (예: "E-Class", "S-Class", "GLE")
     * @param _hasAutoPilot 자율주행 기능 여부
     */
    constructor(string memory _model, bool _hasAutoPilot) 
        Car("luxury-sedan", 4, 50 ether) // 부모 생성자 호출
    {
        require(bytes(_model).length > 0, "Model cannot be empty");
        
        model = _model;
        hasAutoPilot = _hasAutoPilot;
        mileage = 0;
    }
    
    /**
     * @dev 시동 걸기 함수 오버라이드 (벤츠 특화 기능 추가)
     * @notice 부모의 startEngine 기능 + 벤츠 특화 기능
     */
    function startEngine() public override {
        // 부모 함수 호출
        super.startEngine();
        
        // 벤츠 특화 로직 추가
        if (hasAutoPilot) {
            emit AutoPilotActivated(owner, model);
        }
    }
    
    /**
     * @dev 자율주행 활성화 함수 (벤츠 전용)
     */
    function activateAutoPilot() public {
        require(msg.sender == owner, "Only owner can activate autopilot");
        require(hasAutoPilot, "This model does not have autopilot");
        require(isRunning, "Engine must be running to activate autopilot");
        
        emit AutoPilotActivated(owner, model);
    }
    
    /**
     * @dev 주행거리 업데이트 함수
     * @param additionalMiles 추가 주행거리
     */
    function updateMileage(uint256 additionalMiles) public {
        require(msg.sender == owner, "Only owner can update mileage");
        require(additionalMiles > 0, "Additional miles must be positive");
        
        uint256 oldMileage = mileage;
        mileage += additionalMiles;
        
        emit MileageUpdated(oldMileage, mileage);
    }
    
    /**
     * @dev 차량 정보 조회 오버라이드 (벤츠 추가 정보 포함)
     */
    function getCarInfo() public view override returns (
        string memory vehicleType_,
        uint8 doorCount_,
        uint256 price_,
        bool isRunning_
    ) {
        return super.getCarInfo(); // 부모 함수 결과 반환
    }
    
    /**
     * @dev 벤츠 특화 정보 조회
     * @return model_ 모델명
     * @return hasAutoPilot_ 자율주행 기능 여부
     * @return mileage_ 현재 주행거리
     */
    function getBenzInfo() public view returns (
        string memory model_,
        bool hasAutoPilot_,
        uint256 mileage_
    ) {
        return (model, hasAutoPilot, mileage);
    }
}

/**
 * @dev 아우디 컨트랙트 - Car 컨트랙트를 상속
 * @notice 아우디 특화 기능들을 구현
 */
contract Audi is Car {
    // 아우디 특화 상태 변수들
    string public model;
    bool public hasQuattro;      // 콰트로 시스템 (4륜구동)
    uint8 public performanceLevel; // 성능 레벨 (1-10)
    
    // 아우디 전용 이벤트
    event QuattroActivated(address indexed owner, string model);
    event PerformanceModeChanged(uint8 oldLevel, uint8 newLevel);
    
    /**
     * @dev 아우디 생성자
     * @param _model 아우디 모델명 (예: "A4", "Q7", "R8")
     * @param _hasQuattro 콰트로 시스템 여부
     * @param _performanceLevel 성능 레벨 (1-10)
     */
    constructor(
        string memory _model, 
        bool _hasQuattro, 
        uint8 _performanceLevel
    ) Car("sport-sedan", 4, 40 ether) // 부모 생성자 호출
    {
        require(bytes(_model).length > 0, "Model cannot be empty");
        require(_performanceLevel >= 1 && _performanceLevel <= 10, "Performance level must be 1-10");
        
        model = _model;
        hasQuattro = _hasQuattro;
        performanceLevel = _performanceLevel;
    }
    
    /**
     * @dev 시동 걸기 함수 오버라이드 (아우디 특화 기능 추가)
     */
    function startEngine() public override {
        // 부모 함수 호출
        super.startEngine();
        
        // 아우디 특화 로직
        if (hasQuattro) {
            emit QuattroActivated(owner, model);
        }
    }
    
    /**
     * @dev 성능 모드 변경 함수 (아우디 전용)
     * @param newLevel 새로운 성능 레벨 (1-10)
     */
    function changePerformanceMode(uint8 newLevel) public {
        require(msg.sender == owner, "Only owner can change performance mode");
        require(newLevel >= 1 && newLevel <= 10, "Performance level must be 1-10");
        require(isRunning, "Engine must be running to change performance mode");
        
        uint8 oldLevel = performanceLevel;
        performanceLevel = newLevel;
        
        emit PerformanceModeChanged(oldLevel, newLevel);
    }
    
    /**
     * @dev 콰트로 시스템 활성화 함수
     */
    function activateQuattro() public {
        require(msg.sender == owner, "Only owner can activate Quattro");
        require(hasQuattro, "This model does not have Quattro system");
        require(isRunning, "Engine must be running to activate Quattro");
        
        emit QuattroActivated(owner, model);
    }
    
    /**
     * @dev 아우디 특화 정보 조회
     * @return model_ 모델명
     * @return hasQuattro_ 콰트로 시스템 여부
     * @return performanceLevel_ 현재 성능 레벨
     */
    function getAudiInfo() public view returns (
        string memory model_,
        bool hasQuattro_,
        uint8 performanceLevel_
    ) {
        return (model, hasQuattro, performanceLevel);
    }
}

/**
 * @dev BMW 컨트랙트 - Car 컨트랙트를 상속하며 다중 상속 예제
 * @notice BMW 특화 기능과 추가 인터페이스 구현
 */
contract BMW is Car {
    // BMW 특화 상태 변수들
    string public model;
    bool public hasXDrive;       // xDrive 시스템
    string public series;        // BMW 시리즈 (1, 3, 5, 7, X, Z, M)
    uint256 public enginePower;  // 엔진 출력 (HP)
    
    // BMW 전용 이벤트
    event XDriveActivated(address indexed owner, string model);
    event SportModeActivated(address indexed owner, uint256 enginePower);
    
    /**
     * @dev BMW 생성자
     * @param _model BMW 모델명
     * @param _series BMW 시리즈
     * @param _hasXDrive xDrive 시스템 여부
     * @param _enginePower 엔진 출력
     */
    constructor(
        string memory _model,
        string memory _series,
        bool _hasXDrive,
        uint256 _enginePower
    ) Car("premium-car", 4, 45 ether) // 부모 생성자 호출
    {
        require(bytes(_model).length > 0, "Model cannot be empty");
        require(bytes(_series).length > 0, "Series cannot be empty");
        require(_enginePower > 0, "Engine power must be positive");
        
        model = _model;
        series = _series;
        hasXDrive = _hasXDrive;
        enginePower = _enginePower;
    }
    
    /**
     * @dev 스포츠 모드 활성화 (BMW 전용)
     */
    function activateSportMode() public {
        require(msg.sender == owner, "Only owner can activate sport mode");
        require(isRunning, "Engine must be running");
        
        emit SportModeActivated(owner, enginePower);
    }
    
    /**
     * @dev xDrive 시스템 활성화
     */
    function activateXDrive() public {
        require(msg.sender == owner, "Only owner can activate xDrive");
        require(hasXDrive, "This model does not have xDrive system");
        require(isRunning, "Engine must be running");
        
        emit XDriveActivated(owner, model);
    }
    
    /**
     * @dev BMW 특화 정보 조회
     */
    function getBMWInfo() public view returns (
        string memory model_,
        string memory series_,
        bool hasXDrive_,
        uint256 enginePower_
    ) {
        return (model, series, hasXDrive, enginePower);
    }
    
    /**
     * @dev 소유권 이전 오버라이드 (BMW 특화 로직 추가)
     */
    function transferOwnership(address newOwner) public override {
        require(!isRunning, "BMW cannot transfer ownership while running");
        
        // 부모 함수 호출
        super.transferOwnership(newOwner);
        
        // BMW 특화 로직 (예: 등록 시스템 업데이트 등)
        // 여기서는 이벤트만 발생
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}