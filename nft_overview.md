# NFT全了解

## 1. 什么是NFT
>为了让读者有更全面的了解，建议读者先看看维基百科对NFT的解释，下文笔者将用更简明的句子描述NFT。

NFT（Non-Fungible Token）中文叫做非同质化代币，是一种在区块链之上使用代币（Token）去代表数字资产（虚拟物品）的去中心化应用（application）。

每一个NFT代币都通过`TokenID`对应着网络世界中的一件虚拟物品，如画作、艺术品、声音、影片、游戏等（可发挥你的想象力）。在NFT出现以前，这些虚拟商品无法确定其原所有权，
而虚拟物品很容易被复制，这就可能导致多人对同一虚拟物品所有权的争议（下文会描述NFT的意义）。有了NFT，就可以通过【所有人在区块链上的账户——>NFT_TokenID——>NFT元数据】
这样一条链路来确定一件虚拟物品的所有权。也就是说，人们可以通过区块链上的账户来取得和转让NFT（虚拟物品）的所有权。

## 2. NFT如何关联虚拟物品
既然是虚拟物品，那一定是存在于网络世界中的，就可以用二进制数据表示。最简单、安全的办法是将物品原数据直接上传至区块链网络中随代币一同存储，
但不这样做的原因是区块链的全节点是存储了整个账本的，若使用账本存储这些音视频数据，会使得账本非常臃肿，不利于区块链平台运行，当然还有一个原因是以太坊对存储资源的gas高昂收费**阻止**我们这么做，所以常见做法是链下存储。

链下存储指的是存在NFT所在区块链以外的位置，既可以是某个中心化云存储平台，也可以是如今流行的分布式存储协议IPFS、Arweave区块链。
再通过NFT的元数据字段关联链下存储链接即可。

`NFT元数据`指的是一个NFT（一件虚拟物品）的各种属性，元数据一般都会包含名称、描述、链接三个基础属性字段。可以添加其他与虚拟物品属性相关的字段，
比如NFT游戏卡可能有等级、稀有度等属性。元数据的作用不可忽视，其中最重要的字段是链接（URI），我们在网页上看到的NFT商品的图片链接就存在这个NFT商品的元数据中，
没有这个链接，我们就无法查看这个商品图片。

## 3. NFT元数据
### 3.1 基本概念
NFT 是代表单个特定数字资产的代币，而数字资产本身由于区块链账本存储资源紧张和高收费问题无法直接存储在其之上。
所以NFT相关的合约标准如ERC721就规定了一种通过链下元数据关联的方式将NFT和数字资产联系起来。

元数据本身则是对特定数字资产的一系列属性描述，上文已经举例。需要重要说明的是元数据的三个作用：
- 节省链上存储成本：不用将数字资产直接存储于账本中；
- 丰富NFT自身：NFT拥有多个属性字段是非常有用的，既可以表达其价值，又可以增加趣味；
- 记录数字资产的地址（URI）：通常是一个链接，可以是HTTP、IPFS或AR协议。

### 3.2 技术细节

#### 3.2.1 ERC-721
以太坊的ERC-721是目前市场上（OpenSea）最常用（也是最通用）的NFT标准，其通过一个可选的元数据扩展接口提供NFT元数据访问，如下：
```solidity
interface ERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string);
}
```
其中的`tokenURI`函数用来返回NFT资产的链下元数据（JSON格式），其描述如下：
```json
{
    "title": "Asset Metadata",
    "type": "object",
    "properties": {
        "name": {
            "type": "string",
            "description": "Identifies the asset to which this NFT represents"
        },
        "description": {
            "type": "string",
            "description": "Describes the asset to which this NFT represents"
        },
        "image": {
            "type": "string",
            "description": "A URI pointing to a resource with mime type image/* representing the asset to which this NFT represents. Consider making any images at a width between 320 and 1080 pixels and aspect ratio between 1.91:1 and 4:5 inclusive."
        }
    }
}
```
这两段代码来自 [EIP-721][1]，需要注意的是，上面这段json并不是元数据本体，本体的一级字段是其中`properties`里面的`name`和`description`相关字段。

