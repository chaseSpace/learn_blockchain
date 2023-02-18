## 学习知名的NFT项目

### 注意事项
下文将OpenZeppelin简称为OZ。

- [Bored Ape Yacht Club][6]
    - 于2021年4月30日推出的由 10,000 只 "Bored Apes"（无聊猿） 组成的 NFT 系列，写文时市值 826,079.84 ETH。
    - 合约特性
      - 支持NFT保留
      - 支持部署后修改销售状态（开关）
      - 使用**PROVENANCE**来证明项目的NFT资产是与预期一致、未经更改的，包括数量、内容。关于这个术语，查看 [Learning NFT Provenance][8]
      - 但是这合约还有两个**bug**，查看 [BAYC合约严重漏洞][7]
- [Azuki][9]
    - 一个以动漫为灵感的个人资料照片（即Profile Picture，简称PFP）10,000 NFT系列，由Chiru Labs于2022年1月12日推出，写文时市值 352,552.73 ETH。
    - 合约特性
      - 使用兼容ERC721的ERC721A接口实现
      - 支持指定开始时间的拍卖机制
      - 指定NFT数量的白名单机制
      - 使用区块时间戳指定公开发售时间
      - 使用OZ的ReentrancyGuard防止针对提现函数的可重入攻击
- [Crypto Coven][5]
    - 由五名女性组成的团队创建的卡通女巫主题的数字藏品系列，于2021年12月推出，该系列共有9999个NFT，写文时市值 8,894 ETH。
    - 合约特性
      - 使用OZ的MerkleRoot实现经济的白名单机制
      - 使用OZ的ReentrancyGuard防止可重入攻击
      - 支持NFT保留、NFT赠送
      - 支持转入合约的ERC20代币提取
      - 使用OZ的Counter实现Token计数
      - 支持IERC2981，提供NFT的版税信息查询
- [Bitchcoin][10]
    - 由一位法国女艺术家 Sarah Meyohas 创作的名叫《花瓣云》的数字系列作品，2015年就发布了，在2021年转移到以太坊之上
    - 总数量3291，其中480个用于拍卖，总价值 1,049 ETH。
    - 合约特性
      - 使用ERC1155标准发布（[了解ERC1155多代币标准][11]）
      - 使用 [OpenZeppelin可升级库][12] 以支持对合约各方面升级
      - 支持修改铸币和合约交易状态管理的角色
      - 支持访问控制


[5]: https://etherscan.io/address/0x5180db8F5c931aaE63c74266b211F580155ecac8#code
[6]: https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
[7]: https://www.theblockbeats.info/news/30439
[8]: https://dev.to/brodan/learning-nft-provenance-by-example-a-bored-ape-investigation-hfe
[9]: https://etherscan.io/address/0xed5af388653567af2f388e6224dc7c4b3241c544#code
[10]: https://etherscan.io/address/0x5e86f887ff9676a58f25a6e057b7a6b8d65e1874#code
[11]: https://ethereum.org/en/developers/docs/standards/tokens/erc-1155/
[12]: https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable