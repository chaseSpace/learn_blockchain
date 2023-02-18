## 上传NFT图片到IPFS

本文档记录了笔者按照文章 [Working with NFT Metadata, IPFS, and Pinata][0] 来完成以下工作的过程：
- 上传NFT图片到IPFS
- 生成合规的NFT JSON元数据（由于最终会上传到OpenSea，所以使用它的格式）
- 上传NFT元数据到IPFS

### 1. 为什么要上传
这部分内容解释了上述步骤的意义以及理由，由于是科普性内容，请阅读原文理解这部分。

### 2. 上传NFT图片到IPFS
由于在传统中心化云存储服务存放资源具有可替换、可丢失的风险，这在NFT行业是绝对不允许的，所以要使用去中心化且使用内容寻址的IPFS来作为云存储。

就像比特币和以太坊这些公链一样，如果要进行交互，只需要找到一个可靠网关就行了。所以现在有很多所谓提供Web3基础设置服务的公司，它们就是做这个的。
这里我们使用 [Pinata][1] 来作为IPFS网关。现在执行以下步骤：

- 进入Pinata网站注册一个账号，账户拥有免费1G的上传容量
- 进入**Files**页面点击**Upload+**，选择**Folder**，上传上一个[生成艺术NFT教程中得到的图片目录](./0.generate_art_nft/generative-art-nft/output/edition test/images)

上传时为目录输入新的名称，等上传成功后可以看到上传目录对应的CID了。
>这个CID是基于目录内所有内容生成的，所以只要目录内存在对任何图片的增删改，CID就会改变。

根据这个CID就可以得到两个URL:
```shell
# IPFS URL
ipfs://Qmdrw1RD6dQwsUvX4Xj4E3DtBNCorLqDstRWmQugTcQt1f
# 可通过浏览器访问的IPFS内容的HTTPS URL
https://ipfs.io/ipfs/Qmdrw1RD6dQwsUvX4Xj4E3DtBNCorLqDstRWmQugTcQt1f
```
但请注意，第二个HTTP URL是不能直接访问的（返回504），因为它对应的资源是整个目录，而IPFS访问协议不支持返回一个目录，但允许在指向目录的URL后面添加具体文件名来访问单个文件，
像这样：https://ipfs.io/ipfs/Qmdrw1RD6dQwsUvX4Xj4E3DtBNCorLqDstRWmQugTcQt1f/00.png ，还有一点需要注意，这个URL无法在上传Pinata后立即可访问，其中有一个同步的过程，笔者大概等了5min才能访问。

### 3. 生成合规的NFT JSON元数据
这一步我们需要先为每个NFT图片创建一个JSON文件，然后使用符合NFT交易市场（本例中是OpenSea）的数据格式进行填充。上一个教程中的**generative-art-nft**库中包含了一些脚本来帮助我们完成这些工作，
下面来看看所执行的步骤。

#### 3.1 修改metadata.py
在**generative-art-nft**库的根目录下存在`metadata.py`，我们编辑这个文件的第17行\~23行的内容，如下：
```python
BASE_IMAGE_URL = "ipfs://Qmdrw1RD6dQwsUvX4Xj4E3DtBNCorLqDstRWmQugTcQt1f" # 刚才上传图片的目录的IPFS URL
BASE_NAME = "Scrappy Squirrel #"  # 这个NFT集合的名称

BASE_JSON = {
    "name": BASE_NAME,
    "description": "A Collection of 10,000 Scrappy Squirrel on the Ethereum blockchain",  # NFT集合的描述
    "image": BASE_IMAGE_URL,
    "attributes": [],
}
```
只需修改三个变量`BASE_NAME`, `BASE_URL`, `BASE_JSON`，这几个变量都会进入到NFT元数据中。

#### 3.2 执行脚本
进入**generative-art-nft**库的根目录，执行命令（会询问你操作哪个edition，输入上个教程中笔者填的`v1`）：
```shell
lei@WilldeMacBook-Pro generative-art-nft % python3 metadata.py
Enter edition you want to generate metadata for: 
v1
Edition exists! Generating JSON metadata...
| |    
```
生成的JSON文件位于**generative-art-nft**库的`output/edition v1/json/`。

### 4. 上传JSON元数据到IPFS
就像前面上传图片目录一样，将JSON数据目录上传到Pinata获取CID即可。

现在，我们已经获得了这个NFT集合的所有图片和元数据的IPFS URL，下一步就是编写合约来引用这些数据了，请参考下一个教程。



[0]: https://dev.to/rounakbanik/working-with-nft-metadata-ipfs-and-pinata-3ieh
[1]: https://www.pinata.cloud/