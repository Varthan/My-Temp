pragma solidity ^0.4.0;

contract user_registeration
{
     struct bank_Details
    {
        string name;
        uint256 bal;
        bool status;
        uint256 time;
    }
    
    mapping(address=>bank_Details)public bank;
    
    function register(string name,uint256 amt)public returns(string)
    {
        if(bank[msg.sender].status==false)
        {
            bank[msg.sender].name=name;
            bank[msg.sender].bal=amt;
            bank[msg.sender].time=now;
            bank[msg.sender].status=true;
            return "Successfully Registered";
        }
        else
        {
            return "Account Alreay Exist";
        }
    }
}

contract bank is user_registeration
{
    address public owner;
    uint  total_amount;
    function bank() public
    {
        owner=msg.sender;
        total_amount=0;
        
    }
    
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
   mapping(address=>uint) public balance;
   function deposit() public payable{
       require(msg.value>0);
       balance[owner]+=msg.value;
       total_amount=total_amount+msg.value;
       
   }
   function withdraw() public payable onlyOwner
   {
       require(balance[owner]>msg.value);
       balance[owner]-=msg.value;
       total_amount=total_amount-msg.value;
       
   }
   function transfer(address to)public payable onlyOwner 
   {  
       require(balance[owner]>msg.value);
       balance[to]=balance[to]+msg.value;
       balance[owner]-=msg.value;
       //to.transfer(msg.value);
       total_amount-=msg.value;
    }
    function GetBalance() public view returns (uint256) {
        return balance[msg.sender];
    }
    function GetBankBalance() public view onlyOwner returns (uint256){
        return total_amount;
    }
}



contract loan is bank
{
    //uint256 public ln_req_count=0;
    struct loan_req_send
    {
        string bank_name;
        address bank_address;
        uint256 amount;
        string status;
    }
    
    mapping (address=>mapping(uint256=>loan_req_send))public ln_req_send;
    mapping(address=>uint256)public ln_req_count;
    
    struct loan_req_rec
    {
        uint256 req_id;
        string bank_name;
        address bank_address;
        uint256 amount;
    }
    
    mapping (address=>mapping(uint256=>loan_req_rec))public ln_req_rec;
    mapping(address=>uint256)public ln_rec_count;
    
    function loan_req_reply(uint256 req_id,string status) returns(string)
    {
        uint256 ln_req_id = ln_req_rec[msg.sender][req_id].req_id;
        address loan_add = ln_req_rec[msg.sender][req_id].bank_address;
        string cli_st = ln_req_send[loan_add][ln_req_id].status;
        
        require(keccak256(cli_st)!=keccak256("Accepte"));
        require(keccak256(cli_st)!=keccak256("Reject"));
        
        if(keccak256(status)==keccak256("Accepte"))
        {
            require (ln_req_rec[msg.sender][req_id].amount <= bank[msg.sender].bal);
            
            bank[loan_add].bal += ln_req_rec[msg.sender][req_id].amount;
            bank[msg.sender].bal -= ln_req_rec[msg.sender][req_id].amount;
            ln_req_send[loan_add][ln_req_id].status=status;
            
            return "Loan Accepted";
        }
        else if(keccak256(status)==keccak256("Reject"))
        {
            ln_req_send[loan_add][ln_req_id].status=status;
            return "Loan Rejected";
        }
        else
        {
            return "Please Enter correct status";
        }
    }
    
    function req(address bank_address,uint256 amt)public
    {
        /*if(ln_req_count[msg.sender]==0)
        {
            ln_req_count[msg.sender]=1;
        }*/
        require(bank[bank_address].status);
        require(bank[msg.sender].status);
        require(bank_address!=msg.sender);
        
        ln_req_send[msg.sender][ln_req_count[msg.sender]].bank_name = bank[bank_address].name;
        ln_req_send[msg.sender][ln_req_count[msg.sender]].bank_address = bank_address;
        ln_req_send[msg.sender][ln_req_count[msg.sender]].amount = amt;
        
        ln_req_rec[bank_address][ln_rec_count[bank_address]].bank_name = bank[msg.sender].name;
        ln_req_rec[bank_address][ln_rec_count[bank_address]].bank_address = msg.sender;
        ln_req_rec[bank_address][ln_rec_count[bank_address]].amount = amt;
        ln_req_rec[bank_address][ln_rec_count[bank_address]].req_id = ln_req_count[msg.sender];
        
        ln_rec_count[bank_address]++;
        ln_req_count[msg.sender]++;
    }
}
