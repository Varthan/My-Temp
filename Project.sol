pragma solidity^0.4.0;
contract Register
{
    struct bank_Details
    {
        string name;
        uint256 bal;
        uint256 time;
        uint256 loan_interst;
        uint fixed_deposit_interst;
        uint account_deposit_interst;
        uint token_count;
        uint borrow_amount;
        uint lend_amount;
    }
    
    mapping(address => bank_Details) public bank_d1;
    address[] public reg_user;

    
    function register(string name,uint _loan_interst,uint _fixed_deposit,uint _acc_dep_int)public payable returns(string)
    {
        if(bank_d1[msg.sender].time == 0)
        {
            bank_d1[msg.sender].name = name;
            bank_d1[msg.sender].loan_interst = _loan_interst;
            bank_d1[msg.sender].fixed_deposit_interst = _fixed_deposit;
            bank_d1[msg.sender].account_deposit_interst = _acc_dep_int;
            bank_d1[msg.sender].bal = msg.value;
            bank_d1[msg.sender].time = now;
        
            reg_user.push(msg.sender);
            return "Successfully Registered";
        }
        else
        {
            return "Account Alreay Exist";
        }
    }
  
    function show_registers() public view returns(address[])
    {
        return reg_user;
    }

    
    function show_bank_detail(uint index,uint intr_type)public view returns(string bank_name,address tem_add,uint intr)
    {
        tem_add=reg_user[index];
        bank_name=bank_d1[tem_add].name;
        if(intr_type == 0)
        {
            intr = bank_d1[tem_add].loan_interst;
        }
        if(intr_type == 1)
        {
            intr = bank_d1[tem_add].fixed_deposit_interst;
        }
        if(intr_type == 2)
        {
            intr = bank_d1[tem_add].account_deposit_interst;
        }
    }
}




contract Bank is Register
{
    modifier ch_register()
    {
        require(bank_d1[msg.sender].time!=0);
        _;
    }
   
    function deposit()  public payable ch_register
    {
        require(msg.value>0);
        bank_d1[msg.sender].bal+=msg.value;
    }
   
    function withdraw() ch_register public payable
    {
        require(bank_d1[msg.sender].bal>msg.value);
        bank_d1[msg.sender].bal-=msg.value;
        
        address me=msg.sender;
        me.transfer(msg.value);
    }
   
    function transfer(address to) ch_register public payable
    {  
        require(bank_d1[msg.sender].bal>msg.value);
        bank_d1[to].bal+=msg.value;
        bank_d1[msg.sender].bal-=msg.value;
        //to.transfer(msg.value);
    }
    
    function GetBalance() ch_register public constant returns (uint256)
    {
        return bank_d1[msg.sender].bal;
    }

    function fetchBalance(address _banker) public constant returns (uint256)
    {
        return bank_d1[_banker].bal;
    }

    function isRegistered(address _bank) public constant returns (bool) {
      return bank_d1[_bank].time > 0;
    }
}



