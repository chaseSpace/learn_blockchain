# 以太坊操作码（EVM指令）

## 背景知识

我们需要了解EVM执行合约的大致过程：

- EVM中执行的每个指令都叫做OpCode（操作码），且指令本身占用1字节。比如 PUSH1对应0x60,MSTORE对应0x52，每个操作码都唯一对应一个字节码，这在指令集表可以查询。
- 在合约执行前，操作码会被转换为CPU可读的字节码。
- 首先，PC（类似寄存器）从合约字节码中读取一个OpCode，然后从JumpTable中检索出对应操作，即指令包含的函数集合。
  接下来计算该指令包含的所有函数所需的gas，如果足够，则执行该指令，若不够，则扣完gas，并回退执行过的指令。（根据指令不同，可能会对堆栈、memory或StateDB进行操作）
- EVM的堆栈的位宽是256位，最大深度1024。

## 详解

我们编写的solidity代码经过remix或本地编译器如sloc、slocjs可以编译为对应的汇编代码，再转换为机器执行的纯十六进制形式的代码。

>下载支持全功能的cpp实现的solc编译器（推荐）：https://docs.soliditylang.org/en/v0.8.17/installing-solidity.html#installing-the-solidity-compiler
> 下载支持部分功能的solcjs: npm install -g solc

通过一份简单代码来说明；

```solidity
contract Example {
    address _owner;
    constructor() {
        _owner = msg.sender;
    }
}
```

这是一份人类可读的solidity代码，用于实现自定义逻辑，为了便于机器执行，它需要编译为低级别的汇编代码（也称为操作码），再转换为十六进制代码由机器执行。
汇编代码可以认为是最接近CPU执行层的代码形式，通过汇编代码我们可以更清晰的看到solidity代码在汇编层的实际表现，比如一个函数用到了哪些汇编指令，
这十分有利于我们进行故障排查，特别是在debug阶段。下面将solidity转换为紧凑的**操作码序列**形式：

```solidity
// 请先下载solc编译器到本地
// solc -o learn_bytecode --opcodes 0x00_learn_bytecode.sol  
// 生成文件learn_bytecode/Example.opcode
PUSH1 0x80 PUSH1 0x40 MSTORE ...省略
```

操作码序列完全由EVM指令组成，并以线性方式排列所有指令和数据。

以Example合约的前面部分操作码序列为例进行解释：`PUSH1 0x80 PUSH1 0x40 MSTORE`

- 首先，操作码不是字节码，操作码还能读，字节码就完全是 0128asdasda9s87d98asd 这样的一串不可读的字节面量了，每一个操作码可以转换为一个字节。
- `PUSH1 0x80 PUSH1 0x40` 表示将1字节的0x80入栈，紧接着是入栈0x40（随时记住，一个栈元素最大为32byte即256bit）
- `MSTORE` 指令是将一个值保存到EVM 临时内存的操作，接收2个参数，第一个参数是用于存放值的内存地址，第二个参数的要存放的值，
  注意这个指令按规定是它的参数从栈里面获取（而不是外部输入），所以这里的逻辑是 MSTORE 0x40 0x80 （将值0x80存入地址0x40）
- 其他指令的作用则查询指令集表，下面会列出

操作码序列并不利于我们对照代码阅读。所以我们需要生成按行显示的汇编代码：

```solidity
// solc -o learn_bytecode --asm 0x00_learn_bytecode.sol  
/* "0x00_learn_bytecode.sol":57:241  contract Example {... */
mstore(0x40, 0x80)
/* "0x00_learn_bytecode.sol":111:112  0 */
0x00
/* "0x00_learn_bytecode.sol":100:112  uint abc = 0 */
0x01
sstore
/* "0x00_learn_bytecode.sol":118:168  constructor() {... */
callvalue
...省略
```

根据上面代码中的注释我们可以更清晰的对照solidity代码阅读汇编代码。

