// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@合约类型
-   介绍
    - 上节课中编写的contract对象即是一个合约类型，我们把合约对象的名词也叫做是它的合约类型。
    - 合约类型可以拥有状态变量和函数，可以通过 contractType.Var 或 contractType.Func() 调用该合约类型的变量及函数
        - 从外部调用时，需要遵循所调用变量或函数的可见性规则，即public/private
    - 合约类型可以显式转换为合约地址类型，从而可以调用地址的转账函数
    - 通过 selfdestruct()函数可以销毁当前合约，该函数接收一个收款地址参数，以接收当前合约地址中的以太币余额
        - 这个函数不会自动调用收款地址的receive()

-   从v0.6开始，对于合约C，可通过type(C)获得合约的类型信息
    - 如 type(C).name 获得合约名
    - type(C).creationCode 获得合约部署字节码
    - type(C).runtimeCode  获得合约runtime字节码

-   如何显式的分辩外部账户 与 合约账户
    -   EVM提供一个指令 extcodesize 来获取地址下的代码长度，若是外部账户则没有代码返回
*/

contract Example {
    uint public var1;
    uint var2; // 默认internal

    // payable允许创建合约时注入一些以太币，以便下面的Destruct()测试
    constructor() payable {
        var1 = 1;
        // this.someFunc(); // 注意：一旦在构造函数中使用this，则其他合约不能再动态创建此合约的实例：exp = new Example();
    }

    function someFunc() public returns(uint) {
        // 获取自己的合约地址
        // address exampleAddr = address(this);
        var2 = 2;
        return var2;
    }

    function destruct(address payable receipent) public {
        selfdestruct(receipent);
    }
}

contract Utils{
    function isContract(address addr) public view returns (bool){
        uint256 size;
        assembly {
            size :=  extcodesize(addr)
        }
        return size > 0;
    }
}

// 测试1：测试合约类型与地址的转换、转换后的合约调用、extcodesize使用、销毁合约方法调用
contract LearnContractType is Utils{ // 继承Utils使用其方法
    // 声明一合约类型
    Example exp;

    // 声明一个事件 来记录下面的销毁操作
    event destructContract(string, bytes, bytes);

    constructor(address exampleAddr)   {
        exp = Example(exampleAddr);
        uint v1 = exp.var1(); // 在合约外访问其成员变量，需要加括号
        uint v2 = exp.someFunc();
        require(v1+v2 == 3, "v1+v2 != 3 ???");
    }


    // 这个函数将销毁上面的Example合约，所以第二次调用时会断言失败！
    function destructExample() public{
        // 销毁前判断该地址是否一个合约地址
        require(isContract(address(exp)), "already not a contract addr!");

        emit destructContract(type(Example).name, type(Example).creationCode, type(Example).runtimeCode);

        // 传入当前合约地址作为收款者，注意：当前合约此时无需定义receive()
        exp.destruct(payable(address(this)));
    }
}

// 测试2：合约对象的创建
contract LearnCreateContractObj is Utils {
    Example exp;
    constructor() {
        // 上面的测试是通过合约实例的address转换回合约实例，而这里我们通过新创建一个合约实例来调用其成员变量以及函数
        exp = new Example();
        require(exp.var1() + exp.someFunc() == 3, "333");
        // 注意：构造函数执行结束之前，当前合约不能收款
        // exp.destruct(payable(address(this)));
        // require(!isContract(address(exp)), "still is a contract addr!");
    }
}