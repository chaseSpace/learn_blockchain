// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
@合约继承
    如同其他高级语言，继承功能可以继承父类合约的非私有变量/函数，solidity支持override父类合约的函数，但不能覆写其状态变量。
    其他：
        -   通过super.func() 调用父类函数，若继承的多个父合约拥有同名函数，则可以通过 合约名.func() 调用
        -   支持一次继承多个父类合约，若父类合约之间有继承关系，则要求父类合约的书写顺序：父在前
        -   重写函数：要求父同名函数是虚函数，子函数添加override；若继承的多个父类合约具有同名虚函数，则子函数的override需要指定所有重写的父合约：override(P1, P2)
            -   private函数不能是虚函数
        -   若外部函数与子合约的状态变量的getter函数的签名一致，则会被getter函数重写
            -   2个要求：一个是被重写的函数必须是external，第二个是子合约的状态变量必须是public

@抽象合约
    -   不能被部署，通常作为父合约被继承
    -   通常会定义一些无实现的纯虚函数
    -   子函数必须实现父合约的所有虚函数，否则就仍然得被标记为 abstract

@接口合约
    -   用于定义空函数，由继承合约实现
    -   无法继承合约或接口
    -   无法定义变量/结构体/枚举
    -   可用于合约通信
*/



contract Parent {
    string name;
    uint private decimal;
    uint private _birth;
    constructor(uint _decimal) {
        decimal = _decimal;
    }

    // virtual表示是一个可被override的函数：虚函数
    function getDecimal() public virtual returns (uint){
        return decimal;
    }

    // 这个external虚函数 将被LearnInherit2的 public 变量的getter函数重写；
    function birth() external virtual returns (uint){
        return _birth;
    }
}

// 1. 继承时传入父类的构造函数参数
// contract LearnInherit is Parent(10) {
contract LearnInherit is Parent {
    // 第二种传入父类构造器参数的方式是以 子合约 修饰符的方式传入。
    constructor(string memory _name, uint _decimal) Parent(_decimal){
        // 直接使用父类状态变量
        name = _name;
    }
    // constructor(string memory _name) {
    //     // 直接使用父类状态变量
    //     name = _name;
    // }

    // 当此合约也被继承时，若此函数被重写，则这里也得添加virtual
    function getDecimal() public override virtual returns (uint) {
        return super.getDecimal();
    }
}

// 2. 多重继承，且父合约之间有继承关系，这就要求多个父类合约之间的书写关系按照父在前的顺序
contract LearnInherit2 is Parent, LearnInherit {
    uint public override birth;
    constructor(string memory _name, uint _decimal) LearnInherit(name, _decimal){
        name = _name;
    }

    function getDecimal() public override(Parent, LearnInherit) returns (uint) {
        return Parent.getDecimal();
        // 指定父合约调用函数
        // return super.getDecimal();  // 若多重继承时使用super调用父类函数，则实际调用的函数是根据继承顺序的第一个父合约，即LearnInherit
    }
}


abstract contract Example {
    uint public a;
    // 抽象合约可以声明一个没有实现的纯虚函数
    function getA() virtual public returns (uint);
}


// 3. 抽象合约
contract LearnAbstract is Example {
    // 若子合约没有实现父合约的所有虚函数，则子合约还得被标记为 abstract
    function getA() public override view returns (uint){
        return a;
    }
}

// 4. 接口合约，可被继承
interface IToken {
    function transfer(address recipient, uint amount) external;
}

// -    用于合约通信
contract Award {
    IToken immutable token;
    constructor (address _tokenAddr) {
        token = IToken(_tokenAddr);
    }

    function sendBonus(address user) public {
        token.transfer(user, 100);
    }
}