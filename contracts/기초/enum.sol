//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ===============================================
// Enum Contract - 열거형(Enumeration) 타입 예제
// ===============================================
// 
// 📌 열거형(Enum) 개념:
//   - 사용자 정의 타입으로 명명된 상수들의 집합
//   - 정수 값을 사람이 읽기 쉬운 이름으로 표현
//   - 0부터 시작하는 순차적 정수값을 가짐
//   - 코드 가독성과 타입 안전성 향상
//   - 상태 관리, 옵션 선택, 카테고리 분류에 활용
//
// 💡 Enum 특징:
//   - 컴파일 시점에 정수로 변환됨
//   - 가스 효율적 (uint8로 저장)
//   - 타입 안전성 보장 (잘못된 값 할당 불가)
//   - 256개까지 항목 정의 가능 (uint8 범위)
//   - 기본값: 첫 번째 항목 (인덱스 0)
//
// 🔗 실용적 활용 사례:
//   - 주문 상태: 대기, 처리중, 완료, 취소
//   - 사용자 등급: 브론즈, 실버, 골드, 플래티넘
//   - NFT 상태: 민팅, 판매, 경매, 소각
//   - 게임 상태: 시작 전, 진행중, 일시정지, 종료
// ===============================================

/**
 * @title Enum
 * @dev 열거형을 활용한 경매 시스템 예제 컨트랙트
 * @notice 경매의 다양한 상태를 enum으로 관리하는 방법 시연
 */