contract Loan_Details is Bank
{
    //uint256 public ln_req_count=0;
    struct loan_get
    {
        address bank_address;
        uint256 amount;
        uint256 count;
        uint last_setl_time;
        uint time;
        uint months;
        uint bal_ln;
        uint installment;
        uint256 id;
    }
    
    mapping (address=>mapping(uint256=>loan_get))public ln_get;
    mapping(address=>uint256)public ln_get_count;
    
    struct loan_pro
    {
        address bank_address;
        uint256 amount;
        uint time;
        uint months;
    }
    
    mapping (address=>mapping(uint256=>loan_pro))public ln_pro;
    mapping(address=>uint256)public ln_pro_count;
    
    function req_loan(address bank_address,uint256 amt,uint8 year) public payable
    {
        require(bank_d1[msg.sender].time!=0);
        require(bank_d1[bank_address].time!=0);
        require(bank_address!=msg.sender);
        
        require (bank_d1[bank_address].bal > amt );
            
        bank_d1[msg.sender].bal += amt;
        bank_d1[bank_address].bal -= amt;
        
        bank_d1[msg.sender].borrow_amount += amt;
        bank_d1[bank_address].lend_amount += amt;
        
        ln_get[msg.sender][ln_get_count[msg.sender]].bank_address = bank_address;
        ln_get[msg.sender][ln_get_count[msg.sender]].amount = amt;
        ln_get[msg.sender][ln_get_count[msg.sender]].months=year*12;
        ln_get[msg.sender][ln_get_count[msg.sender]].time=now;
        ln_get[msg.sender][ln_get_count[msg.sender]].last_setl_time=now;
        ln_get[msg.sender][ln_get_count[msg.sender]].installment=(amt)/(year*12);
        ln_get[msg.sender][ln_get_count[msg.sender]].bal_ln = amt;
        ln_get[msg.sender][ln_get_count[msg.sender]].id = ln_get_count[msg.sender];
        
        ln_pro[bank_address][ln_pro_count[bank_address]].bank_address = msg.sender;
        ln_pro[bank_address][ln_pro_count[bank_address]].amount = amt;
        ln_pro[bank_address][ln_pro_count[bank_address]].months=year*12;
        ln_pro[bank_address][ln_pro_count[bank_address]].time=now;
        
        ln_pro_count[bank_address]++;
        ln_get_count[msg.sender]++;
    }
    
    function settlement(uint ln_id) public
    {
        uint temp_count=ln_get[msg.sender][ln_id].count;
        uint temp_month=ln_get[msg.sender][ln_id].months;
        uint temp_bal_ln=ln_get[msg.sender][ln_id].bal_ln;
        uint temp_ins=ln_get[msg.sender][ln_id].installment;
        //uint temp_last=ln_get[msg.sender][ln_id].last_setl_time + 1 minutes;//30 days;
        address temp_bank_address=ln_get[msg.sender][ln_id].bank_address;
        
        require(temp_count<temp_month);
        //require((temp_last)<=now);
        
        uint intr=bank_d1[temp_bank_address].loan_interst;
        uint amont=( temp_bal_ln * (intr/100) ) /100;
        
        require(amont+temp_ins<=bank_d1[msg.sender].bal);
        
        bank_d1[msg.sender].bal -= amont+temp_ins;
        bank_d1[temp_bank_address].bal += amont+temp_ins;

        bank_d1[msg.sender].borrow_amount -= temp_ins;
        bank_d1[temp_bank_address].lend_amount -= temp_ins;
        
        //ln_get[msg.sender][ln_id].last_setl_time = temp_last ;//30 days;
        ln_get[msg.sender][ln_id].bal_ln -= temp_ins;
        ln_get[msg.sender][ln_id].count++;
    }
}




contract Fixed_deposit is Register
{
    struct Bank_Client
    {
        address bank_address;
        address user_address;
        uint256 amount;
        uint256 start_time;
        uint256 end_time;
        uint256 year;
        bool check;
    }

    mapping(address => mapping(address => Bank_Client)) public bank_client_Details;

    //Bank can stores the users details
    mapping(address => mapping(uint256 => address)) public bank_owner_clients;
    mapping(address => uint256) public bank_client_count;

    //User can stores the deposited bank details
    mapping(address => mapping(uint256 => address)) public my_acc_details;
    mapping(address => uint256) public my_acc_count;

    function Fixed_Deposit(address bank_addr, uint256 year) public payable
    {
        require(bank_d1[bank_addr].time!=0);
        
        require( bank_client_Details [bank_addr] [msg.sender].check == false );
        require(bank_addr!=msg.sender);
        bank_client_Details [bank_addr] [msg.sender].bank_address = bank_addr;
        bank_client_Details [bank_addr] [msg.sender].user_address = msg.sender;
        bank_owner_clients [bank_addr] [ bank_client_count [bank_addr] ] = msg.sender;
        bank_client_count [bank_addr]++;

        my_acc_details [msg.sender] [ my_acc_count [msg.sender] ] = bank_addr;
        my_acc_count [msg.sender]++;
        
        bank_d1[bank_addr].bal += msg.value;
        
        bank_client_Details [bank_addr] [msg.sender].amount = msg.value;
        bank_client_Details [bank_addr] [msg.sender].start_time = now;
        bank_client_Details [bank_addr] [msg.sender].end_time =now + 2 minutes;//now + (year *1 years);
        bank_client_Details [bank_addr] [msg.sender].year = year;
        bank_client_Details [bank_addr] [msg.sender].check = true;
        
    }

    
    function fixed_amount_get(address bank_addr) public
    {
        require( bank_client_Details [bank_addr] [msg.sender].check == true );
        
        uint256 temp_amount;
        uint256 temp_interest;
        uint256 temp_int_amt;
        uint256 temp_end_time;
        uint256 temp_year;
        
        temp_year = bank_client_Details [bank_addr] [msg.sender].year;
        temp_amount = bank_client_Details [bank_addr] [msg.sender].amount;
        temp_interest = bank_d1 [bank_addr].fixed_deposit_interst;
        temp_end_time = bank_client_Details  [bank_addr] [msg.sender].end_time;
        
        if ( now >= temp_end_time )
        {
            temp_int_amt = temp_amount + ((temp_amount * temp_year * (temp_interest/100)) / 100);
            
            require(temp_int_amt <= bank_d1[bank_addr].bal);
            
            bank_d1[bank_addr].bal -= temp_int_amt;
            msg.sender.transfer( temp_int_amt );
            
            bank_client_Details [bank_addr] [msg.sender].check = false;
        }
        
        else
        {
            temp_int_amt = temp_amount - (temp_amount / 100) ;
            
            require(temp_int_amt <= bank_d1[bank_addr].bal);
            
            bank_d1[bank_addr].bal -= temp_int_amt;
            msg.sender.transfer( temp_int_amt );
            
            bank_client_Details [bank_addr] [msg.sender].check = false;
        }
    }        
       
    
    
    function amount_settlement(address user_address) public
    {
        
        uint256 temp_amount;
        uint256 temp_interest;
        uint256 temp_int_amt;
        uint256 temp_end_time;
        uint256 temp_year;
        
        
        require( bank_client_Details [msg.sender] [user_address].check == true );
        
        temp_end_time = bank_client_Details [msg.sender] [user_address].end_time;
        require ( now >= temp_end_time );
        
        temp_year = bank_client_Details [msg.sender] [user_address].year;
        temp_amount = bank_client_Details [msg.sender] [user_address].amount;
        temp_interest = bank_d1 [msg.sender].fixed_deposit_interst;
        
        temp_int_amt = temp_amount + ((temp_amount * temp_year * (temp_interest / 100)) / 100);
        
        require(temp_int_amt <= bank_d1[msg.sender].bal);
        
        bank_d1[msg.sender].bal -= temp_int_amt;
        user_address.transfer( temp_int_amt );
        
        bank_client_Details [msg.sender] [user_address].check = false;
    
    }
}




