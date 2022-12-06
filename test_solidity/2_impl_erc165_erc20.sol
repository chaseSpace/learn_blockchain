// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*

实现ERC165和ERC20标准需要引入三方库OpenZeppelin，下面介绍OpenZeppelin库
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

下面代码简单介绍了其中的一些功能使用方法
*/


// 1.演示数学库的使用
contract TestMath {
    // 为类型关联方法，以便后续这个类型可以直接调用关联的方法
    using SafeMath for uint256;

    function testDiv(uint256 a, uint256 b) public pure returns (uint256) {
        return a.div(b);
        // 调用SafeMath提供的div方法，这个方法没有做特别处理，与a/b一致，若b=0则合约执行中断，所有改变回滚
    }

    function testTryDiv(uint256 a, uint256 b) public pure returns (bool, uint256) {
        return a.tryDiv(b);
        // 调用SafeMath提供的安全的除法方法，b=0不会导致中断，会返回一个bool字段以供下一步处理
    }
}

// 2. 演示Address库的使用
// Address对象提供了一些方法
// - 比如isContract判断一个地址是否是有效的合约地址，其内部是通过参数地址所关联的EVM代码的字节码长度是否大于0来判断的。
contract TestAddress {
    using Address for address;
    address private owner;

    event logIsContract(bool); // Event可以用来作为日志打印使用

    function isContract(address acc) public view returns (bool)  {
        //        return Address.isContract(acc);
        return acc.isContract();
    }
    constructor(){
        // emit logIsContract(address(this).isContract());
        require(address(this).isContract(), "构造函数执行结束前，合约地址尚未初始化");
    }
}


// 3. 演示ERC165的使用
// ERC165 规定了一个签名为     function supportsInterface(bytes4 interfaceId) external view returns (bool)  的 interface
// - 如果合约继承了这个interface，则需要对外提供这个函数，以供外部查询是否实现了这个函数，参数interfaceId是函数选择器。
// - 函数选择器就是待调用函数的哈希值的前4字节，通常以十六进制体现，如0x01ffc9a7
// - 1. 关于具体实现有1点要求，如果参数interfaceId=0xffffffff，需要返回false。
contract TestERC165 is IERC165{
    bytes4 private constant _INTERFACE_ID_ERC165 = bytes4(0x01ffc9a7);
    mapping(bytes4 => bool) private _supportedInterfaces;
    constructor(){
        // 先注册两个自有函数
        _registerInterface(_INTERFACE_ID_ERC165);
        _registerInterface(TestERC165.someFunction.selector); // 这里可以写成 this.someFunction.selector 但规范不推荐在构造函数中使用this
    }
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != bytes4(0xffffffff), "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    function someFunction(uint) external pure{}

    // 这个合约的功能之一就是提供supportsInterface给外界查询是否实现了这个合约的某个函数
    function supportsInterface(bytes4 interfaceId) external view override returns (bool){
        return _supportedInterfaces[interfaceId];
    }
}


// 4. 演示ERC20的使用
// ERC20是使用最广泛的代币标准，所有钱包和交易所都按照这个标准进行代币的支持，ERC20标准约定了代币名称、总量以及相关的交易函数
// - 这个标准中，不是所有函数都是必须实现的
// - 继承的这个ERC20是一个已经可以直接使用的合约，它实现了IERC20约定的那些接口（Interface of the ERC20）
// - 其源码路径：./node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol
// - ERC20的优点：
//      -   定义统一的函数名:名称、发行量、转账函数、转账事件等
//      -   以便交易所、钱包进行集成
//      -   所有实现了这些函数的合约都是 ERC20Token
//      -   ERC20 可以表示任何同质的可以交易的内容: 货币、股票、积分、债券、利息...
contract myToken is ERC20("MyToken", "MTK"){
    // 这里不再列出，只解释几个函数和变量用途
    // _balances和_allowances 都是mapping，分别保存了地址对应余额，某地址授权给另一个地址可使用的余额
    // decimals() 可选，返回代币小数点后的位数
    // approval(address spender, uint256 amount) bool 代币持有者授权spender可代表操作者花费代币的数量，必须触发Approval事件
    // allowance(address holder, address spender) uint256 查询spender可以消费代币持有者holder的代币数量
    // transferFrom(address from, address to, uint256 amount) bool 被授权用户代替持有者转账部分代币，成功转账必须触发Transfer事件；
    //   - 场景1：通常和approval配合使用，比如使用代币发放工资，总经理授权财务允许使用部分代币，财务再把部分代币发放给员工。
    //   - 场景2：DEX（合约处理的去中心化交易），比如alice使用DEX合约用100个代币A购买150个代币B，那么通常步骤是：alice先把100个代币A授权给DEX，
    //           然后调用DEX的兑换函数，由兑换函数调用transferFrom()转走alice的100个代币A，之后再转给alice150个代币B
}