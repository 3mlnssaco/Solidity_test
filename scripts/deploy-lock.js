const { ethers } = require("hardhat");

async function main() {
    console.log("=== Lock 컨트랙트 배포 및 테스트 ===");
    
    // 시그너 정보 가져오기
    const [deployer] = await ethers.getSigners();
    
    console.log("배포자 주소:", deployer.address);
    console.log("배포자 잔액:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");
    
    // 현재 시간 가져오기
    const currentBlock = await ethers.provider.getBlock("latest");
    const currentTime = currentBlock.timestamp;
    
    // 잠금 해제 시간 설정 (현재 시간 + 1분)
    const unlockTime = currentTime + 60; // 60초 후
    const unlockDate = new Date(unlockTime * 1000);
    
    console.log("현재 시간:", new Date(currentTime * 1000).toLocaleString("ko-KR"));
    console.log("잠금 해제 시간:", unlockDate.toLocaleString("ko-KR"));
    
    // 컨트랙트 배포 (1 ETH와 함께)
    console.log("\n🚀 Lock 컨트랙트 배포 중...");
    const lockValue = ethers.parseEther("1.0"); // 1 ETH를 잠금
    
    const Lock = await ethers.getContractFactory("Lock");
    const lock = await Lock.deploy(unlockTime, {
        value: lockValue
    });
    await lock.waitForDeployment();
    
    const contractAddress = await lock.getAddress();
    console.log("✅ 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", contractAddress);
    console.log("잠긴 이더량:", ethers.formatEther(lockValue), "ETH");
    
    // 컨트랙트 정보 확인
    console.log("\n📋 컨트랙트 정보 조회...");
    const contractUnlockTime = await lock.unlockTime();
    const owner = await lock.owner();
    const contractBalance = await ethers.provider.getBalance(contractAddress);
    
    console.log("소유자:", owner);
    console.log("잠금 해제 시간:", new Date(Number(contractUnlockTime) * 1000).toLocaleString("ko-KR"));
    console.log("컨트랙트 잔액:", ethers.formatEther(contractBalance), "ETH");
    
    // 너무 일찍 출금 시도 (실패해야 함)
    console.log("\n⏰ 잠금 시간 전 출금 시도 (실패 예상)...");
    try {
        await lock.withdraw();
        console.log("❌ 예상과 다르게 출금이 성공했습니다!");
    } catch (error) {
        console.log("✅ 예상대로 출금이 실패했습니다:");
        console.log("오류 메시지:", error.reason || "잠금 시간이 아직 지나지 않았습니다");
    }
    
    // 다른 계정에서 출금 시도 (실패해야 함)
    console.log("\n👤 다른 계정에서 출금 시도 (실패 예상)...");
    const [, otherAccount] = await ethers.getSigners();
    try {
        await lock.connect(otherAccount).withdraw();
        console.log("❌ 예상과 다르게 출금이 성공했습니다!");
    } catch (error) {
        console.log("✅ 예상대로 출금이 실패했습니다:");
        console.log("오류 메시지:", error.reason || "소유자가 아닙니다");
    }
    
    // 시간 경과 시뮬레이션 (테스트넷에서만 가능)
    console.log("\n⏱️  시간 경과 시뮬레이션...");
    console.log("네트워크의 다음 블록까지 대기 중...");
    
    // 실제 배포 환경에서는 이 부분을 주석 처리하고 실제 시간이 지날 때까지 기다려야 합니다
    /*
    // Hardhat 네트워크에서만 시간 이동 가능
    if (network.name === "hardhat") {
        await network.provider.send("evm_increaseTime", [61]); // 61초 증가
        await network.provider.send("evm_mine"); // 새 블록 생성
        console.log("✅ 시간이 61초 증가했습니다");
    }
    */
    
    // 현재 시간 다시 확인
    const newBlock = await ethers.provider.getBlock("latest");
    const newCurrentTime = newBlock.timestamp;
    console.log("현재 블록 시간:", new Date(newCurrentTime * 1000).toLocaleString("ko-KR"));
    
    if (newCurrentTime >= unlockTime) {
        // 정상적인 출금 시도
        console.log("\n💰 잠금 해제 후 출금 시도...");
        const ownerBalanceBefore = await ethers.provider.getBalance(deployer.address);
        console.log("출금 전 소유자 잔액:", ethers.formatEther(ownerBalanceBefore), "ETH");
        
        try {
            const withdrawTx = await lock.withdraw();
            const receipt = await withdrawTx.wait();
            
            console.log("✅ 출금 성공!");
            console.log("트랜잭션 해시:", withdrawTx.hash);
            console.log("사용된 가스:", receipt.gasUsed.toString());
            
            const ownerBalanceAfter = await ethers.provider.getBalance(deployer.address);
            console.log("출금 후 소유자 잔액:", ethers.formatEther(ownerBalanceAfter), "ETH");
            
            const finalContractBalance = await ethers.provider.getBalance(contractAddress);
            console.log("출금 후 컨트랙트 잔액:", ethers.formatEther(finalContractBalance), "ETH");
            
            // 이벤트 확인
            const events = await lock.queryFilter(lock.filters.Withdrawal());
            if (events.length > 0) {
                const event = events[0];
                console.log("출금 이벤트:", {
                    amount: ethers.formatEther(event.args.amount),
                    when: new Date(Number(event.args.when) * 1000).toLocaleString("ko-KR")
                });
            }
            
        } catch (error) {
            console.log("❌ 출금 실패:");
            console.log("오류:", error.reason || error.message);
        }
    } else {
        console.log("⏳ 아직 잠금 해제 시간이 되지 않았습니다.");
        console.log("잠금 해제까지 남은 시간:", unlockTime - newCurrentTime, "초");
    }
    
    console.log("\n🎉 Lock 컨트랙트 테스트 완료!");
}

// 에러 처리
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ 스크립트 실행 중 오류 발생:");
        console.error(error);
        process.exit(1);
    }); 