# 以太坊合约执行

## 基本概念

### EVM
EVM是一个**基于栈的、大端序**的虚拟机，这个虚拟机不是VMware那种，而是类似JVM的虚拟机，所以我们可以向理解JVM那样理解EVM。

类似JVM，EVM也是一个在真实计算机之上设计并创建出来的支持一套自定义指令集的计算机。它还包含一个栈和两个存储域，即memory和storage。
>是的，如果自定义一套指令集，一般就需要实现相对应的一个汇编语言，在汇编之上才是开发者使用的高级语言，如solidity，vyper等。

但EVM不像JVM，是可以直接安装在各种物理机之上，EVM在设计之处就是嵌入以太坊客户端中的，即EVM运行在以太坊系统之上。EVM的作用是运行以太坊智能合约，
合约是在外部账户通过一笔交易创建的，合约字节码会附在交易的`data`中。同样，交易也可以通过携带`data`的方式与合约进行各种类型的交互，比如调用、销毁合约等。

### 合约字节码
合约字节码由一系列操作符（也叫指令）组成，任何一个操作符都可以编码成一个字节面量，除了[PUSHn](https://www.ethervm.io/#PUSH1)。
EVM指令集支持多个PUSH指令，如PUSH1, PUSH2等，后面的数字指的是入栈的数据字节大小，PUSH1就是入栈1字节的数据，以此类推。PUSHn由于携带了数字变量，
所以只能编码为双字节。

### 合约的构造函数
合约在创建成功后，它的构造函数将从中剔除，即构造函数不会出现在已部署的合约中。

### 与合约交互
合约会暴露一些ABI（应用程序二进制接口）来与允许外部世界与之交互。

### Call Data
它是在调用合约时附在交易的`data`字段的信息，通常包含一个4字节的方法标识，方法标识的构造方式：`sha3-256("somefunc(uint)uint")[:4]`，即函数签名的SHA3-256哈希后的前4字节。

### 栈、Memory和Storage
EVM维护了几个用于不同目的的数据结构，分别如下：
- Stack：类似一个数组结构，数组元素大小限定为256bit，长度限定为1024。元素的读写在栈顶（数组尾部）进行。栈用来保存合约执行过程中的临时变量，函数参数和返回地址。
  通常指令`PUSH1, DUP1, SWAP1, POP`会操作栈；
- Memory：也是一个数组结构，用于存放合约执行过程中的瞬态数据。通常指令`MLOAD, MSTORE, MSTORE8`会操作Memory（可以看到指令前的M前缀）；
- Storage：不同于前两个结构，它是存放持久化数据的一个map结构，key和value都是uint256类型。通常指令`SLOAD, SSTORE`会操作Storage（可以看到指令前的S前缀）；

### 合约执行过程
我们需要了解EVM执行合约的大致过程：
- EVM中执行的每个指令都叫做OpCode（操作码），且指令本身占用1字节。比如 PUSH1对应0x60,MSTORE对应0x52，每个操作码都唯一对应一个字节码，这在指令集表可以查询。
- 在合约执行前，操作码会被转换为CPU可读的字节码。
- 首先，程序计数器（PC，类似寄存器）从合约字节码中读取一个OpCode，然后从JumpTable中检索出对应操作，即指令包含的函数集合。
  接下来计算该指令包含的所有函数所需的gas，如果足够，则执行该指令，若不够，则扣完gas，并回退执行过的指令。（根据指令不同，可能会对堆栈、memory或StateDB进行操作）
- EVM的堆栈的位宽是256位，最大深度1024。

## 过程详解

我们编写的solidity代码经过remix或本地编译器如sloc、slocjs可以编译为对应的汇编代码，再转换为机器执行的纯十六进制字符的代码。

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

- 首先，操作码不是字节码，操作码还能读，字节码就完全是 0128asdasda9s87d98asd 这样的一串不可读的十六进制字符了，每一个操作码可以转换为一个字节。
- `PUSH1 0x80 PUSH1 0x40` 表示将1字节的0x80入栈，紧接着是入栈0x40（随时记住，一个栈元素最大为32byte即256bit）
- `MSTORE` 指令是将一个值保存到EVM 临时内存的操作，接收2个参数，第一个参数是用于存放值的内存地址，第二个参数的要存放的值，
  注意这个指令按规定是它的参数从栈里面获取（而不是外部输入），所以这里的逻辑是 MSTORE 0x40 0x80 （将值0x80存入地址0x40）
- 其他指令的含义则查询指令集表，下面会列出

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

Solidity 定义了一种汇编语言，在没有 Solidity 的情况下也可以使用。这种汇编语言也可以嵌入到 Solidity 源代码中当作“内联汇编（inline assembly）”使用。

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

目前共有140多个指令。需要注意的是，部分指令的参数数量是不固定的。另外，为了防止DOS攻击，每个指令的执行都要消耗gas，在 [evm.codes](https://www.evm.codes/#60?fork=merge) 查询指令集表以及指令所消耗的gas数量。
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
  mstore(0x40, 0x80)   // 将0x80这个值存入内存中0x40的位置
    /* "0x00_learn_bytecode.sol":111:112  0 */
  0x00 // 将0x00入栈（省略PUSH）
    /* "0x00_learn_bytecode.sol":100:112  uint abc = 0 */
  0x01 // 将0x01入栈（省略PUSH）
  sstore // 将0x01这个值存入storage中0x00的位置
    /* "0x00_learn_bytecode.sol":118:168  constructor() {... */
  callvalue // 将本次调用注入的以太币数量入栈，没有就是0 （不管是创建合约，还是调用合约都是一次消息调用，都可注入以太币）
  dup1      // 复制栈顶的数值，即为本次调用注入的以太币数量，此时的栈中元素情况：[栈底, 0, 0] ，这里假设注入0以太币。
  iszero    // 取出栈顶的值并判断是否为0，若是则入栈1，否则入栈0，stack: [栈底,0,0,1]
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