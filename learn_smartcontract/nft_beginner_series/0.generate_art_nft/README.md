## 用自定义素材组合生成艺术NFT

本文档记录了笔者按照文章 [Create Generative NFT Art with Rarities][1] 来生成艺术NFT的过程，这是参考文章的[中文版本][0]。

### 1. 了解大致原理
一个艺术NFT图像是由多个特征图片叠加合成，特征指的是图像的某个位置，比如这个项目生成的是松鼠头像，它包含8个特征，包括背景、皮肤、面部、帽子等。
我们只需提前为每个特征准备一组不同的图片，然后由程序从这个特征图片池中为每个特征随机抽取一张出来，并将所有特征图进行叠加就得到一个艺术图片。

所以只要丰富特征图片池，生成一万张不同的图片是很容易的。

然后，每个特征部位的名称由我们提前定义，这些特征名最终会作为**NFT元数据**。

### 2. 下载代码库
这里直接使用一个免费的（Python）生成艺术品代码库：https://github.com/rounakbanik/generative-art-nft

执行下面的步骤：

```shell
# step1
# 若失效，请更换地址：https://github.com/chaseSpace/generative-art-nft
git clone git@github.com:rounakbanik/generative-art-nft.git

# step2：代码库依赖这几个python库
pip install Pillow pandas progressbar2
```

第二个命令将安装我们的库所依赖的三个重要的 Python 包：
- Pillow：一个图像处理库，将帮助我们堆叠特征图像。
- Pandas: 一个数据分析库，将帮助我们生成和保存图像元数据。
- 进度条: 一个库，将告诉我们图像生成时的进度和 ETA 值。

### 3. 了解config.py
主要是配置每个特征叠加的顺序，以及稀有性权重。请查看直接查看原文或该文件了解细节。

### 4. 生成NFT集合
执行命令：
```shell
lei@WilldeMacBook-Pro 0.generate_art_nft % cd 0.generative-art-nft 
lei@WilldeMacBook-Pro generative-art-nft % python3 nft.py       
Checking assets...
Assets look great! We are good to go!

You can create a total of 16 distinct avatars

How many avatars would you like to create? Enter a number greater than 0: 
20
What would you like to call this edition?: 
v1
Starting task...
100% (20 of 20) |################################################################################################################################################################################################################################################################| Elapsed Time: 0:00:01 Time:  0:00:01
Generated 20 images, 13 are distinct
Removing 7 images...
Saving metadata...
Task complete!
```
注意其中会需要你输入想要创建头像的数量以及本次生成操作的版本备注（笔者输入的是v1）。另外，根据日志可以发现仓库中的素材太少，最多生成13张不同的图，其余相同的会被删除。

生成结束后，会将头像和元数据.csv写入`/output`目录中，元数据.csv主要用来做稀有度分析，下一步要做的就是【上传头像到IPFS网络获得URL】，请参考下一个教程。

[0]:https://mp.weixin.qq.com/s?__biz=MzU5NzUwODcyMw==&mid=2247500378&idx=2&sn=1b721bdfc35890e2381df50c6ec0448b&chksm=fe50d546c9275c50e0393b7b5c0ad4da65015373c9ed89d64dce8cb490d362b50f30f75d2fad&scene=178&cur_album_id=1716985081560367106#rd
[1]:https://dev.to/rounakbanik/create-generative-nft-art-with-rarities-1n6f