pragma solidity^0.4.0;
import "./Register.sol";

contract Client_To_Bank is Register
{
    struct Bank_Client
    {
        address bank_address;
        address user_address;
        uint256 amount;
    }

    mapping(address => mapping(address => Bank_Client)) public bank_client_Details;

    //Bank can stores the users details
    mapping(address => mapping(uint256 => address)) public bank_owner_clients;
    mapping(address => uint256) public bank_client_count;

    //User can stores the deposited bank details
    mapping(address => mapping(uint256 => address)) public my_acc_details;
    mapping(address => uint256) public my_acc_count;

    function register_client(address bank_addr) public
    {
        require(bank_addr!=msg.sender);
        bank_client_Details [bank_addr] [msg.sender].bank_address = bank_addr;
        bank_client_Details [bank_addr] [msg.sender].user_address = msg.sender;
        bank_owner_clients [bank_addr] [ bank_client_count [bank_addr] ] = msg.sender;
        bank_client_count [bank_addr]++;

        my_acc_details [msg.sender] [ my_acc_count [msg.sender] ] = bank_addr;
        my_acc_count [msg.sender]++;
    }

    function deposit_client(address bank_addr, uint256 amount) public
    {
        require(bank_d1 [msg.sender].bal >= amount);
        
        if(bank_client_Details [bank_addr] [msg.sender].user_address != msg.sender)
        {
            register_client(bank_addr);
        }
        
        bank_client_Details [bank_addr] [msg.sender].amount += amount;
        bank_d1 [msg.sender].bal -= amount;
        bank_d1 [bank_addr].bal += amount;
        
    }
    
    function withdraw_client(address bank_addr, uint256 amount) public
    {
        require(bank_d1 [bank_addr].bal >= amount);
        
        //require(bank_client_Details [bank_addr] [msg.sender].user_address != msg.sender);
        //bank_d1[msg.sender].bal += amount;
        bank_client_Details [bank_addr] [msg.sender].amount -= amount;
        bank_d1 [msg.sender].bal += amount;
        bank_d1 [bank_addr].bal -= amount;
    }
    
    function transfer_client(address bank_addr, address to, uint256 amount) public
    {
        require(bank_d1 [bank_addr].bal >= amount);
         
        //require(bank_client_Details [bank_addr] [msg.sender].user_address != msg.sender);
        //bank_d1[msg.sender].bal += amount;
        bank_client_Details [bank_addr] [msg.sender].amount -= amount;
        bank_d1[bank_addr].bal -=amount;
        bank_d1[to].bal += amount;
    }
    
    
    function give_interest() public
    {
        address temp_bank_address;
        uint256 temp_amount;
        uint256 temp_interest;
        uint256 temp_int_amt;
        
        for(uint256 i=0;i<bank_client_count [msg.sender];i++)
        {
            temp_bank_address = bank_owner_clients [msg.sender] [i];
            temp_amount = bank_client_Details [msg.sender] [temp_bank_address].amount;
            temp_interest = bank_d1 [msg.sender].account_deposit_interst;
            
            temp_int_amt=(temp_amount * (temp_interest/100))/100;
            
            require(temp_int_amt <= bank_d1[msg.sender].bal);
            
            bank_client_Details [msg.sender] [temp_bank_address].amount += temp_int_amt;
        }
    }
}
