pragma solidity ^0.6.0;


contract DMU
{
    string public constant name = "Decentralized Manufacturing Unit";
    string public constant symbol = "DMU";
    uint8 public constant decimals = 2;
    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => uint256) agent;
    mapping(address => uint256) retailer;
    mapping(address => uint256)items;
    mapping(address => mapping (address => uint256)) transaction;
    uint256 totalTokens;
    address manager;
    using SafeMath for uint256;
    
    modifier onlyManager{ 
        require(msg.sender==manager);
        _;
    }
    modifier onlyAgent{
        require(agent[msg.sender]==1);
        _;
    }
    modifier onlyRetailer{
        require(retailer[msg.sender]==1);
        _;
    }

   constructor(uint256 total) public 
    {
        totalTokens = total;
        balances[msg.sender] = totalTokens;
        manager=msg.sender;
    }
    
    function register(uint256 input) public returns (bool)
    {
        if(input==1)
        {
            if(agent[msg.sender]!=1)
            {
                agent[msg.sender]=1;
                items[msg.sender]=25;
                return true;
            } else
            return false;
        } else if (input == 2){
            if(retailer[msg.sender]!=1)
            {
                retailer[msg.sender]=1;
                return true;
            } else
            return false;
        }
    }
    function reward(address spender) onlyAgent public returns (uint256)
    {
        if(agent[msg.sender]!= 1)
        {
            revert();
        }
        uint temp=0;
        uint256 rewardOn = transaction[msg.sender][spender];
        while(rewardOn>100000)
        {
            if(rewardOn-100000>=0)
            {
                temp+=1;
                rewardOn-=100000;
            }
        }
        transaction[msg.sender][spender]=rewardOn;
        // require(balances[manager]>=100000);
        balances[msg.sender]-=temp*1000;
        balances[spender]+=temp*1000;
        return temp*1000;
    }
    function approveTo(address add) payable onlyManager public
    {
        if(manager!= msg.sender)
        {
            revert();
        }
        if(retailer[add]==1 || agent[add]==1) 
        {
            require(balances[manager]>=100000);
            balances[manager]-=100000;
            balances[add]+=100000;
        }
    }
    
    function totalSupply() public view returns (uint256) 
    {
        return totalTokens;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) 
    {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens) payable public returns (bool) 
    {
        require(tokens <= balances[msg.sender]);
        if(agent[to]==1 && retailer[msg.sender]==1){
            transaction[to][msg.sender]+=tokens;
            items[to]-=tokens/10000;
            
        }
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function availabilityAt(address agent) public view returns(uint256)
    {
        return items[agent];
    }
    
    function returnProduct(address add, uint256 item) payable onlyRetailer public returns (uint256)
    {
       if(retailer[msg.sender]!= 1)
       {
            revert();
       }
       balances[add]-=item*10000;
       balances[msg.sender]+=item*10000;
       transaction[add][msg.sender]-=item*10000;
       items[add]+=item;
       return item*10000;
        
    }
    function approve(address spender, uint256 tokens) public returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint) {
        return allowed[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint256 tokens) payable public returns (bool) {
        require(tokens <= balances[from]);
        require(tokens <= allowed[from][msg.sender]);

        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}

library SafeMath 
{
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}