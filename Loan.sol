  pragma solidity ^0.4.0;
import "./NewToken.sol"; 

contract Loan_Detail
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
    //mapping(uint => address) public reg_user;
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
    
    
    
    modifier ch_register()
    {
        require(bank_d1[msg.sender].time != 0);
        _;
    }
   
    function deposit()  public payable ch_register
    {
        require(msg.value > 0);
        bank_d1[msg.sender].bal += msg.value;
    }
   
    function withdraw( uint256 amount ) ch_register public
    {
        require(bank_d1[msg.sender].bal > amount);
        bank_d1[msg.sender].bal -= amount;
        msg.sender.transfer(amount);
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
    
    
    uint loan_count;
    uint eth= 0.01 ether;
    struct loan_details
    {
        uint loan_id;
        address lender_address;
        address borrower_address;
        address token_address;
        uint amount;
        uint settle_count;
        uint last_settle_time;
        uint loan_get_time;
        uint months;
        uint bal_loan;
        uint current_installment;
        uint ins_per_month;
        uint tokens;
        uint not_pay_count;
    }
    
    mapping(uint => loan_details) public loan;
    //mapping (address => mapping(address => mapping(uint256 => loan_details))) public loan;
    
    mapping(address => mapping(uint => uint)) public loan_get_id;
    mapping(address => uint256) public loan_get_count;
    
    mapping(address => mapping(uint => uint)) public loan_pro_id;
    mapping(address => uint256) public loan_pro_count;
    

    
    function req(address token_address,address bank_address,uint256 tokens,uint8 year)public payable
    {
        require(bank_d1[bank_address].time!=0);
        require(bank_address!=msg.sender);
        
        uint256 amt = (eth * tokens);
        
        require (bank_d1[bank_address].bal > amt );
        
        NewToken(token_address).transferFrom(msg.sender,bank_address,tokens);
        
        bank_d1[bank_address].bal-=amt;
        bank_d1[msg.sender].bal+=amt;
        //msg.sender.transfer(amt);
        
        
        bank_d1[msg.sender].borrow_amount += amt;
        bank_d1[bank_address].lend_amount += amt;

        uint intr = bank_d1[bank_address].loan_interst;
        uint amont = ( amt * (intr/100) ) /100;
        
        loan_get_id[msg.sender][ loan_get_count[msg.sender] ] = loan_count;
        loan_get_count[msg.sender]++;
        loan_pro_id[bank_address][ loan_pro_count[bank_address] ] = loan_count;
        loan_pro_count[bank_address]++;
        
        
        loan[loan_count].loan_id = loan_count;
        loan[loan_count].lender_address = bank_address;
        loan[loan_count].borrower_address = msg.sender;
        loan[loan_count].token_address = token_address;
        loan[loan_count].amount = amt;
        loan[loan_count].last_settle_time = now;
        loan[loan_count].loan_get_time = now;
        loan[loan_count].months = year*12;
        loan[loan_count].bal_loan = amt;
        loan[loan_count].current_installment = amont + ((amt)/(year*12));
        loan[loan_count].ins_per_month = (amt)/(year*12);
        loan[loan_count].tokens = tokens;
        
        loan_count++;
        
    }
    function balanceOftoken(address token) public view returns(uint)
    {   
        return NewToken(token).balanceOf(msg.sender);
    }
    
    function settlement(uint ln_id) public
    {
        
        require(loan[ln_id].borrower_address == msg.sender);
        
        //uint temp_last = loan[ln_id].last_settle_time + 1 minutes;//30 days;
        
        require(loan[ln_id].settle_count <= loan[ln_id].months);
         
        if(loan[ln_id].settle_count < loan[ln_id].months)
        {
            
            //require((temp_last) <= now);
        
            require( loan[ln_id].current_installment <= bank_d1[msg.sender].bal);
        
            bank_d1[msg.sender].bal -= loan[ln_id].current_installment;
            bank_d1[ loan[ln_id].lender_address ].bal += loan[ln_id].current_installment;

            bank_d1[msg.sender].borrow_amount -= loan[ln_id].ins_per_month;
            bank_d1[ loan[ln_id].lender_address ].lend_amount -= loan[ln_id].ins_per_month;
            loan[ln_id].bal_loan -= loan[ln_id].ins_per_month;
        
            uint intr = bank_d1[ loan[ln_id].lender_address ].loan_interst;
            uint amont = ( (loan[ln_id].bal_loan) * (intr/100) ) /100;
            loan[ln_id].current_installment = amont + loan[ln_id].ins_per_month;
        
            //ln_get[msg.sender][ln_id].last_setl_time = temp_last ;//30 days;
        
            loan[ln_id].settle_count++;
        }
        else if(loan[ln_id].settle_count == loan[ln_id].months)
        {

            bank_d1[msg.sender].bal -= loan[ln_id].bal_loan;
            bank_d1[ loan[ln_id].lender_address ].bal += loan[ln_id].bal_loan;

            bank_d1[msg.sender].borrow_amount -= loan[ln_id].bal_loan;
            bank_d1[ loan[ln_id].lender_address ].lend_amount -= loan[ln_id].bal_loan;
            loan[ln_id].bal_loan -= loan[ln_id].bal_loan;

            NewToken( loan[ln_id].token_address ).transferFrom( loan[ln_id].lender_address , msg.sender, loan[ln_id].tokens);
        }
    }
    
 }
