const { ethers } = require("hardhat");

async function main() {
    console.log("=== TransactionProperty2 컨트랙트 배포 및 테스트 ===");
    
    // 시그너 정보 가져오기
    const [deployer, user1, user2] = await ethers.getSigners();
    
    console.log("배포자 주소:", deployer.address);
    console.log("배포자 잔액:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");
    
    // 컨트랙트 배포
    console.log("\n🚀 TransactionProperty2 컨트랙트 배포 중...");
    const TransactionProperty2 = await ethers.getContractFactory("TransactionProperty2");
    const transactionProperty2 = await TransactionProperty2.deploy();
    await transactionProperty2.waitForDeployment();
    
    const contractAddress = await transactionProperty2.getAddress();
    console.log("✅ 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", contractAddress);
    
    // 새로운 주문 생성 테스트
    console.log("\n📝 새로운 주문 생성 테스트...");
    const orderValue = ethers.parseEther("1.5"); // 1.5 ETH
    
    console.log("주문 생성 전 user1 잔액:", ethers.formatEther(await ethers.provider.getBalance(user1.address)), "ETH");
    
    const tx1 = await transactionProperty2.connect(user1).newOrderList({
        value: orderValue,
        gasLimit: 100000
    });
    await tx1.wait();
    
    console.log("✅ 주문 생성 완료!");
    console.log("전송된 이더량:", ethers.formatEther(orderValue), "ETH");
    console.log("주문 생성 후 user1 잔액:", ethers.formatEther(await ethers.provider.getBalance(user1.address)), "ETH");
    
    // 다른 사용자도 주문 생성
    console.log("\n📝 user2도 주문 생성...");
    const orderValue2 = ethers.parseEther("2.0"); // 2.0 ETH
    
    const tx2 = await transactionProperty2.connect(user2).newOrderList({
        value: orderValue2,
        gasLimit: 100000
    });
    await tx2.wait();
    
    console.log("✅ user2 주문 생성 완료!");
    console.log("전송된 이더량:", ethers.formatEther(orderValue2), "ETH");
    
    // 주문 확인 테스트
    console.log("\n🔍 주문 확인 테스트...");
    
    // user1의 주문이 1 ETH 이상인지 확인
    const checkResult1 = await transactionProperty2.checkOrderFunction(user1.address, ethers.parseEther("1.0"));
    console.log("user1이 1 ETH 이상 주문했는가?", checkResult1);
    
    // user1의 주문이 2 ETH 이상인지 확인
    const checkResult2 = await transactionProperty2.checkOrderFunction(user1.address, ethers.parseEther("2.0"));
    console.log("user1이 2 ETH 이상 주문했는가?", checkResult2);
    
    // user2의 주문이 1.5 ETH 이상인지 확인
    const checkResult3 = await transactionProperty2.checkOrderFunction(user2.address, ethers.parseEther("1.5"));
    console.log("user2가 1.5 ETH 이상 주문했는가?", checkResult3);
    
    // 함수 체크 테스트
    console.log("\n🔧 함수 시그니처 체크 테스트...");
    const checkFunctionResult = await transactionProperty2.newCheckFunction();
    console.log("함수 시그니처 일치 여부:", checkFunctionResult);
    
    // 컨트랙트 잔액 확인
    console.log("\n💰 컨트랙트 최종 상태:");
    console.log("컨트랙트 잔액:", ethers.formatEther(await ethers.provider.getBalance(contractAddress)), "ETH");
    
    // 가스 사용량 분석
    console.log("\n⛽ 가스 사용량 분석:");
    const receipt1 = await ethers.provider.getTransactionReceipt(tx1.hash);
    const receipt2 = await ethers.provider.getTransactionReceipt(tx2.hash);
    
    console.log("user1 주문 생성 가스:", receipt1.gasUsed.toString());
    console.log("user2 주문 생성 가스:", receipt2.gasUsed.toString());
    
    console.log("\n🎉 모든 테스트 완료!");
}

// 에러 처리
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ 스크립트 실행 중 오류 발생:");
        console.error(error);
        process.exit(1);
    }); 