[//]: # (3. 编译为机器可读的十六进制字节码，生成learn_bytecode/Example.bin-runtime)

[//]: # (   solc -o learn_bytecode --bin-runtime 0x00_learn_bytecode.sol)

[//]: # ()

[//]: # (4. 编译为机器执行的完整字节码，生成learn_bytecode/Example.bin)

[//]: # (   solc -o learn_bytecode --bin 0x00_learn_bytecode.sol)

汇编代码由执行引擎支持的汇编指令集中的一系列指令和操作的数据组成，不同的执行引擎支持的指令集也不相同，指令集可以由引擎的开发者自定义一套。solidity运行在EVM执行引擎上，
所以该指令集我们称为EVM指令集，完整的指令集表在[这里](https://ethervm.io/#opcodes)
查询。需要注意，在EVM环境中，把支持的指令集也叫做**OpCode**，即操作码。

这里也以下图简单说明一下：

![](./images/ethereum_opcodes_example.jpg)

为方便阅读，以表格形式翻译如下：

| uint8 | Mnemonic | StackInput  | Stack Output | Expression | Notes                        |
|-------|----------|-------------|--------------|------------|------------------------------|
| 译：字节码 | 指令名      | 指令执行时需要的栈元素 | 指令执行后写入栈的元素  | 表达式        | 备注                           |
| 00    | STOP     | 无           | 无            | STOP()     | 停止合约执行                       |
| 01    | ADD      | /a/b/       | /a+b/        | a+b        | 对栈顶的两个int256或uint256元素执行加法运算 |

目前共有140多个指令。需要注意的是，部分指令的参数数量是不固定的。另外，为了防止DOS攻击，每个指令的执行都要消耗gas，在 [evm.codes](https://www.evm.codes/#60?fork=merge) 查询指令集表以及所消耗的gas数量。
这个网站还支持在线操作码编程，实时查看操作码与字节码、solidity的转换。  
> 最准确的以太坊支持的指令集表还得在 Geth 的源码中查询，[这个链接](https://github.com/ethereum/go-ethereum/blob/v1.10.26/core/vm/opcodes.go)指向了v1.10.26版本的Geth的指令集相关go代码：
 
简单起见，我们可以将所有操作码分为以下几类（列出部分）：
- 堆栈操作操作码（POP、PUSH、DUP、SWAP）
- 算术/比较/按位操作码（ADD、SUB、GT、LT、AND、OR）
- 环境操作码（CALLER、CALLVALUE、NUMBER）
- 内存操作操作码（MLOAD、MSTORE、MSTORE8、MSIZE）
- 存储操作操作码（SLOAD、SSTORE）
- 程序计数器相关操作码（JUMP、JUMPI、PC、JUMPDEST）
- 停止操作码（STOP、RETURN、REVERT、INVALID、SELFDESTRUCT）

### 详解上面的一段汇编指令
```solidity
    /* "0x00_learn_bytecode.sol":57:241  contract Example {... */
  mstore(0x40, 0x80)
    /* "0x00_learn_bytecode.sol":111:112  0 */
  0x00
    /* "0x00_learn_bytecode.sol":100:112  uint abc = 0 */
  0x01
  sstore
    /* "0x00_learn_bytecode.sol":118:168  constructor() {... */
  callvalue
  dup1
  iszero
  tag_1
  jumpi
  0x00
  dup1
  revert
tag_1:
  pop
  /* "0x00_learn_bytecode.sol":151:161  msg.sender */
  caller
  /* "0x00_learn_bytecode.sol":142:148  _owner */
  0x00
  dup1
  /* "0x00_learn_bytecode.sol":142:161  _owner = msg.sender */
  0x0100
  exp
  dup2
  sload
  dup2
  0xffffffffffffffffffffffffffffffffffffffff
```

参考
- [精通以太坊中关于EVM的章节](https://github.com/ethereumbook/ethereumbook/blob/develop/13evm.asciidoc)
- [以太坊虚拟机EVM的工作原理是怎样的](https://blog.csdn.net/pony_maggie/article/details/127021328)
- [以太坊操作码实时交互（与字节码实时转换）](https://www.evm.codes/playground?fork=merge)
- [以太坊黄皮书](https://ethereum.github.io/yellowpaper/paper.pdf)