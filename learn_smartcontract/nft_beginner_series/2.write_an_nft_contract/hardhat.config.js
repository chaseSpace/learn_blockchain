require("@nomicfoundation/hardhat-toolbox");

// @nomiclabs/hardhat-etherscan 这个库使用undici作为http客户端，所以修改它的代理设置（它并不访问环境变量中的代理配置，所以只能在代码中设置）
const {ProxyAgent, setGlobalDispatcher} = require("undici")
const proxyAgent = new ProxyAgent("http://127.0.0.1:7890") // change to yours
setGlobalDispatcher(proxyAgent)

// 这是笔者编写此练习时临时使用的配置，可能已经失效，建议自行去alchemy申请账户创建app获得它们
const ALCHEMY_GOERLI_API = 'https://eth-goerli.g.alchemy.com/v2/0l_WW7kaE9pLJIySxGuojjc8JEOke9Ky'
// 以太坊网络账户的私钥，不要透露给任何人，笔者上传的是随意填写的，但格式、长度是正确的
const ETH_ACCOUNT_PRI_KEY = '2ecf1f16b9dd012c2f737d0307aac4b17fed602a3a1dfdfebb04f0a7ca89ede5'
// etherscan api private key
const ETHERSCAN_API_KEY = 'VGDVCY4EB8UAG4W9R9JYKV4PJCZA7MFCQP'

// 这部分代码演示如何创建一个hardhat task，官方文档是 https://hardhat.org/guides/create-task.html
// 此task提供运行 npx hardhat accounts 的快捷功能，但注意这里的逻辑实现是打印Hardhat本地网络的账户，不是goerli网络的
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.17",
    defaultNetwork: "localhost",
    networks: {
        goerli: {
            url: ALCHEMY_GOERLI_API,
            accounts: [ETH_ACCOUNT_PRI_KEY]
        }
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    }
};
