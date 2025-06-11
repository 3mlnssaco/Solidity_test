const { ethers } = require("hardhat");

async function main() {
    console.log("=== 자료형 컨트랙트들 배포 및 테스트 ===");
    
    // 시그너 정보 가져오기
    const [deployer, user1] = await ethers.getSigners();
    
    console.log("배포자 주소:", deployer.address);
    console.log("배포자 잔액:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");
    
    // ================================
    // DataType 컨트랙트 테스트
    // ================================
    
    console.log("\n🚀 DataType 컨트랙트 배포 중...");
    const DataType = await ethers.getContractFactory("DataType");
    const dataType = await DataType.deploy();
    await dataType.waitForDeployment();
    
    const dataTypeAddress = await dataType.getAddress();
    console.log("✅ DataType 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", dataTypeAddress);
    
    console.log("\n📊 DataType 컨트랙트 데이터 조회...");
    console.log("bool data1:", await dataType.data1());
    console.log("int data2:", (await dataType.data2()).toString());
    console.log("uint data3:", (await dataType.data3()).toString());
    console.log("uint256 data4:", (await dataType.data4()).toString());
    console.log("int256 data5:", (await dataType.data5()).toString());
    console.log("uint8 data6:", (await dataType.data6()).toString());
    console.log("int8 data7:", (await dataType.data7()).toString());
    console.log("string data8:", await dataType.data8());
    console.log("bytes data9:", await dataType.data9());
    console.log("address data11:", await dataType.data11());
    console.log("address data12:", await dataType.data12());
    
    // ================================
    // Solidity 컨트랙트 테스트 (first.sol)
    // ================================
    
    console.log("\n🚀 Solidity 컨트랙트 배포 중...");
    const Solidity = await ethers.getContractFactory("Solidity");
    const solidity = await Solidity.deploy();
    await solidity.waitForDeployment();
    
    const solidityAddress = await solidity.getAddress();
    console.log("✅ Solidity 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", solidityAddress);
    
    console.log("\n📊 Solidity 컨트랙트 테스트...");
    console.log("초기 a 값:", (await solidity.a()).toString());
    
    // changeData 함수 호출
    const changeDataTx = await solidity.changeData();
    await changeDataTx.wait();
    console.log("changeData 호출 후 a 값:", (await solidity.a()).toString());
    
    // ================================
    // Function 컨트랙트 테스트
    // ================================
    
    console.log("\n🚀 Function 컨트랙트 배포 중...");
    const Function = await ethers.getContractFactory("Function");
    const functionContract = await Function.deploy();
    await functionContract.waitForDeployment();
    
    const functionAddress = await functionContract.getAddress();
    console.log("✅ Function 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", functionAddress);
    
    console.log("\n📊 Function 컨트랙트 테스트...");
    console.log("초기 데이터:", (await functionContract.getData()).toString());
    
    // setData 함수 호출
    const setDataTx = await functionContract.setData(100);
    await setDataTx.wait();
    console.log("setData(100) 호출 후 데이터:", (await functionContract.getData()).toString());
    
    // ================================
    // FunctionVisibility 컨트랙트 테스트
    // ================================
    
    console.log("\n🚀 FunctionVisibility 컨트랙트 배포 중...");
    const FunctionVisibility = await ethers.getContractFactory("FunctionVisibility");
    const functionVisibility = await FunctionVisibility.deploy();
    await functionVisibility.waitForDeployment();
    
    const visibilityAddress = await functionVisibility.getAddress();
    console.log("✅ FunctionVisibility 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", visibilityAddress);
    
    console.log("\n📊 FunctionVisibility 컨트랙트 테스트...");
    console.log("초기 data2:", (await functionVisibility.data2()).toString());
    console.log("초기 data3:", (await functionVisibility.data3()).toString());
    console.log("초기 data4:", (await functionVisibility.data4()).toString());
    
    // public 함수 호출
    const setData3Tx = await functionVisibility.setData3(123);
    await setData3Tx.wait();
    console.log("setData3(123) 호출 후 data3:", (await functionVisibility.data3()).toString());
    
    // external 함수 호출
    const setData4Tx = await functionVisibility.setData4(45);
    await setData4Tx.wait();
    console.log("setData4(45) 호출 후 data4:", (await functionVisibility.data4()).toString());
    
    // ================================
    // Operation 컨트랙트 테스트
    // ================================
    
    console.log("\n🚀 Operation 컨트랙트 배포 중...");
    const Operation = await ethers.getContractFactory("Operation");
    const operation = await Operation.deploy();
    await operation.waitForDeployment();
    
    const operationAddress = await operation.getAddress();
    console.log("✅ Operation 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", operationAddress);
    
    console.log("\n📊 Operation 컨트랙트 테스트...");
    console.log("초기 intData:", (await operation.intData()).toString());
    console.log("초기 stringData:", await operation.stringData());
    
    // math 함수 호출
    const mathTx = await operation.math();
    await mathTx.wait();
    console.log("math() 호출 후 intData:", (await operation.intData()).toString());
    
    // weitoEth 함수 호출
    const weiToEthResult = await operation.weitoEth();
    console.log("weitoEth() 결과:", weiToEthResult.toString());
    
    // logical 함수 호출
    const logicalResult = await operation.logical();
    console.log("logical() 결과:");
    console.log("  AND 결과:", logicalResult[0]);
    console.log("  OR 결과:", logicalResult[1]);
    console.log("  EQUAL 결과:", logicalResult[2]);
    console.log("  NOT_EQUAL 결과:", logicalResult[3]);
    
    // ================================
    // PureView 컨트랙트 테스트
    // ================================
    
    console.log("\n🚀 PureView 컨트랙트 배포 중...");
    const PureView = await ethers.getContractFactory("PureView");
    const pureView = await PureView.deploy();
    await pureView.waitForDeployment();
    
    const pureViewAddress = await pureView.getAddress();
    console.log("✅ PureView 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", pureViewAddress);
    
    console.log("\n📊 PureView 컨트랙트 테스트...");
    
    // view 함수 테스트
    const dataResult = await pureView.getData();
    console.log("getData() (view 함수) 결과:", dataResult.toString());
    
    // pure 함수 테스트
    const pureResult = await pureView.getPureData("안녕하세요 솔리디티!");
    console.log("getPureData() (pure 함수) 결과:", pureResult);
    
    // ================================
    // Version4 컨트랙트 테스트
    // ================================
    
    console.log("\n🚀 Version4 컨트랙트 배포 중...");
    const Version4 = await ethers.getContractFactory("Version4");
    const version4 = await Version4.deploy();
    await version4.waitForDeployment();
    
    const version4Address = await version4.getAddress();
    console.log("✅ Version4 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", version4Address);
    console.log("📝 Version4는 빈 컨트랙트입니다.");
    
    // ================================
    // 가스 사용량 분석
    // ================================
    
    console.log("\n⛽ 가스 사용량 분석:");
    
    // 각 컨트랙트의 배포 비용 계산
    const deploymentCosts = [
        { name: "DataType", address: dataTypeAddress },
        { name: "Solidity", address: solidityAddress },
        { name: "Function", address: functionAddress },
        { name: "FunctionVisibility", address: visibilityAddress },
        { name: "Operation", address: operationAddress },
        { name: "PureView", address: pureViewAddress },
        { name: "Version4", address: version4Address }
    ];
    
    for (const contract of deploymentCosts) {
        const code = await ethers.provider.getCode(contract.address);
        const codeSize = (code.length - 2) / 2; // 0x 제거 후 바이트 계산
        console.log(`${contract.name}: 코드 크기 ${codeSize} 바이트`);
    }
    
    // ================================
    // 최종 상태 요약
    // ================================
    
    console.log("\n📋 최종 상태 요약:");
    console.log("=== 배포된 컨트랙트 주소 ===");
    console.log("DataType:", dataTypeAddress);
    console.log("Solidity:", solidityAddress);
    console.log("Function:", functionAddress);
    console.log("FunctionVisibility:", visibilityAddress);
    console.log("Operation:", operationAddress);
    console.log("PureView:", pureViewAddress);
    console.log("Version4:", version4Address);
    
    console.log("\n=== 최종 데이터 값들 ===");
    console.log("DataType - bool data1:", await dataType.data1());
    console.log("DataType - string data8:", await dataType.data8());
    console.log("Solidity - a:", (await solidity.a()).toString());
    console.log("Function - data:", (await functionContract.getData()).toString());
    console.log("FunctionVisibility - data3:", (await functionVisibility.data3()).toString());
    console.log("Operation - intData:", (await operation.intData()).toString());
    console.log("PureView - data:", (await pureView.getData()).toString());
    
    console.log("\n=== 네트워크 정보 ===");
    const network = await ethers.provider.getNetwork();
    console.log("네트워크 이름:", network.name);
    console.log("체인 ID:", network.chainId.toString());
    
    const finalBlock = await ethers.provider.getBlock("latest");
    console.log("현재 블록 번호:", finalBlock.number);
    console.log("현재 시간:", new Date(finalBlock.timestamp * 1000).toLocaleString("ko-KR"));
    
    console.log("\n🎉 모든 자료형 컨트랙트 테스트 완료!");
}

// 에러 처리
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ 스크립트 실행 중 오류 발생:");
        console.error(error);
        process.exit(1);
    }); 