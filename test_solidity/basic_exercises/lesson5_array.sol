// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@数组
-   介绍
    与其他语言类似，solidity的数组也适用[]语法，分两种类型：定长和不定长，即 T[x] T[]
    -   仅storage位置的bytes和其他类型数组支持push/pop
    -   delete arr[x] 重置元素； delete arr 删除所有元素
    -   bytes和string本质一样，固定长度多使用bytes1~bytes32 string不支持index和length
    -   memory位置的数组需要初始化后才能使用
    -   仅calldata位置的数组支持范围访问，在abi解码时常用
*/


contract LearnArray{
    // storage数组，部署后就自动初始化，长度为0，可以直接使用
    uint[] stateArr;

    event PrintUnicode(bytes1);

    function test(uint[] memory a) public  {
        // 声明
        uint8[2] memory xx;
        string[] memory xx2;
        bytes[] memory xx4;

        // 初始化，注意memory位置的数组无法push/pop修改长度，所以初始化的时候要确定合适长度
        xx = [1,2];
        // xx2 = ["S"];  // 不定长数组不能这样初始化，后者表示一个定长数组
        xx2 = new string[](2); // 只能这样
        // xx2.length = 0; // 动态数组 从v0.6.0开始，不能通过length修改长度
        xx4 = new bytes[](2);


        // 发现暂时无法在函数中初始化storage变量
        // string[] storage xx3 = new string[](1);
        // uint[] storage xx3 = new uint[](1);

        // storage的数组可以修改长度
        stateArr.push() = 1; // 默认push一个零值类型，此时返回元素引用可直接修改元素，但不能再声明一个变量去修改
        require(stateArr[0] == 1);
        stateArr.push(2); // 传参则不返回数据。push方法只对storage的数组和bytes类型有效
        stateArr.pop(); // 无返回值。会删除一个元素，节约gas。只对storage的数组和bytes类型有效
        stateArr = a;

        testBytesString();
        test2dArray();
    }

    bytes _bs;

    // bytes和string基本是一致的，都可以表示字符串，只是string不允许index和length访问和修改
    // 对于bytes，等同于byte[]，但bytes的gas消耗更低；另外，对于固定长度的byte数组，更常用的是bytes1, bytes2...bytes32类型，它们比bytes消耗更少gas
    function testBytesString() internal {
        bytes[] memory bs = new bytes[](2);
        bs[0] = "str"; // utf8 str
        bs[1] = "\x22"; // 字节字面量
        bs[1] = "\u718a"; // unicode字面量
        bs[1] = bytes("oil"); // str 2 bytes

        string memory s = "\u718a"; // '熊'的unicode
        require(bytes(s).length == 3); // 一个utf8中文，3字节
        bytes1 b1 = bytes(s)[0]; // 下标读取字节
        // emit PrintUnicode(b1);
        require(b1[0] == bytes1("\xe7")); // '熊'的字节是 b'\xe7\x86\x8a'

        // solidity提供的string功能较少，所以一般使用其工具库：https://github.com/willitscale/solidity-util/blob/master/lib/Strings.sol
        // s[0]; // 不允许下标访问string

        // 初始长度为0
        require(_bs.length == 0);
        _bs = "";
        _bs.push("x");
        _bs[0] = 0x08;
    }

    // 支持多维数组
    function test2dArray() internal{
        // 但注意：两个[]的定义顺序与其他语言相反
        // 这代表一个外层长度为2，元素为变长数组的定长数组
        uint[][2] memory _2dArray;

        _2dArray[0] = new uint[](1); // 初始化元素数组
        _2dArray[1] = new uint[](2); // 初始化元素数组
        _2dArray[1][0]; // 读取内层数组元素
        // _2dArray[2]; // 越界
    }

    // 数组的范围下标访问，仅支持动态calldata数组，在abi解码数据时特别有用
    // 测试：将任意合约地址填入setOwner()参数框后，复制其calldata，填入此函数的参数框进行调用
    function testRangeIndex(bytes calldata _data) public {
        // uint[3] memory arr;
        // require(arr[1:3].length == 2); // 不支持

        // uint[] memory arr2 = new uint[](3);
        // require(arr2[1:3].length == 2); // 不支持

        bytes4 funcSig = bytes4(_data[:4]);
        require(funcSig == bytes4(keccak256("setOwner(address)")), "funcSig not match!");
        address owner = abi.decode(_data[4:], (address));
        require(owner != address(0), "address is 0!");

        // 假设转发_data给其他合约函数
        (bool succ, ) = address(this).call(_data);
        require(succ, "not succ!!!");
    }

    // 假设这个函数是其他合约的，此时要实现参数转发
    function setOwner(address _addr) public {}
}

