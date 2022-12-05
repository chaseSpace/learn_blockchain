// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/*

OpenZeppelin库介绍
-   是以太坊生态中一个了不起的项目，它提供了许多经过社区反复审计及验证的合约模板（如ERC20，ERC721）及函数库如SafeMath，开发者可以使用
    这些现有的模板代码进行项目开发，可以提高项目的开发效率以及安全性。

-   子目录用途介绍
    -   cryptography   加解密，实现了椭圆曲线签名和merkle证明工具
    -   introspection   合约自身可提供的函数接口，目前主要实现了ETC165和ERC1820
    -   math    数学运算
    -   token   实现了ERC20、ERC721、ERC777
    -   ownership   实现了合约所有权
    -   access      实现了合约函数的访问控制功能
    -   crowdsale   实现了合约众筹、代币定价等功能
    -   lifecycle   实现了生命周期功能，如可暂定、可销毁操作
    -   payment     实现了合约资金托管、如支付、充值、取回、悬赏等功能
    -   utils       一些工具方法，如判断是否为合约地址、数组操作、函数可重入的控制

下面代码介绍了其中的一些功能使用方法
*/


contract TestMath {
    // 为类型关联方法，以便后续这个类型可以直接调用关联的方法
    using SafeMath for uint256;

    function testDiv(uint256 a, uint256 b) public pure returns (uint256) {
        return a.div(b); // 调用SafeMath提供的div方法，这个方法没有做特别处理，与a/b一致，若b=0则合约执行中断，所有改变回滚
    }

    function testTryDiv(uint256 a, uint256 b) public pure returns (bool, uint256) {
        return a.tryDiv(b); // 调用SafeMath提供的安全的除法方法，b=0不会导致中断，会返回一个bool字段以供下一步处理
    }
}

// Address对象提供了一些方法
// - 比如isContract判断一个地址是否是有效的合约地址，其内部是通过参数地址所关联的EVM代码的字节码长度是否大于0来判断的。
contract TestAddress{
    using Address for address;
    function isContract(address acc) public view returns(bool)  {
//        return Address.isContract(acc);
        return acc.isContract();
    }
}
