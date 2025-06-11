const { ethers } = require("hardhat");

async function main() {
    console.log("=== 상속 컨트랙트들 배포 및 테스트 ===");
    
    // 시그너 정보 가져오기
    const [deployer, user1, user2] = await ethers.getSigners();
    
    console.log("배포자 주소:", deployer.address);
    console.log("배포자 잔액:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");
    
    // ================================
    // 기본 Car 컨트랙트 테스트
    // ================================
    
    console.log("\n🚗 기본 Car 컨트랙트 배포 중...");
    const Car = await ethers.getContractFactory("Car");
    const car = await Car.deploy("sedan", 4, ethers.parseEther("30"));
    await car.waitForDeployment();
    
    const carAddress = await car.getAddress();
    console.log("✅ Car 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", carAddress);
    
    console.log("\n📊 Car 컨트랙트 기본 테스트...");
    console.log("소유자:", await car.owner());
    console.log("차량 타입:", await car.getVehicleType());
    console.log("문 개수:", (await car.getDoorCount()).toString());
    console.log("가격:", ethers.formatEther(await car.price()), "ETH");
    console.log("시동 상태:", await car.isRunning());
    
    // 시동 걸기 테스트
    console.log("\n🔥 시동 걸기 테스트...");
    const startTx = await car.startEngine();
    await startTx.wait();
    console.log("✅ 시동 걸기 완료!");
    console.log("시동 상태:", await car.isRunning());
    
    // 시동 끄기 테스트
    console.log("\n⏹️  시동 끄기 테스트...");
    const stopTx = await car.stopEngine();
    await stopTx.wait();
    console.log("✅ 시동 끄기 완료!");
    console.log("시동 상태:", await car.isRunning());
    
    // ================================
    // Benz 컨트랙트 테스트 (상속)
    // ================================
    
    console.log("\n🚙 Benz 컨트랙트 배포 중...");
    const Benz = await ethers.getContractFactory("Benz");
    const benz = await Benz.deploy("S-Class", true); // 자율주행 기능 있음
    await benz.waitForDeployment();
    
    const benzAddress = await benz.getAddress();
    console.log("✅ Benz 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", benzAddress);
    
    console.log("\n📊 Benz 컨트랙트 정보 조회...");
    console.log("소유자:", await benz.owner());
    console.log("차량 타입:", await benz.getVehicleType());
    console.log("가격:", ethers.formatEther(await benz.price()), "ETH");
    
    // Benz 특화 정보
    const [model, hasAutoPilot, mileage] = await benz.getBenzInfo();
    console.log("모델:", model);
    console.log("자율주행 기능:", hasAutoPilot);
    console.log("주행거리:", mileage.toString(), "miles");
    
    // Benz 시동 걸기 (오버라이드된 함수)
    console.log("\n🔥 Benz 시동 걸기 (상속된 기능 + 벤츠 특화 기능)...");
    const benzStartTx = await benz.startEngine();
    const receipt = await benzStartTx.wait();
    
    // 이벤트 확인
    console.log("✅ Benz 시동 걸기 완료!");
    console.log("발생한 이벤트 수:", receipt.logs.length);
    
    // 자율주행 활성화 테스트
    console.log("\n🤖 자율주행 활성화 테스트...");
    const autoPilotTx = await benz.activateAutoPilot();
    await autoPilotTx.wait();
    console.log("✅ 자율주행 활성화 완료!");
    
    // 주행거리 업데이트 테스트
    console.log("\n📈 주행거리 업데이트 테스트...");
    const mileageTx = await benz.updateMileage(500);
    await mileageTx.wait();
    
    const [, , newMileage] = await benz.getBenzInfo();
    console.log("✅ 주행거리 업데이트 완료!");
    console.log("새로운 주행거리:", newMileage.toString(), "miles");
    
    // ================================
    // Audi 컨트랙트 테스트 (상속)
    // ================================
    
    console.log("\n🚗 Audi 컨트랙트 배포 중...");
    const Audi = await ethers.getContractFactory("Audi");
    const audi = await Audi.deploy("A4", true, 7); // 콰트로 있음, 성능 레벨 7
    await audi.waitForDeployment();
    
    const audiAddress = await audi.getAddress();
    console.log("✅ Audi 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", audiAddress);
    
    console.log("\n📊 Audi 컨트랙트 정보 조회...");
    const [audiModel, hasQuattro, performanceLevel] = await audi.getAudiInfo();
    console.log("모델:", audiModel);
    console.log("콰트로 시스템:", hasQuattro);
    console.log("성능 레벨:", performanceLevel.toString());
    
    // Audi 시동 걸기
    console.log("\n🔥 Audi 시동 걸기...");
    const audiStartTx = await audi.startEngine();
    await audiStartTx.wait();
    console.log("✅ Audi 시동 걸기 완료!");
    
    // 콰트로 시스템 활성화
    console.log("\n🚙 콰트로 시스템 활성화...");
    const quattroTx = await audi.activateQuattro();
    await quattroTx.wait();
    console.log("✅ 콰트로 시스템 활성화 완료!");
    
    // 성능 모드 변경
    console.log("\n⚡ 성능 모드 변경 (7 → 10)...");
    const performanceTx = await audi.changePerformanceMode(10);
    await performanceTx.wait();
    
    const [, , newPerformance] = await audi.getAudiInfo();
    console.log("✅ 성능 모드 변경 완료!");
    console.log("새로운 성능 레벨:", newPerformance.toString());
    
    // ================================
    // BMW 컨트랙트 테스트 (상속)
    // ================================
    
    console.log("\n🚗 BMW 컨트랙트 배포 중...");
    const BMW = await ethers.getContractFactory("BMW");
    const bmw = await BMW.deploy("X5", "X-Series", true, 400); // xDrive 있음, 400HP
    await bmw.waitForDeployment();
    
    const bmwAddress = await bmw.getAddress();
    console.log("✅ BMW 컨트랙트 배포 완료!");
    console.log("컨트랙트 주소:", bmwAddress);
    
    console.log("\n📊 BMW 컨트랙트 정보 조회...");
    const [bmwModel, bmwSeries, hasXDrive, enginePower] = await bmw.getBMWInfo();
    console.log("모델:", bmwModel);
    console.log("시리즈:", bmwSeries);
    console.log("xDrive 시스템:", hasXDrive);
    console.log("엔진 출력:", enginePower.toString(), "HP");
    
    // BMW 시동 걸기
    console.log("\n🔥 BMW 시동 걸기...");
    const bmwStartTx = await bmw.startEngine();
    await bmwStartTx.wait();
    console.log("✅ BMW 시동 걸기 완료!");
    
    // xDrive 시스템 활성화
    console.log("\n🚙 xDrive 시스템 활성화...");
    const xDriveTx = await bmw.activateXDrive();
    await xDriveTx.wait();
    console.log("✅ xDrive 시스템 활성화 완료!");
    
    // 스포츠 모드 활성화
    console.log("\n🏎️  스포츠 모드 활성화...");
    const sportTx = await bmw.activateSportMode();
    await sportTx.wait();
    console.log("✅ 스포츠 모드 활성화 완료!");
    
    // ================================
    // 상속 관계 및 다형성 테스트
    // ================================
    
    console.log("\n🔗 상속 관계 및 다형성 테스트...");
    
    // 모든 차량의 공통 인터페이스 테스트
    const vehicles = [
        { name: "기본 Car", contract: car },
        { name: "Benz", contract: benz },
        { name: "Audi", contract: audi },
        { name: "BMW", contract: bmw }
    ];
    
    console.log("\n📋 모든 차량의 공통 정보:");
    for (const vehicle of vehicles) {
        const [vType, doors, price, running] = await vehicle.contract.getCarInfo();
        console.log(`${vehicle.name}:`);
        console.log(`  - 타입: ${vType}`);
        console.log(`  - 문 개수: ${doors}`);
        console.log(`  - 가격: ${ethers.formatEther(price)} ETH`);
        console.log(`  - 시동 상태: ${running}`);
        console.log("");
    }
    
    // ================================
    // 소유권 이전 테스트
    // ================================
    
    console.log("\n👤 소유권 이전 테스트...");
    
    // Benz 시동 끄기 (소유권 이전 전 필요)
    await benz.stopEngine();
    
    console.log("Benz 소유권 이전 전 소유자:", await benz.owner());
    
    // user1에게 소유권 이전
    const transferTx = await benz.transferOwnership(user1.address);
    await transferTx.wait();
    
    console.log("✅ Benz 소유권 이전 완료!");
    console.log("Benz 소유권 이전 후 소유자:", await benz.owner());
    
    // 새 소유자로 시동 걸기 테스트
    console.log("\n🔄 새 소유자로 시동 걸기 테스트...");
    try {
        const newOwnerStartTx = await benz.connect(user1).startEngine();
        await newOwnerStartTx.wait();
        console.log("✅ 새 소유자로 시동 걸기 성공!");
    } catch (error) {
        console.log("❌ 새 소유자로 시동 걸기 실패:", error.reason);
    }
    
    // ================================
    // 에러 처리 테스트
    // ================================
    
    console.log("\n❌ 에러 처리 테스트...");
    
    // 잘못된 사용자가 BMW 시동 끄려고 시도
    try {
        await bmw.connect(user2).stopEngine();
        console.log("❌ 예상과 다르게 성공했습니다!");
    } catch (error) {
        console.log("✅ 예상대로 실패: 소유자가 아닌 사용자의 시동 끄기 시도");
    }
    
    // Audi에 잘못된 성능 레벨 설정 시도
    try {
        await audi.changePerformanceMode(15); // 범위 초과
        console.log("❌ 예상과 다르게 성공했습니다!");
    } catch (error) {
        console.log("✅ 예상대로 실패: 잘못된 성능 레벨 설정 시도");
    }
    
    // ================================
    // 가스 사용량 분석
    // ================================
    
    console.log("\n⛽ 가스 사용량 분석:");
    
    const deploymentInfo = [
        { name: "Car", address: carAddress },
        { name: "Benz", address: benzAddress },
        { name: "Audi", address: audiAddress },
        { name: "BMW", address: bmwAddress }
    ];
    
    for (const info of deploymentInfo) {
        const code = await ethers.provider.getCode(info.address);
        const codeSize = (code.length - 2) / 2;
        console.log(`${info.name}: ${codeSize} 바이트`);
    }
    
    // ================================
    // 최종 상태 요약
    // ================================
    
    console.log("\n📋 최종 상태 요약:");
    console.log("=== 배포된 컨트랙트 주소 ===");
    console.log("Car (기본):", carAddress);
    console.log("Benz:", benzAddress);
    console.log("Audi:", audiAddress);
    console.log("BMW:", bmwAddress);
    
    console.log("\n=== 최종 소유자 정보 ===");
    console.log("Car 소유자:", await car.owner());
    console.log("Benz 소유자:", await benz.owner(), "(이전됨)");
    console.log("Audi 소유자:", await audi.owner());
    console.log("BMW 소유자:", await bmw.owner());
    
    console.log("\n=== 최종 시동 상태 ===");
    console.log("Car 시동:", await car.isRunning());
    console.log("Benz 시동:", await benz.isRunning());
    console.log("Audi 시동:", await audi.isRunning());
    console.log("BMW 시동:", await bmw.isRunning());
    
    console.log("\n=== 상속 관계 요약 ===");
    console.log("🔗 Car (부모)");
    console.log("  ├── Benz (자율주행 특화)");
    console.log("  ├── Audi (성능/콰트로 특화)");
    console.log("  └── BMW (스포츠/xDrive 특화)");
    
    console.log("\n🎉 모든 상속 컨트랙트 테스트 완료!");
    console.log("상속의 주요 개념들이 성공적으로 구현되고 테스트되었습니다:");
    console.log("✅ 단일 상속 (Car → Benz/Audi/BMW)");
    console.log("✅ 함수 오버라이딩 (startEngine, transferOwnership)");
    console.log("✅ super 키워드 사용");
    console.log("✅ virtual/override 키워드");
    console.log("✅ 다형성 (동일 인터페이스, 다른 구현)");
    console.log("✅ 접근 제어자 (internal, public, private)");
}

// 에러 처리
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ 스크립트 실행 중 오류 발생:");
        console.error(error);
        process.exit(1);
    }); 