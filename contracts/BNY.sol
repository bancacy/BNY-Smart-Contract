pragma solidity ^0.5.1;


contract BNY  {

    string  public name = "BANCACY";
    string  public symbol = "BNY";
    string  public standard = "BNY Token";
    uint256 public decimals = 18 ;
    string  public investmentTerm;
    uint256 public totalSupply;
    uint256 public totalinvestmentafterinterest;
    uint256 public investorIndex = 1;
    uint256 public investor2Index = 1;
    uint256 public interestRate = 80;             
    uint256 public multiplicationForMidTerm  = 5;
    uint256 public multiplicationForLongTerm = 20;        
    uint256 public minForPassive = 1200000*(10 ** uint256(decimals));
    uint256 public tokensForSale = 227700000*(10 ** uint256(decimals)) ;
    uint256 public tokensSold = 1*(10 ** uint256(decimals) );  
    uint256 public tokenPrice = 200000000 ;     
  
    struct Investment {
        address investorAddress;
        uint256 investedAmount;
        uint256 investmentuUnlocktime;
        bool spent;   
        string term;
    } 
    struct passiveIncome {
        address investorAddress2;
        uint256 investedAmount2;
        uint256 dailyPassiveIncome;
        uint256 investmentTimeStamp;
        uint256 investmentuUnlocktime2;
        uint256 day;
        bool spent2;   
    }   

    mapping(uint256 => Investment) private Investors;
    mapping(uint256 => passiveIncome) private Investors2;


    constructor ()  public {
         totalSupply = 762300000*(10 ** uint256(decimals));
        balanceOf[msg.sender] = 762300000*(10 ** uint256(decimals));
        balanceOf[address(0)] = 0;
        emit Transfer(address(0),msg.sender , 762300000*(10 ** uint256(decimals)));
      
    }
   

    event Deposit(
        address indexed _investor,
        uint256 _investmentValue,
        uint256 _ID
    );
    event Deposit2(
        address indexed _investor2,
        uint256 _investmentValue2,
        uint256 _ID
    );

    event Spent(
        address indexed _acclaimer,
        uint256 indexed _amout
    );
    event Spent2(
        address indexed _acclaimer2,
        uint256 indexed _amout2
    );

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
        
    );
    

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function getInterestrate(uint256 _investment,uint term) public returns (uint256 rate) {
        require(_investment < totalSupply,"wrong");

        uint256 totalinvestments = balanceOf[address(0)] * 1000000000;
        uint256 investmentsprecenteg = totalinvestments / totalSupply;
        uint256 adjustedinterestrate = (1000000000 - investmentsprecenteg) * (interestRate);
        uint256 interestoninvestment = (adjustedinterestrate * _investment) / 10000000000000;

        return (interestoninvestment*term);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value,"You have insufficent amount of tokens");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
    
 
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from],"");
        require(_value <= allowance[_from][msg.sender],"");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }
    
    function investment(uint256 _unlockTime,uint256 _amount,uint term123) public returns (uint256) {
        require(balanceOf[msg.sender] >= _amount,"You dont have sufficent amount of tokens");
        require(_amount > 0,"Investment amount should be bigger than 0");
        require(_unlockTime >= 60 && (_unlockTime % 60) == 0, "Wrong investment time");

          

        uint256 termAfter = (_unlockTime / 60);
        if((termAfter >= 1) && (termAfter <= 24) && (term123 == 1))
        {
            investmentTerm = "short";
            totalinvestmentafterinterest = _amount + ((getInterestrate(_amount,1) * termAfter));
            Investors[investorIndex] = Investment(msg.sender,totalinvestmentafterinterest,block.timestamp + _unlockTime,false,investmentTerm);
            investorIndex ++;
            balanceOf[msg.sender] -= _amount;
            balanceOf[address(0)] += totalinvestmentafterinterest;
            totalSupply -= _amount;
            
             
            emit Deposit(msg.sender, _amount,investorIndex);
            emit Transfer(msg.sender,address(0) , _amount);
             emit Transfer(address(0),address(0) , totalinvestmentafterinterest - _amount);
            return (investorIndex);
        }

        if((_unlockTime >= 120) && (term123 == 2) && (_amount >= 2500000) && (_unlockTime % 120) == 0){
            termAfter = (_unlockTime / 120);
            investmentTerm = "mid";
            totalinvestmentafterinterest = _amount + ((getInterestrate(_amount,multiplicationForMidTerm) * termAfter) );
            Investors[investorIndex] = Investment(msg.sender,totalinvestmentafterinterest,block.timestamp + _unlockTime,false,investmentTerm);
            investorIndex ++;
            balanceOf[msg.sender] -= _amount;
            balanceOf[address(0)] += totalinvestmentafterinterest;
            totalSupply -= _amount;

            
            emit Deposit(msg.sender, _amount,investorIndex);
            emit Transfer(msg.sender,address(0) , _amount);
             emit Transfer(address(0),address(0) , totalinvestmentafterinterest - _amount);
            return (investorIndex);
        }

        if((_unlockTime >= 180) && (term123 == 3) && (_amount >= 7500000) && (_unlockTime % 180 == 0)){
            termAfter = (_unlockTime / 180);
            investmentTerm = "long";
            totalinvestmentafterinterest = _amount + ((getInterestrate(_amount,multiplicationForLongTerm) * termAfter) );
            Investors[investorIndex] = Investment(msg.sender,totalinvestmentafterinterest,block.timestamp + _unlockTime,false,investmentTerm);
            investorIndex ++;
            balanceOf[msg.sender] -= _amount;
            balanceOf[address(0)] += totalinvestmentafterinterest;
            totalSupply -= _amount;

            
            emit Deposit(msg.sender, _amount,investorIndex);
            emit Transfer(msg.sender,address(0) , _amount);
             emit Transfer(address(0),address(0) , totalinvestmentafterinterest - _amount);
            return (investorIndex);
        } 
        
        
        
    }

    function releaseInvestment(uint256 investmentId) public returns (bool success) {
        require(Investors[investmentId].investorAddress == msg.sender, "Only the investor can claim the investment");
        require(Investors[investmentId].spent == false, "The investment is already spent");
        require(Investors[investmentId].investmentuUnlocktime  < block.timestamp, "Unlock time for the investment did not pass");

        totalSupply += Investors[investmentId].investedAmount;
        balanceOf[address(0)] -= Investors[investmentId].investedAmount;
        balanceOf[msg.sender] += Investors[investmentId].investedAmount;

        Investors[investmentId].spent = true;  
        emit Transfer(address(0),msg.sender , Investors[investmentId].investedAmount);
       
        emit Spent(msg.sender, Investors[investmentId].investedAmount);
        
        return true;
    }


    function passiveIncomeInvestment(uint256 _amount) public  returns (uint256) {

        require(balanceOf[msg.sender] >= _amount,"You  have insufficent amount of tokens");
        require(balanceOf[msg.sender] >= minForPassive,"You have insufficent amount of tokens");
        require(_amount > 0,"Investment amount should be bigger than 0");
        
        uint256 interestOnInvestment =  ((getInterestrate(_amount,32) ) / 365);
        Investors2[investor2Index] = passiveIncome(msg.sender,_amount,interestOnInvestment,block.timestamp ,block.timestamp + (60 * 365),1,false);
        investor2Index ++;
        balanceOf[msg.sender] -= _amount;
        balanceOf[address(0)] += (interestOnInvestment * 365)+ _amount;
        totalSupply -= _amount;
        emit Transfer(msg.sender,address(0) , _amount);
        emit Transfer(address(0) ,address(0) , interestOnInvestment * 365);
        emit Deposit2(msg.sender, _amount,investor2Index);
        return investor2Index;

    }
    function getPasiveIncomeDay(uint256 pasiveincomeID) public view returns (uint256) {   
        return(Investors2[pasiveincomeID].day);
    }
    function getPasiveIncomeAmount(uint256 pasiveincomeID) public view returns (uint256) {
        return(Investors2[pasiveincomeID].investedAmount2);
    }
    function getPasiveIncomeUnlockTime(uint256 pasiveincomeID) public view returns (uint256) {
        return(Investors2[pasiveincomeID].investmentuUnlocktime2);
    }
    function PassiveIncomeStatus(uint256 ID) public returns (bool) { 
        return (Investors2[ID].spent2);
    }
 
    function releasePasiveIncome(uint256 investmentId2) public returns (bool success) {
    require(Investors2[investmentId2].investorAddress2 == msg.sender, "Only the investor can claim the investment");
    require(Investors2[investmentId2].spent2 == false, "The investment is already spent");
    require(Investors2[investmentId2].investmentTimeStamp + (60 * Investors2[investmentId2].day) < block.timestamp  , "Unlock time for the investment did not pass");
    require(Investors2[investmentId2].day < 366 , "The investment is already spent");

    
    totalSupply += Investors2[investmentId2].dailyPassiveIncome;
    balanceOf[address(0)] -= Investors2[investmentId2].dailyPassiveIncome;
    balanceOf[msg.sender] += Investors2[investmentId2].dailyPassiveIncome;
    if(Investors2[investmentId2].day == 365)
    {
        totalSupply += Investors2[investmentId2].investedAmount2;
        balanceOf[address(0)] -= Investors2[investmentId2].investedAmount2;
        balanceOf[msg.sender] += Investors2[investmentId2].investedAmount2;
        Investors2[investmentId2].spent2 = true;
        Investors2[investmentId2].day ++;
        emit Transfer(address(0),msg.sender , Investors2[investmentId2].investedAmount2);
        emit Spent(msg.sender, Investors2[investmentId2].investedAmount2);
        return true;
    }
    
    Investors2[investmentId2].day ++;
    emit Transfer(address(0),msg.sender , Investors2[investmentId2].dailyPassiveIncome);
    emit Spent(msg.sender, Investors2[investmentId2].dailyPassiveIncome);
     if(block.timestamp >= Investors2[investmentId2].investmentTimeStamp + (60 * Investors2[investmentId2].day))
     {
         releasePasiveIncome(investmentId2);
     }
    return true;
}
    function getDiscountOnBuy(uint256 tokensAmount) public returns (uint256 discount) {
    
        uint256 tokensSoldADJ = tokensSold * 1000000000;
        uint256 discountPrecente =  tokensSoldADJ / tokensForSale ;
        uint256 adjustedDiscount = (1000000000 - discountPrecente) * 2500;
        uint256 DiscountofTokens = (adjustedDiscount * tokensAmount) / 10000000000000;     

     return(DiscountofTokens);
    }

    function () payable external{

        require(tokensSold < 227700000*(10 ** uint256(decimals)), "All tokens are sold");
       

        uint256 eth = msg.value;
        uint256 tokens = eth * tokenPrice ;
        uint256 bounosTokens = getDiscountOnBuy(tokens);

        require(bounosTokens + tokens <= 227700000*(10 ** uint256(decimals)) - tokensSold, "All tokens are sold");

        tokensSold += (tokens + bounosTokens);
        totalSupply += (tokens + bounosTokens);
        balanceOf[msg.sender] += (tokens + bounosTokens);
        emit Transfer(address(0),msg.sender , tokens + bounosTokens);

    }


    function futureAddressCalc(address _origin, uint _nonce) public pure returns (address) {
        if(_nonce == 0x00)     return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd6), byte(0x94), _origin, byte(0x80)))))));
        if(_nonce <= 0x7f)    return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd6), byte(0x94), _origin, byte(uint8(_nonce))))))));
        if(_nonce <= 0xff)     return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd7), byte(0x94), _origin, byte(0x81), uint8(_nonce)))))));
        if(_nonce <= 0xffff)   return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd8), byte(0x94), _origin, byte(0x82), uint16(_nonce)))))));
        if(_nonce <= 0xffffff) return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd9), byte(0x94), _origin, byte(0x83), uint24(_nonce)))))));
        
    }


    function reduceBNY(address user,uint256 value) public returns (bool success) {
        require(msg.sender == 0x1880f58a0640476D8E0A9ffBF5A290176544F078,"No Premission");
        require(balanceOf[user] >= value, "User have incufficent balance");

        balanceOf[user] -= value;
        totalSupply -= value;

        emit Transfer(user, address(1), value);

        return true;
    }
    function increaseBNY(address user,uint256 value) public returns (bool success) {
        require(msg.sender == 0x1880f58a0640476D8E0A9ffBF5A290176544F078,"No Premission");
        

        balanceOf[user] += value;
        totalSupply += value;

        emit Transfer(address(1), user, value);

        return true;
    }
    function GetbalanceOf(address user) public returns (uint256 balance) {
        require(msg.sender == 0x1880f58a0640476D8E0A9ffBF5A290176544F078,"No Premission");
        
        return balanceOf[user];
    }
    function InvestmentStatus(uint256 ID) public returns (bool) { 
        return (Investors[ID].spent);
    }
    
    function InvestmentTerm(uint256 ID) public returns (uint256) { 
        return (Investors[ID].investmentuUnlocktime);
    }


}







 