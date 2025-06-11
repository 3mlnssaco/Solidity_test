//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// ===============================================
// BlockProperty Contract - 블록 속성(Block Properties) 사용 예제
// ===============================================
// 
// 📌 블록 속성(Block Properties) 개념:
//   - 현재 블록의 다양한 정보에 접근할 수 있는 전역 변수들
//   - 블록체인의 상태와 메타데이터를 제공
//   - 스마트 컨트랙트에서 블록체인 정보 기반 로직 구현 시 사용
//   - 모든 트랜잭션에서 동일한 블록 정보를 공유
//
// 🔗 주요 블록 속성들:
//   - block.basefee: 현재 블록의 기본 수수료 (EIP-1559)
//   - block.chainid: 체인 ID (메인넷=1, 테스트넷 등 각각 고유 ID)
//   - block.coinbase: 블록을 채굴한 마이너의 주소
//   - block.prevrandao: 이전 블록의 랜덤 값 (구 block.difficulty)
//   - block.gaslimit: 현재 블록의 가스 한도
//   - block.number: 현재 블록 번호 (제네시스 블록부터의 순서)
//   - block.timestamp: 블록 생성 시간 (Unix 타임스탬프)
//
// 💡 활용 사례:
//   - 시간 기반 로직 (경매 종료, 락업 기간 등)
//   - 체인별 다른 동작 구현
//   - 블록 번호 기반 단계별 기능
//   - 랜덤성이 필요한 게임 로직 (주의: 진정한 랜덤은 아님)
// ===============================================

contract BlockProperty {
    // 🏷️ 각 블록 속성을 저장하는 public 변수들
    // 컨트랙트 배포 시점의 블록 정보가 저장됨
    
    /**
     * @dev 기본 수수료 (Base Fee) - EIP-1559에서 도입
     * - 네트워크 혼잡도에 따라 동적으로 조정되는 최소 수수료
     * - 가스 가격 예측 및 수수료 계산에 활용
     * - 단위: wei (1 ETH = 10^18 wei)
     */
    uint public block1 = block.basefee;
    
    /**
     * @dev 체인 ID (Chain ID)
     * - 각 블록체인 네트워크의 고유 식별자
     * - 이더리움 메인넷: 1, 세폴리아 테스트넷: 11155111
     * - 교차 체인 트랜잭션 방지 및 네트워크 구분에 사용
     */
    uint public block2 = block.chainid;
    
    /**
     * @dev 코인베이스 (마이너 주소)
     * - 현재 블록을 채굴한 마이너(또는 검증자)의 주소
     * - PoW에서는 마이너, PoS에서는 검증자 주소
     * - 마이너 보상이 전송되는 주소
     */
    address public block3 = block.coinbase;
    
    /**
     * @dev 이전 랜덤 값 (Previous Randao)
     * - 이전 블록에서 생성된 의사 랜덤 값
     * - 구 block.difficulty를 대체 (The Merge 이후)
     * - 예측 가능하므로 진정한 랜덤성이 필요한 경우 외부 오라클 사용 권장
     */
    uint public block4 = block.prevrandao;
    
    /**
     * @dev 가스 한도 (Gas Limit)
     * - 현재 블록에서 사용할 수 있는 최대 가스량
     * - 네트워크의 처리 용량을 나타냄
     * - 복잡한 계산의 실행 가능성 판단에 활용
     */
    uint public block5 = block.gaslimit;
    
    /**
     * @dev 블록 번호 (Block Number)
     * - 제네시스 블록(0번)부터 현재까지의 블록 순서
     * - 시간 경과 측정 및 단계별 로직 구현에 활용
     * - 대략 12초마다 1씩 증가 (이더리움 기준)
     */
    uint public block6 = block.number;
    
    /**
     * @dev 블록 타임스탬프 (Block Timestamp)
     * - 블록이 생성된 Unix 타임스탬프 (초 단위)
     * - 시간 기반 로직에서 가장 많이 사용됨
     * - 마이너가 조작 가능하므로 정확한 시간이 중요한 경우 주의 필요
     */
    uint public block7 = block.timestamp;
    
    /**
     * @dev 현재 블록 정보 조회 함수
     * @return basefee 현재 기본 수수료
     * @return chainid 체인 ID  
     * @return coinbase 마이너 주소
     * @return prevrandao 이전 랜덤 값
     * @return gaslimit 가스 한도
     * @return blocknumber 블록 번호
     * @return timestamp 타임스탬프
     * 
     * 컨트랙트 배포 시점과 함수 호출 시점의 블록 정보 차이를 
     * 비교해볼 수 있는 함수입니다.
     */
    function getCurrentBlockInfo() public view returns (
        uint basefee,
        uint chainid, 
        address coinbase,
        uint prevrandao,
        uint gaslimit,
        uint blocknumber,
        uint timestamp
    ) {
        return (
            block.basefee,      // 현재 기본 수수료
            block.chainid,      // 체인 ID
            block.coinbase,     // 현재 마이너 주소
            block.prevrandao,   // 현재 랜덤 값
            block.gaslimit,     // 현재 가스 한도
            block.number,       // 현재 블록 번호
            block.timestamp     // 현재 타임스탬프
        );
    }
    
    /**
     * @dev 시간 기반 조건 검사 예제
     * @param targetTime 목표 시간 (Unix 타임스탬프)
     * @return bool 현재 시간이 목표 시간 이후인지 여부
     */
    function isAfterTime(uint targetTime) public view returns (bool) {
        return block.timestamp >= targetTime;
    }
    
    /**
     * @dev 블록 번호 기반 단계 계산 예제
     * @return uint 현재 단계 (10000블록마다 단계 증가)
     */
    function getCurrentPhase() public view returns (uint) {
        return block.number / 10000;
    }
    
    /**
     * @dev 체인 검증 함수 예제
     * @param expectedChainId 예상 체인 ID
     * @return bool 현재 체인이 예상 체인과 같은지 여부
     */
    function isCorrectChain(uint expectedChainId) public view returns (bool) {
        return block.chainid == expectedChainId;
    }
}