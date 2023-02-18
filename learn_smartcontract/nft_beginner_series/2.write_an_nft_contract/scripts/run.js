const {utils} = require("ethers");

async function main() {
    const baseTokenURI = "ipfs://QmacBqarE9dJTqjmVsDbnLbf7NRZaAegtGDd9ZoF6bhBmX/";

    // Get owner/deployer's wallet address
    const [owner] = await hre.ethers.getSigners();

    // Get contract that we want to deploy
    const contractFactory = await hre.ethers.getContractFactory("NFTCollectible");

    // Deploy contract with the correct constructor arguments
    const contract = await contractFactory.deploy(baseTokenURI);

    // Wait for this transaction to be mined
    await contract.deployed();

    // Get contract address
    console.log("Contract deployed to:", contract.address);

    // Reserve NFTs
    let txn = await contract.reserveNFTs();
    await txn.wait();
    console.log("10 NFTs have been reserved");

    // Mint 3 NFTs by sending 0.03 ether
    // 注意：reserveNFTs 加上这里单独铸币 共13个，已经将之前上传的NFT图片资源用尽，所以再铸币的话它的元数据链接是无法访问的。
    txn = await contract.mintNFTs(3, {value: utils.parseEther('0.03')});
    await txn.wait()

    // Get all token IDs of the owner
    let tokens = await contract.tokensOfOwner(owner.address)
    console.log("Owner has tokens: ", tokens);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });