// test/all.js
const {upgrades, ethers} = require("hardhat");
const {expect} = require('chai')

// Box的测试用例
describe("Box", function () {
    it("works", async function () {
        const Box = await ethers.getContractFactory("Box");
        const box = await upgrades.deployProxy(Box);
        await box.deployed();

        await expect(box.store(1)).to.emit(box, "ValueChanged").withArgs(1);
        expect(await box.retrieve()).to.equal(1);
    })
})

// BoxV2的测试用例
describe("BoxV2", function () {
    it("works", async function () {
        const Box = await ethers.getContractFactory("Box");
        const BoxV2 = await ethers.getContractFactory("BoxV2");

        const instance = await upgrades.deployProxy(Box);
        await instance.deployed();
        await expect(instance.store(1)).to.emit(instance, "ValueChanged").withArgs(1);
        expect(await instance.retrieve()).to.equal(1);

        // 使用旧地址升级
        const upgraded = await upgrades.upgradeProxy(instance.address, BoxV2);
        await upgraded.deployed();

        await upgraded.increment();
        expect(await upgraded.retrieve()).to.equal(2);
    })
})

// AdminBox的测试用例
describe("AdminBox", function () {
    it("works", async function () {
        const [owner, address1] = await ethers.getSigners();

        const AdminBox = await ethers.getContractFactory("AdminBox");
        const instance = await upgrades.deployProxy(AdminBox, [owner.address]);
        await instance.deployed();

        // 切换账户测试
        await expect(instance.connect(address1).store(1)).to.revertedWith("AdminBox: not admin");
        await instance.store(1);
        expect(await instance.retrieve()).to.equal(1);
    })
})