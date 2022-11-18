# 以太坊技术细节（整理）

### 目录
TODO

## 挖矿算法PoS
比特币使用的PoW算法由于存在大量资源浪费，导致难以被更大规模的应用接受。对此，以太坊尝试使用股份/权益（stake）作为标准进行记账权的竞争，并把这样的共识算法定义为PoS（Proof of Stake，权益证明）算法。
关于PoS的更多细节请参阅[共识算法——传统PoS共识算法](./consensus.md#2-传统PoS共识算法) 。
>PoS的思想起源于企业的股份制：一个人拥有的股份越多，其获得的股息和分红也就越高。如果采用这种方式进行区块链系统的维护，则不需要过多资源消耗，也能够使区块链资产有自然的通胀。
节点通过投入一定量的虚拟币参与共识，根据持币情况获得打包新区块的权利，并获得奖励。

## Casper算法
进入以太坊2.0时代的标志就是上线了采用了Casper算法的Beacon区块链。Casper属于权益证明制（PoS）范畴，除了继承PoS机制低能耗、防51%攻击更安全的优势外，
还在现有PoS机制上增加经济惩罚机制，解决PoS机制本身存在的“无利害攻击”问题。
>Casper 共识机制是一种旨在将以太坊从 1.0 版过渡到 2.0 版的协议，也称为“Serenity”计划。 以太坊 2.0 的长期目标是使其更快、更高效和高度可扩展。

Casper的上线意味着以太坊将不再需要挖矿来产生区块，而是通过基于股权的投票选出验证节点，然后由验证节点产生区块。
### 1. CBC和FFG
目前为止，在以太坊生态系统中已经有两个共同开发的Casper版本：Casper CBC（Correct-by-Construction）和Casper FFG（Friendly Finality Gadget）。
CBC版本最初由以太坊基金会研究员Vlad Zamfir提出。尽管对CBC的研究最初侧重于公链的PoS协议，但它已经发展成为一个更广泛的研究领域，其中就包括一系列的PoS模型。

Casper FFG的研究由以太坊联合创始人Vitalik Buterin主导。最初的提议包括混合PoW & PoS系统，但实施仍在讨论中，新提案最终可能仅使用PoS模型取而代之。

虽然两个版本都是为以太坊开发的，但Casper是一种PoS模型，也可以在其他区块链网络中推广和使用。

### 2. 以太坊2.0选择的共识算法
以太坊2.0选择的共识算法是Casper FFG + LMD-GHOST，二者结合起来叫做**Gasper**。其中LMD GHOST是被FFG和CBC同时选择的分叉选择规则。
>FFG论文：https://arxiv.org/abs/1710.09437  
> LMD GHOST：https://vitalik.ca/general/2018/12/05/cbc_casper.html#lmd-ghost

### 3. 算法细节
TODO

## LMD-GHOST协议

TODO




---

参考

- [Beacon Chain Fork Choice](https://github.com/ethereum/annotated-spec/blob/master/phase0/fork-choice.md)