contract Enum {
    
    // ========== 열거형 정의 ==========
    
    /**
     * @dev 경매 상태를 나타내는 열거형
     * @notice 경매의 생명주기를 단계별로 표현
     * 
     * 각 상태의 의미:
     * - NotSale (0): 판매하지 않음 (기본 상태)
     * - Auction (1): 경매 진행중
     * - Sales (2): 즉시 구매 가능
     * - Bid (3): 입찰 접수중
     * - Sold (4): 판매 완료
     * 
     * Enum 내부 동작:
     * - 각 항목은 0부터 시작하는 정수값 할당
     * - 메모리에서는 uint8로 저장 (1바이트)
     * - 정의되지 않은 값 할당 시 컴파일 에러
     */
    enum Status {
        NotSale,    // 0: 판매 안함
        Auction,    // 1: 경매중
        Sales,      // 2: 판매중  
        Bid,        // 3: 입찰중
        Sold        // 4: 판매완료
    }
    
    // ========== 상태 변수 ==========
    
    /**
     * @dev 현재 경매 상태
     * @notice public으로 선언하여 자동 getter 함수 생성
     * 
     * 기본값: Status.NotSale (첫 번째 항목)
     * 반환값: 정수형으로 변환되어 반환 (0, 1, 2, 3, 4)
     */
    Status public auctionStatus;
    
    /**
     * @dev 상태 변경 이력을 추적하는 배열
     * @notice 경매 진행 과정을 기록하여 투명성 제공
     */
    Status[] public statusHistory;
    
    /**
     * @dev 각 상태별 진입 시간 기록
     * @notice 상태별 소요 시간 분석에 활용
     */
    mapping(Status => uint256) public statusTimestamp;
    
    /**
     * @dev 경매 시작자 주소
     * @notice 권한 관리를 위한 소유자 정보
     */
    address public auctionCreator;
    
    /**
     * @dev 현재 최고 입찰자
     * @notice 입찰 상태에서의 리더 추적
     */
    address public highestBidder;
    
    /**
     * @dev 현재 최고 입찰가
     * @notice 입찰 금액 추적
     */
    uint256 public highestBid;
    
    // ========== 이벤트 정의 ==========
    
    /**
     * @dev 상태 변경 시 발생하는 이벤트
     * @param from 이전 상태
     * @param to 새로운 상태  
     * @param timestamp 변경 시간
     * @param changer 상태를 변경한 주소
     */
    event StatusChanged(
        Status indexed from, 
        Status indexed to, 
        uint256 timestamp, 
        address indexed changer
    );
    
    /**
     * @dev 새로운 입찰 시 발생하는 이벤트
     * @param bidder 입찰자 주소
     * @param amount 입찰 금액
     * @param timestamp 입찰 시간
     */
    event BidPlaced(
        address indexed bidder, 
        uint256 amount, 
        uint256 timestamp
    );
    
    // ========== 한정자(Modifiers) ==========
    
    /**
     * @dev 경매 생성자만 실행 가능한 한정자
     */
    modifier onlyCreator() {
        require(msg.sender == auctionCreator, "Only creator can perform this action");
        _;
    }
    
    /**
     * @dev 특정 상태에서만 실행 가능한 한정자
     * @param _status 요구되는 상태
     */
    modifier onlyInStatus(Status _status) {
        require(auctionStatus == _status, "Invalid status for this action");
        _;
    }
    
    // ========== 생성자 ==========
    
    /**
     * @dev 컨트랙트 생성자
     * @notice 초기 상태 설정 및 생성자 등록
     */
    constructor() {
        auctionCreator = msg.sender;
        auctionStatus = Status.NotSale; // 기본값이지만 명시적 설정
        _recordStatusChange(Status.NotSale, Status.NotSale);
    }
    
    // ========== 상태 변경 함수들 ==========
    
    /**
     * @dev 경매를 시작하는 함수
     * @notice NotSale 상태에서 Auction 상태로 변경
     * 
     * 상태 전환 조건:
     * - 현재 상태: NotSale
     * - 호출자: 경매 생성자
     * - 결과: Auction 상태로 변경
     */
    function auctionStart() public onlyCreator onlyInStatus(Status.NotSale) {
        Status oldStatus = auctionStatus;
        auctionStatus = Status.Auction;
        _recordStatusChange(oldStatus, Status.Auction);
        
        emit StatusChanged(oldStatus, Status.Auction, block.timestamp, msg.sender);
    }
    
    /**
     * @dev 입찰 접수 상태로 변경하는 함수  
     * @notice Auction 상태에서 Bid 상태로 변경
     * 
     * 상태 전환 조건:
     * - 현재 상태: Auction
     * - 호출자: 경매 생성자
     * - 결과: Bid 상태로 변경하여 입찰 접수 시작
     */
    function startBidding() public onlyCreator onlyInStatus(Status.Auction) {
        Status oldStatus = auctionStatus;
        auctionStatus = Status.Bid;
        _recordStatusChange(oldStatus, Status.Bid);
        
        emit StatusChanged(oldStatus, Status.Bid, block.timestamp, msg.sender);
    }
    
    /**
     * @dev 즉시 판매 상태로 변경하는 함수
     * @notice 경매 대신 고정 가격 판매로 전환
     */
    function setSalesMode() public onlyCreator {
        require(
            auctionStatus == Status.NotSale || auctionStatus == Status.Auction, 
            "Cannot switch to sales mode in current status"
        );
        
        Status oldStatus = auctionStatus;
        auctionStatus = Status.Sales;
        _recordStatusChange(oldStatus, Status.Sales);
        
        emit StatusChanged(oldStatus, Status.Sales, block.timestamp, msg.sender);
    }
    
    /**
     * @dev 입찰을 처리하는 함수
     * @notice 입찰 접수 상태에서 새로운 입찰을 받음
     */
    function placeBid() public payable onlyInStatus(Status.Bid) {
        require(msg.value > highestBid, "Bid must be higher than current highest");
        require(msg.sender != auctionCreator, "Creator cannot bid on own auction");
        
        // 이전 최고 입찰자에게 환불 (실제 구현에서는 pull over push 패턴 권장)
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit BidPlaced(msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @dev 경매/판매를 완료하는 함수
     * @notice 최종 판매 완료 상태로 변경
     */
    function completeSale() public onlyCreator {
        require(
            auctionStatus == Status.Bid || auctionStatus == Status.Sales,
            "No active sale to complete"
        );
        
        if (auctionStatus == Status.Bid) {
            require(highestBidder != address(0), "No valid bids received");
        }
        
        Status oldStatus = auctionStatus;
        auctionStatus = Status.Sold;
        _recordStatusChange(oldStatus, Status.Sold);
        
        emit StatusChanged(oldStatus, Status.Sold, block.timestamp, msg.sender);
    }
    
    /**
     * @dev 경매/판매를 취소하는 함수
     * @notice 다시 판매하지 않음 상태로 되돌림
     */
    function cancelSale() public onlyCreator {
        require(auctionStatus != Status.Sold, "Cannot cancel completed sale");
        
        // 진행중인 입찰이 있다면 환불
        if (auctionStatus == Status.Bid && highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
            highestBidder = address(0);
            highestBid = 0;
        }
        
        Status oldStatus = auctionStatus;
        auctionStatus = Status.NotSale;
        _recordStatusChange(oldStatus, Status.NotSale);
        
        emit StatusChanged(oldStatus, Status.NotSale, block.timestamp, msg.sender);
    }
    
    // ========== 내부 함수 ==========
    
    /**
     * @dev 상태 변경을 기록하는 내부 함수
     * @param _from 이전 상태
     * @param _to 새로운 상태
     */
    function _recordStatusChange(Status _from, Status _to) internal {
        statusHistory.push(_to);
        statusTimestamp[_to] = block.timestamp;
    }
    
    // ========== 조회 함수들 ==========
    
    /**
     * @dev 현재 상태를 문자열로 반환
     * @return statusName 현재 상태의 이름
     * @notice enum 값을 사람이 읽기 쉬운 문자열로 변환
     */
    function getCurrentStatusName() external view returns (string memory statusName) {
        if (auctionStatus == Status.NotSale) return "Not For Sale";
        if (auctionStatus == Status.Auction) return "Auction Active";
        if (auctionStatus == Status.Sales) return "For Sale";
        if (auctionStatus == Status.Bid) return "Accepting Bids";
        if (auctionStatus == Status.Sold) return "Sold";
        return "Unknown";
    }
    
    /**
     * @dev 특정 상태인지 확인하는 함수
     * @param _status 확인할 상태
     * @return bool 현재 상태가 지정된 상태와 일치하는지 여부
     */
    function isInStatus(Status _status) external view returns (bool) {
        return auctionStatus == _status;
    }
    
    /**
     * @dev 상태 변경 이력 개수 반환
     * @return uint256 지금까지 변경된 상태의 총 개수
     */
    function getStatusHistoryLength() external view returns (uint256) {
        return statusHistory.length;
    }
    
    /**
     * @dev 특정 인덱스의 상태 이력 조회
     * @param _index 조회할 이력의 인덱스
     * @return Status 해당 인덱스의 상태
     */
    function getStatusHistoryAt(uint256 _index) external view returns (Status) {
        require(_index < statusHistory.length, "Index out of bounds");
        return statusHistory[_index];
    }
    
    /**
     * @dev 모든 가능한 상태 목록 반환
     * @return statusList 모든 enum 값들의 배열
     * @notice 프론트엔드에서 드롭다운 등에 활용
     */
    function getAllPossibleStatuses() external pure returns (Status[5] memory statusList) {
        statusList[0] = Status.NotSale;
        statusList[1] = Status.Auction;
        statusList[2] = Status.Sales;
        statusList[3] = Status.Bid;
        statusList[4] = Status.Sold;
        return statusList;
    }
    
    /**
     * @dev enum을 정수로 변환하는 예제 함수
     * @param _status 변환할 enum 값
     * @return uint8 해당 enum의 정수 표현
     */
    function statusToUint(Status _status) external pure returns (uint8) {
        return uint8(_status);
    }
    
    /**
     * @dev 정수를 enum으로 변환하는 예제 함수
     * @param _value 변환할 정수 (0-4)
     * @return Status 해당 정수에 대응하는 enum 값
     */
    function uintToStatus(uint8 _value) external pure returns (Status) {
        require(_value <= 4, "Invalid status value");
        return Status(_value);
    }
    
    /**
     * @dev 현재 경매 정보 종합 조회
     * @return status 현재 상태
     * @return creator 생성자 주소
     * @return bidder 최고 입찰자 주소
     * @return bid 최고 입찰가
     * @return historyCount 상태 변경 횟수
     */
    function getAuctionInfo() external view returns (
        Status status,
        address creator,
        address bidder,
        uint256 bid,
        uint256 historyCount
    ) {
        return (
            auctionStatus,
            auctionCreator,
            highestBidder,
            highestBid,
            statusHistory.length
        );
    }
    
    /**
     * @dev 특정 상태에 진입한 시간 조회
     * @param _status 조회할 상태
     * @return uint256 해당 상태 진입 시간 (타임스탬프)
     */
    function getStatusTimestamp(Status _status) external view returns (uint256) {
        return statusTimestamp[_status];
    }
} 