这里给出一个Opensea商城中的实际案例，商品是Soul Cafe Genesis创作的 [#758][2]，它的元数据可以通过点击Details部分的 [TokenID链接][3] 得到，这里粘贴如下：
```json
{
    "name": "#758",
    "symbol": "SC",
    "description": "Soul Café is a collection of 3333 randomly generated, unique and diverse women existing as NFTs on the  Ethereum Blockchain.",
    "seller_fee_basis_points": 500,
    "external_url": "https://soulcafe.io",
    "attributes": [{
        "trait_type": "Necklace",
        "value": ""
    }, 数组过长，省略部分],
    "collection": {
        "name": "Sol Café",
        "family": "collection of 3333"
    },
    "date": 1637869246139,
    "properties": {
        "files": [{
            "uri": "https://arweave.net/mijxytN91rovAl9RN-ghx6AVunwGFGCXNNlwEy3R_-4",
            "type": "image/png"
        }],
        "category": "image",
        "maxSupply": 0,
        "creators": [{
            "address": "3jcoiAdBUPgjvynAhFP9sHWSrtULpR9SfDXGvyaWtFj4",
            "share": 100
        }]
    },
    "image": "https://arweave.net/mijxytN91rovAl9RN-ghx6AVunwGFGCXNNlwEy3R_-4"
}
```
为了方便丰富商品详情页的元素，OpenSea在ERC721基础上又增加了一些字段，如`external_url`、`animation_url`等，详见 [OpenSea DevDocs][4] 。

#### 3.2.2 ERC-1155
除了ERC721，2018年由**Enjin**首席技术官Witek Radomski等人开发又开发出了一种新的代币标准ERC1155，
其主要用于游戏行业中道具资产的生成和处理。ERC1155同时支持发行同质化和非同质化代币，并且允许批量发行和转移代币，
相比于ERC721大大降本增效！
>ERC1155元数据标准又称Enjin元数据标准。

ERC-1155较为有名的应用是Enjin network，另有区块链游戏The Sandbox也将ERC-1155作为其首选代币标准。

#### 3.2.3 ERC-998
ERC998同样在2018年被提出，且目前被标准化，叫做可合成非同质化代币（Composable NFT，缩写为CNFT）。 

ERC998允许一个NFT拥有其他NFT或FT，也就是说在代币之间增加了所属关系，一个典型的例子是一个ERC721代币可能位于一个树形结构的顶点。
这表示这个顶点的721代币拥有组成树形结构中的不同类型的多种代币。具体来说，ERC998允许的合成关系如下：
- `ERC998ERC721`自上而下的可合成代币可以接收、持有和转账`ERC721`代币
- `ERC998ERC20`自上而下的可合成代币可以接收、持有和转账`ERC20`代币
- `ERC998ERC721`**自下而上**的可合成代币可以附加到其他`ERC721`代币
- `ERC998ERC20`**自上而下**的可合成代币可以附加到其他`ERC20`代币

自上而下的可组合合约存储并跟踪其每个代币的子代币，自下而上的可组合合约存储并跟踪其每个代币的父代币。

### 3.3 元数据和虚拟物品存储
通过前面例举的OpenSea商品案例，可以发现OpenSea使用分布式存储协议IPFS存储了NFT的元数据，而元数据中使用AR协议存储了NFT绑定的数字资产的地址。

#### 3.3.1 IPFS协议
IPFS又叫做星际文件系统，[官网在这][5]，是一个旨在创建持久且分布式存储和共享文件的网络传输协议。这个协议像公链一样，将网络中参与到IPFS网络的计算机设备作为一个存储节点，
节点可以和其他IPFS节点通信，以提供内容索引和下载。参与到网络的节点用户可以只存储感兴趣的文件，以节省空间，这意味着，IPFS之上的数据可能不会永久存储。

IPFS协议将文件分块哈希存储，每个块对应一个哈希ID（叫做ContentID），这个CID会用于内容索引和版本管理，这意味着使用ipfs协议下载文件自带cdn效果。
用户分享（和下载文件）的链接通常也会包含一个哈希。

IPFS网络使用是免费的，但是请注意，添加到IPFS网络的数据不会自动复制到其他节点。基于此，一个强大的基于IPFS的公链项目诞生了，它就是Filecoin。
Filecoin使用token激励节点来参与数据的存储于分发，为用户文件提供了可用性保证。

>注意，IPFS只是一个P2P的文件传输协议，而Filecoin则是基于IPFS的一个公有区块链项目。

#### 3.3.2 Arweave协议
TODO

### 3.4 使用NFTScan查看NFT数据


## 4. NFT的意义

## 5. NFT发展

[1]:https://eips.ethereum.org/EIPS/eip-721
[2]:https://opensea.io/assets/ethereum/0xdb8f52d04f9156dd2167d2503a5a2ceef3125b09/758
[3]:https://ipfs.io/ipfs/QmT11YwPGdUv1ZVvEQ9tU7gH5Q3jWpDovMsT5NpQQec6VD/758.json
[4]:https://docs.opensea.io/docs/metadata-standards
[5]:https://ipfs.tech