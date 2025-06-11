const { ethers } = require("hardhat");

async function main() {
    console.log("=== BlockProperty2 컨트랙트 배포 및 테스트 ===");
    
    // 시그너 정보 가져오기
    const [deployer] = await ethers.getSigners();
    
    console.log("배포자 주소:", deployer.address);
    console.log("배포자 잔액:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");
    
    // 배포 전 현재 블록 정보 확인
    console.log("\n📊 배포 전 현재 블록 정보:");
    const currentBlock = await ethers.provider.getBlock("latest");
    console.log("현재 블록 번호:", currentBlock.number);
    console.log("현재 블록 타임스탬프:", currentBlock.timestamp);
    console.log("현재 시간:", new Date(currentBlock.timestamp * 1000).toLocaleString("ko-KR"));
    
    // 컨트랙트 배포
    console.log("\n🚀 BlockProperty2 컨트랙트 배포 중...");
    const BlockProperty2 = await ethers.getContractFactory("BlockProperty2");
    const blockProperty2 = await BlockProperty2.deploy();
    await blockProperty2.waitForDeployment();
    
    const contractAddress = await blockProperty2.getAddress();
    console.log("✅ 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", contractAddress);
    
    // 배포 후 블록 정보 확인
    console.log("\n📊 배포 후 블록 정보:");
    const deployBlock = await ethers.provider.getBlock("latest");
    console.log("배포 후 블록 번호:", deployBlock.number);
    console.log("배포 후 블록 타임스탬프:", deployBlock.timestamp);
    console.log("배포 후 시간:", new Date(deployBlock.timestamp * 1000).toLocaleString("ko-KR"));
    
    // 컨트랙트에 저장된 배포 시점의 블록 정보 조회
    console.log("\n🏗️  컨트랙트 생성 시점의 블록 정보 (저장된 값):");
    const storedBlockNumber = await blockProperty2.blockNumber();
    const storedTimestamp = await blockProperty2.timestamp();
    
    console.log("저장된 블록 번호:", storedBlockNumber.toString());
    console.log("저장된 타임스탬프:", storedTimestamp.toString());
    console.log("저장된 시간:", new Date(Number(storedTimestamp) * 1000).toLocaleString("ko-KR"));
    
    // 현재 블록 정보와 비교
    console.log("\n📈 블록 정보 비교:");
    console.log("블록 번호 차이:", deployBlock.number - Number(storedBlockNumber), "블록");
    console.log("시간 차이:", deployBlock.timestamp - Number(storedTimestamp), "초");
    
    // getCurrentBlockInfo 함수 호출
    console.log("\n🔍 현재 블록 정보 조회 함수 호출...");
    const [currentBlockNum, currentTimestamp] = await blockProperty2.getCurrentBlockInfo();
    
    console.log("함수로 조회한 현재 블록 번호:", currentBlockNum.toString());
    console.log("함수로 조회한 현재 타임스탬프:", currentTimestamp.toString());
    console.log("함수로 조회한 현재 시간:", new Date(Number(currentTimestamp) * 1000).toLocaleString("ko-KR"));
    
    // 몇 개의 트랜잭션을 더 보내서 블록 진행 확인
    console.log("\n⏭️  추가 트랜잭션으로 블록 진행 확인...");
    
    for (let i = 1; i <= 3; i++) {
        console.log(`\n--- ${i}번째 추가 조회 ---`);
        
        // 의미없는 트랜잭션으로 블록 진행 (view 함수는 블록을 진행시키지 않음)
        const tx = await deployer.sendTransaction({
            to: deployer.address,
            value: 0
        });
        await tx.wait();
        
        // 현재 블록 정보 다시 조회
        const [newBlockNum, newTimestamp] = await blockProperty2.getCurrentBlockInfo();
        const newBlock = await ethers.provider.getBlock("latest");
        
        console.log("실제 블록 번호:", newBlock.number);
        console.log("함수 조회 블록 번호:", newBlockNum.toString());
        console.log("실제 타임스탬프:", newBlock.timestamp);
        console.log("함수 조회 타임스탬프:", newTimestamp.toString());
        console.log("현재 시간:", new Date(Number(newTimestamp) * 1000).toLocaleString("ko-KR"));
        
        // 컨트랙트 생성 시점과의 차이
        console.log("생성 시점과의 블록 차이:", Number(newBlockNum) - Number(storedBlockNumber));
        console.log("생성 시점과의 시간 차이:", Number(newTimestamp) - Number(storedTimestamp), "초");
        
        // 1초 대기
        await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    // 최종 상태 요약
    console.log("\n📋 최종 상태 요약:");
    const finalBlock = await ethers.provider.getBlock("latest");
    const [finalBlockNum, finalTimestamp] = await blockProperty2.getCurrentBlockInfo();
    
    console.log("=== 컨트랙트 생성 시점 ===");
    console.log("블록 번호:", storedBlockNumber.toString());
    console.log("시간:", new Date(Number(storedTimestamp) * 1000).toLocaleString("ko-KR"));
    
    console.log("\n=== 현재 시점 ===");
    console.log("블록 번호:", finalBlockNum.toString());
    console.log("시간:", new Date(Number(finalTimestamp) * 1000).toLocaleString("ko-KR"));
    
    console.log("\n=== 총 변화량 ===");
    console.log("진행된 블록 수:", Number(finalBlockNum) - Number(storedBlockNumber));
    console.log("경과 시간:", Number(finalTimestamp) - Number(storedTimestamp), "초");
    
    // 블록 생성 시간 분석
    const elapsedBlocks = Number(finalBlockNum) - Number(storedBlockNumber);
    const elapsedTime = Number(finalTimestamp) - Number(storedTimestamp);
    
    if (elapsedBlocks > 0) {
        const avgBlockTime = elapsedTime / elapsedBlocks;
        console.log("평균 블록 생성 시간:", avgBlockTime.toFixed(2), "초/블록");
    }
    
    console.log("\n🎉 BlockProperty2 컨트랙트 테스트 완료!");
}

// 에러 처리
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ 스크립트 실행 중 오류 발생:");
        console.error(error);
        process.exit(1);
    }); 