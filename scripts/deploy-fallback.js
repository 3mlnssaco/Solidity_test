const { ethers } = require("hardhat");

async function main() {
    console.log("=== Fallback 및 SimpleProxy 컨트랙트 배포 및 테스트 ===");
    
    // 시그너 정보 가져오기
    const [deployer, user1, user2] = await ethers.getSigners();
    
    console.log("배포자 주소:", deployer.address);
    console.log("배포자 잔액:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");
    
    // ================================
    // FallbackDemo 컨트랙트 테스트
    // ================================
    
    console.log("\n🚀 FallbackDemo 컨트랙트 배포 중...");
    const FallbackDemo = await ethers.getContractFactory("FallbackDemo");
    const fallbackDemo = await FallbackDemo.deploy();
    await fallbackDemo.waitForDeployment();
    
    const fallbackAddress = await fallbackDemo.getAddress();
    console.log("✅ FallbackDemo 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", fallbackAddress);
    
    // 초기 상태 확인
    console.log("\n📋 초기 상태 확인...");
    let [data, receiveCount, fallbackCount, totalReceived, balance] = await fallbackDemo.getStatus();
    console.log("data:", data.toString());
    console.log("receiveCount:", receiveCount.toString());
    console.log("fallbackCount:", fallbackCount.toString());
    console.log("totalReceived:", ethers.formatEther(totalReceived), "ETH");
    console.log("balance:", ethers.formatEther(balance), "ETH");
    
    // 1. order 함수 호출 (정상적인 함수 호출)
    console.log("\n📞 order 함수 호출 테스트...");
    const orderTx = await fallbackDemo.connect(user1).order({
        value: ethers.parseEther("0.5")
    });
    await orderTx.wait();
    console.log("✅ order 함수 호출 완료");
    
    [data, receiveCount, fallbackCount, totalReceived, balance] = await fallbackDemo.getStatus();
    console.log("order 호출 후 data:", data.toString(), "(9가 되어야 함)");
    console.log("totalReceived:", ethers.formatEther(totalReceived), "ETH");
    
    // 2. receive 함수 테스트 (순수한 이더 전송)
    console.log("\n💰 receive 함수 테스트 (순수한 이더 전송)...");
    try {
        const receiveTx = await user1.sendTransaction({
            to: fallbackAddress,
            value: ethers.parseEther("0.002") // 최소 0.001 ETH 이상
        });
        await receiveTx.wait();
        console.log("✅ receive 함수 호출 성공");
        
        [data, receiveCount, fallbackCount, totalReceived, balance] = await fallbackDemo.getStatus();
        console.log("receive 호출 후 receiveCount:", receiveCount.toString());
        console.log("totalReceived:", ethers.formatEther(totalReceived), "ETH");
        
    } catch (error) {
        console.log("❌ receive 함수 호출 실패:", error.reason);
    }
    
    // 3. receive 함수 실패 테스트 (너무 적은 금액)
    console.log("\n💸 receive 함수 실패 테스트 (너무 적은 금액)...");
    try {
        const receiveTx = await user2.sendTransaction({
            to: fallbackAddress,
            value: ethers.parseEther("0.0005") // 0.001 ETH 미만
        });
        await receiveTx.wait();
        console.log("❌ 예상과 다르게 성공했습니다!");
    } catch (error) {
        console.log("✅ 예상대로 실패했습니다:", error.reason || "최소 금액 미달");
    }
    
    // 4. fallback 함수 테스트 (존재하지 않는 함수 호출)
    console.log("\n🔄 fallback 함수 테스트 (존재하지 않는 함수 호출)...");
    
    // 존재하지 않는 함수 시그니처 생성
    const unknownFunctionData = ethers.id("unknownFunction()").slice(0, 10); // 4바이트 시그니처
    console.log("존재하지 않는 함수 시그니처:", unknownFunctionData);
    
    try {
        const fallbackTx = await user2.sendTransaction({
            to: fallbackAddress,
            data: unknownFunctionData,
            value: ethers.parseEther("0.001")
        });
        await fallbackTx.wait();
        console.log("✅ fallback 함수 호출 성공");
        
        [data, receiveCount, fallbackCount, totalReceived, balance] = await fallbackDemo.getStatus();
        console.log("fallback 호출 후 fallbackCount:", fallbackCount.toString());
        console.log("totalReceived:", ethers.formatEther(totalReceived), "ETH");
        
    } catch (error) {
        console.log("❌ fallback 함수 호출 실패:", error.reason);
    }
    
    // 5. 특별한 함수 시그니처 테스트 (getBalance)
    console.log("\n🔧 특별한 함수 시그니처 테스트 (getBalance)...");
    const getBalanceSig = ethers.id("getBalance()").slice(0, 10);
    console.log("getBalance 함수 시그니처:", getBalanceSig);
    
    try {
        const specialTx = await user1.sendTransaction({
            to: fallbackAddress,
            data: getBalanceSig,
            value: ethers.parseEther("0.001")
        });
        await specialTx.wait();
        console.log("✅ 특별한 함수 시그니처 처리 완료");
        
        [data, receiveCount, fallbackCount, totalReceived, balance] = await fallbackDemo.getStatus();
        console.log("특별 처리 후 data:", data.toString(), "(100이 되어야 함)");
        
    } catch (error) {
        console.log("❌ 특별한 함수 시그니처 처리 실패:", error.reason);
    }
    
    // 6. testUnknownFunction 함수 테스트
    console.log("\n🧪 testUnknownFunction 함수 테스트...");
    const unknownData = ethers.id("nonExistentFunction(uint256)").slice(0, 10) + 
                       ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [123]).slice(2);
    
    try {
        const [success, returnData] = await fallbackDemo.testUnknownFunction(
            fallbackAddress,
            unknownData,
            { value: ethers.parseEther("0.001") }
        );
        console.log("✅ testUnknownFunction 호출 성공");
        console.log("성공 여부:", success);
        console.log("반환 데이터 길이:", returnData.length);
        
    } catch (error) {
        console.log("❌ testUnknownFunction 호출 실패:", error.reason);
    }
    
    // ================================
    // SimpleProxy 컨트랙트 테스트
    // ================================
    
    console.log("\n\n🚀 SimpleProxy 컨트랙트 배포 중...");
    
    // 우선 구현 컨트랙트로 FallbackDemo를 사용
    const SimpleProxy = await ethers.getContractFactory("SimpleProxy");
    const simpleProxy = await SimpleProxy.deploy(fallbackAddress);
    await simpleProxy.waitForDeployment();
    
    const proxyAddress = await simpleProxy.getAddress();
    console.log("✅ SimpleProxy 컨트랙트 배포 완료!");
    console.log("프록시 주소:", proxyAddress);
    console.log("구현 컨트랙트 주소:", fallbackAddress);
    
    // 프록시 정보 확인
    console.log("\n📋 프록시 정보 확인...");
    const implementation = await simpleProxy.implementation();
    const admin = await simpleProxy.admin();
    console.log("구현 컨트랙트:", implementation);
    console.log("관리자:", admin);
    
    // 프록시를 통한 함수 호출 테스트
    console.log("\n🔗 프록시를 통한 함수 호출 테스트...");
    
    // FallbackDemo의 order 함수를 프록시를 통해 호출
    const orderData = ethers.id("order()").slice(0, 10);
    
    try {
        const proxyTx = await user1.sendTransaction({
            to: proxyAddress,
            data: orderData,
            value: ethers.parseEther("0.3")
        });
        await proxyTx.wait();
        console.log("✅ 프록시를 통한 order 함수 호출 성공");
        
        // 구현 컨트랙트의 상태가 변경되었는지 확인
        [data, receiveCount, fallbackCount, totalReceived, balance] = await fallbackDemo.getStatus();
        console.log("프록시 호출 후 data:", data.toString());
        console.log("totalReceived:", ethers.formatEther(totalReceived), "ETH");
        
    } catch (error) {
        console.log("❌ 프록시를 통한 함수 호출 실패:", error.reason);
    }
    
    // 프록시에 이더 전송 테스트
    console.log("\n💰 프록시에 이더 전송 테스트...");
    try {
        const proxyEtherTx = await user2.sendTransaction({
            to: proxyAddress,
            value: ethers.parseEther("0.002")
        });
        await proxyEtherTx.wait();
        console.log("✅ 프록시에 이더 전송 성공");
        
        const proxyBalance = await ethers.provider.getBalance(proxyAddress);
        console.log("프록시 잔액:", ethers.formatEther(proxyBalance), "ETH");
        
    } catch (error) {
        console.log("❌ 프록시에 이더 전송 실패:", error.reason);
    }
    
    // 최종 상태 요약
    console.log("\n📊 최종 상태 요약:");
    console.log("=== FallbackDemo 컨트랙트 ===");
    [data, receiveCount, fallbackCount, totalReceived, balance] = await fallbackDemo.getStatus();
    console.log("data:", data.toString());
    console.log("receiveCount:", receiveCount.toString());
    console.log("fallbackCount:", fallbackCount.toString());
    console.log("totalReceived:", ethers.formatEther(totalReceived), "ETH");
    console.log("balance:", ethers.formatEther(balance), "ETH");
    
    console.log("\n=== SimpleProxy 컨트랙트 ===");
    const finalProxyBalance = await ethers.provider.getBalance(proxyAddress);
    console.log("프록시 잔액:", ethers.formatEther(finalProxyBalance), "ETH");
    console.log("구현 컨트랙트:", await simpleProxy.implementation());
    console.log("관리자:", await simpleProxy.admin());
    
    console.log("\n🎉 모든 fallback 및 프록시 테스트 완료!");
}

// 에러 처리
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ 스크립트 실행 중 오류 발생:");
        console.error(error);
        process.exit(1);
    }); 