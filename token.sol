// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Energy {

    //have total supply
    //transferable
    //name
    //symbol
    //decimal
    //burnable

    //state variables//////

    uint constant totalSupply = 10000;
    uint circulatingSupply;
    string constant name = "Energy";
    string constant symbol = "ENG";
    uint constant decimal = 1e18;
    address owner;

    mapping (address => uint) public _balance;

    event tokenMint (address indexed _to, uint indexed amount);
    event _transfer (address from,address to,  uint amount);
    modifier onlyOwner () {
        require(owner == msg.sender, "No permission");
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function _totalSupply() public pure returns (uint) {
        return totalSupply;
    }

    function _name() public pure returns(string memory) {
        return name;
    }

    function _symbol() public pure returns(string memory) {
        return symbol;
    } 

    function _decimal() public pure returns(uint) {
        return decimal;
    }

    function mint(uint amount, address _to) public returns(uint) {
        circulatingSupply += amount;
        require(circulatingSupply <= totalSupply, "Total supply exceeded");
        require(_to != address(0), "mint to address zero");
        uint value = amount * decimal;
        _balance[_to] += value;
        emit tokenMint (_to, amount);
        return amount;
    }

    function transfer (address _to, uint amount) public {
        require(_to != address(0), "mint to address zero");
        require(msg.sender != _to );
        uint userBalance = _balance[msg.sender];
        require (userBalance >= amount, "You dont have enough token");
        uint burableToken = calculateBurn(amount);
        uint transferable = amount - burableToken;
        _balance[msg.sender] -= amount;
        _balance[msg.sender] += transferable;

        emit _transfer(msg.sender, _to, amount);


    }

    function _burn(uint amount) private returns(uint burnableToken) {
        burnableToken = calculateBurn(amount);
        circulatingSupply -= burnableToken / 18;


    }

    function calculateBurn (uint amount) internal pure returns (uint burn){
        burn = (amount * 10)/100;
    }

    function balanceOf(address who ) public  view returns (uint256){
       return  _balance[who];
    }

    ////////////////////////////////////////////////////////////////////////////


    mapping(address => mapping(address => uint)) _allowance;
    // event Transfer(msg.sender, _to, amount);

    modifier checkBalance(address _owner, uint amount) {
        uint balance = balanceOf(_owner);
        require(balance >= amount, "insufficient fund!");
        _;

    }

    function Approve(address spender, uint amount) external checkBalance(msg.sender, amount) {
        require(spender != address(0));
        _allowance[msg.sender][spender] += amount;
    }

    function transferFrom(address from, address _to, uint amount) external checkBalance(from, amount) {
        require(_to == msg.sender, "not spender");
        uint _allowanceBalance = _allowance[from][_to];
        require(_allowanceBalance >= amount, "funds less than amount inputed");
        
        _allowance[from][_to] -= amount;
        require(_balance[from] >= amount, "You be thief, why you wan withdraw pass the one they give you");
        uint burnableToken = _burn(amount);
        uint transferrable = amount - burnableToken;

        _balance[from] -= amount;
        _balance[_to] += transferrable;

        emit _transfer(from, _to, amount);
    }

    
}