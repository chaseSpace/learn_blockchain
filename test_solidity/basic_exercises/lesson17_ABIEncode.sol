// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@ABI（应用程序二进制接口）协议
-   官文：https://docs.soliditylang.org/en/v0.8.17/abi-spec.html
-   介绍
    在以太坊生态系统中，ABI协议是区块链外部与合约进行交互、合约与合约之间交互（主要是函数）的一种编码协议。
    数据根据其类型进行编码，下面会介绍；其次，编码不是自描述的，因此需要一个范式才能解码。

    ABI假定合约的接口函数是强类型的，在编译时已知。所有合约在编译时都有它们调用的任何合约的接口定义。

    1. 函数选择器（function selector）
        是一个4字节数据，计算方式：bytes4(keccak256(<function_signature>))  也就是取函数签名哈希的前4字节，大端序。
        -   也叫做Method ID
        -   selector用来唯一标识合约中的函数，合约在编译后，可以得到一个selector列表，即函数标识列表，用于部署后与外部的交互。
        -   <function_signature> 举例：“add(uint,uint)”  它不含返回值，因为函数名+参数类型足够标识一个函数了。
        -   既然是用来交互，selector必然会用在calldata中。所以在合约调用时，交易calldata的前4字节就是selector，后面跟的是函数所需参数值的keccak哈希
        -   函数签名：由函数名和参数类型组成的字符串，参数类型之间逗号分隔，不含返回值类型！不含空格！

    2. ABI的json描述格式
        具体示例见下方注释。
        -   是一个JSON数组，描述了合约拥有的所有function,event,error详细信息，像合约的部分元数据，可以根据这个信息来生成函数调用所需的calldata数据
        -   在remix IDE中可以在<solidity compiler> -- <Compilation Details> 中的ABI部分查看
        -   对于error类型，可以有多个同名且同签名的元素，因为合约可引用/继承了其他合约，就可能出现同名error，abi-json中不会描述error的定义来源。
            -   注：这是官文的描述，笔者下方代码没能复现！

    3. ABI编码
        -   函数调用的calldata就是ABI编码格式，即4字节的函数选择器 + 填充至32字节的二进制形式的参数
        -   calldata的第5个字节开始是函数的参数部分，对于参数和返回值的ABI编码规则，参阅官文：https://docs.soliditylang.org/en/v0.8.17/abi-spec.html#formal-specification-of-the-encoding
            -   简单来说，就是静态类型参数填充字节时向右对齐，动态类型向左对齐
                -   动态类型指的是string,bytes以及定长和不定长数组、包含动态类型的元组，除此之外都是静态类型(mappinge不能作为public类型函数的参数类型)
            -   abi.encode()、abi.encodeWithSelector()、abi.encodeWithSignature() 可以得到函数选择器以及参数的ABI编码
            -   abi.encodePacked() 得到函数选择器以及无填充的参数的ABI编码
            -   abi.decode()对返回值进行解码，得到对应的每个返回值

    4. 在区块链浏览器中观察calldata
        先找到一笔to字段为合约地址的交易，表示是一笔合约调用的交易，那么它的input data就是calldata
            -   浏览 https://etherscan.io/tx/0xad7e92d60cd22a06ff6323b78943e11ce94824712637973c07859ceb1a46fe33

    5. 通过ABI编码调用其他合约函数
        -   参考lesson3中对几个abi函数的使用
        -   通过对ABI编码调用合约函数过程的了解，我们可以发现，调用一个合约函数，并不需要提前知晓函数的签名以及返回值，只需定义这样一个函数即可
            -   function execute(address target, uint ether_val, bytes memory data) public returns (bytes memory) { /* 使用abi函数进行底层调用 *\/ }

@ABI的json描述
[
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "TransferFailed",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "a",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "b",
				"type": "uint256"
			}
		],
		"name": "add",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "c",
				"type": "uint256"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	}
]
*/



contract Example {
    event Transfer(address);

    error TransferFailed(address, uint);
}

contract LearnABI {
    event Transfer(address);

    error TransferFailed(address, uint);
    constructor() {
        Example ex = new Example();

    }
    function add(uint a, uint b) public pure returns (uint c) {
        c = a + b;
    }
}

contract LearnFuncSelector {
    // 分析calldata的构成1
    // add(1,2)的calldata：0x771602f700000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002
    // -    分为三部分
    //          0x771602f7  // add(uint,uint)的selector
    //          0000000000000000000000000000000000000000000000000000000000000001   // 参数1填充至32字节，静态类型填充时向右对齐
    //          0000000000000000000000000000000000000000000000000000000000000002    // 参数2填充至32字节，静态类型填充时向右对齐
    // -    calldata在remix IDE调用函数时点击旁边的∨可以看到calldata字样，输入数据后点击calldata复制数据
    function add(uint a, uint b) public pure returns (uint c) {
        c = a + b;
    }

    // 分析calldata的构成2(针对动态类型)
    // 传入参数(0x123, [0x456, 0x789], "1234567890", "Hello, world!")，calldata分隔后如下：
    // -    分为十个部分
    //          0x8be65246   // 此函数的selector
    //          接下来是四个参数的head部分，其中，对于静态类型uint256,bytes10，head(X)=值本身；对于动态类型uint32[],bytes，head(X)=offset(X)
    //          offset：某个参数相对于calldata的参数部分（第5个字节）开始的字节偏移量
    //          0x0000000000000000000000000000000000000000000000000000000000000123   // 0x123，第一个静态类型参数，head(X)=值本身，静态类型是左边填充0字节（数据右对齐）
    //          0x0000000000000000000000000000000000000000000000000000000000000080   // 0x80，第二个参数的offset=4*32=128字节=0x80，其中4理解为函数的4个参数，先编码4个参数的head，后编码4个参数的tail，tail是参数值本身；另外，静态类型的tail是空，所以整个tail部分都是动态类型参数的值数据。
    //          0x3132333435363738393000000000000000000000000000000000000000000000   // "1234567890"转ASCII码，即第三个参数的head，bytes10是定长数组，所以是静态类型，所以head(X)=值本身
    //          0x00000000000000000000000000000000000000000000000000000000000000e0   // 0xe0，第四个参数的offset=offset(dynamic_arg1)+tail(dynamic_arg1)=4*32+3*32；其中tail(dynamic_arg1)=len(arg)+arg_val，这里的dynamic_arg1就是uint32[]，其len是2，arg_val是其2个元素：0x456, 0x789
    //          接下来是动态类型参数的tail（就是data）部分，静态类型参数没有tail部分！
    //          首先是[0x456, 0x789]
    //          0x0000000000000000000000000000000000000000000000000000000000000002   // 数组长度
    //          0x0000000000000000000000000000000000000000000000000000000000000456   // 数组第一个元素
    //          0x0000000000000000000000000000000000000000000000000000000000000789   // 数组第二个元素
    //          然后是第二个动态类型参数"Hello, world!"
    //          0x000000000000000000000000000000000000000000000000000000000000000d   // string的UTF8字节长度：13=0x0d
    //          0x48656c6c6f2c20776f726c642100000000000000000000000000000000000000   // string本身，数据左对齐

    // 总结：函数参数的calldata构成为：<func_selector> <head(arg1)head(arg2)...head(argn)> <tail(arg1)tail(arg2)...tail(argn)>
    //  -   其中对于head<arg>，若arg是静态类型，则head<arg>=arg本身的32字节形式；若arg是动态类型，则head<arg>=offset(data part of arg)
    //  -   对于tail<arg>，若arg是静态类型，则为空；若arg是动态类型，则tail<arg>=<len(arg)><arg_self>；tail部分也称为动态类型的data部分。
    function f(uint256 a, uint32[] memory b, bytes10 c, bytes memory d) public pure {}

    // 通过this.func.selector获取
    // 测试此函数！
    function getSelector() public pure {
        // 注意uint的规范书写是uint256
        // 还可通过 https://emn178.github.io/online-tools/keccak_256.html 查看函数签名的哈希
        require(this.add.selector == bytes4(keccak256("add(uint256,uint256)")), "not match!");
    }
}