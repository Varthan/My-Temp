pragma solidity ^0.4.0;
library calc
{
    function add(uint256 a, uint256 b) returns(uint256)
    {
        return (a+=b);
    }
    function sub(uint256 a, uint256 b) returns(uint256)
    {
        return (a-=b);
    }
}

contract ERC20
{
    uint256 totalsuply;
    function totalsupply(uint256 value)public;
    function transfer(address to, uint256 amt)public;
    function transferfrom(address from,address to, uint256 amt)public;
    function mint(uint256 amt)public;
}

contract acc is ERC20
{
    
    address owner;
    string public name;
    string public symbol;
    uint256 public decimals;
    function acc()
    {
        name="Bank";
        symbol="GV";
        decimals=18;
        owner=msg.sender;
    }
    
    modifier ch_own()
    {
        require(owner==msg.sender);
        _;
    }
    
    mapping(address=>uint256)public balance;
    
    function totalsupply(uint256 value)public
    {
        require(totalsuply==0);
        totalsuply=value;
    }
    
    using calc for uint256;
    
    function transfer(address to, uint256 amt)ch_own public
    {
        require(balance[msg.sender]>amt && amt>0);
        balance[msg.sender]=calc.sub(balance[msg.sender],amt);
        balance[to]=calc.add(balance[to],amt);
    }
    
    function transferfrom(address from,address to, uint256 amt)ch_own public
    {
        require(balance[from]>amt && amt>0);
        balance[from]=calc.sub(balance[from],amt);
        balance[to]=calc.add(balance[to],amt);
    }
    
    function mint(uint256 amt)ch_own public
    {
        require(amt<=totalsuply);
        uint256 temp=balance[msg.sender];
        require((temp+amt)<=totalsuply);
        balance[msg.sender]=calc.add(balance[msg.sender],amt);
    }
}
