// scripts/deploy_upgradeable_adminbox.js
const {ethers, upgrades} = require("hardhat");

async function main() {
    // 得到部署账号
    const [owner] = await ethers.getSigners();

    const AdminBox = await ethers.getContractFactory("AdminBox");
    console.log("Deploying AdminBox...");

    // 将部署账号作为初始化参数传入（因为函数名是initialize，所以opts参数可以省略）
    const adminBox = await upgrades.deployProxy(AdminBox, [owner.address], {initializer: 'initialize'});
    await adminBox.deployed();
    console.log("AdminBox deployed to:", adminBox.address);

    // 测试函数调用
    tx = await adminBox.store(1);
    await tx.wait();
    console.log("adminBox.store(1) is OK!")
}

main();