pragma solidity ^0.5.1;
import "./SafeMath.sol";

contract BNY   {

  using SafeMath for uint256;

    string  public name = "BANCACY";
    string  public symbol = "BNY";
    string  public standard = "BNY Token";
    uint256 public decimals = 18 ;
    string  public investmentTerm;
    uint256 public totalSupply;
    uint256 public totalInvestmentAfterInterest;
    uint256 public investorIndex = 1;
    // NOTE: Renamed this variable
    uint256 public passiveInvestorIndex = 1;
    uint256 public interestRate = 16;
    uint256 public multiplicationForMidTerm  = 5;
    uint256 public multiplicationForLongTerm = 20;
    uint256 public minForPassive = 12000000 * (10 ** uint256(decimals));
    uint256 public tokensForSale = 227700000 * (10 ** uint256(decimals));
    // REVIEW: WHy does this start at one?
    // ANS: there is function that use this value and it cant be 0 due to dividing by zero
    // DONE: OK.
    uint256 public tokensSold = 1 * (10 ** uint256(decimals));

    uint256 public tokenPrice = 206000;
    uint256 public Precent = 1000000000;

    // NOTE: Added these variables
    uint256 internal day = 86400;
    uint256 internal week = 604800;
    uint256 internal month = 2419200;
    uint256 internal quarter = 7257600;
    uint256 internal year = 31536000;

    // TESTNET Overrides
    day = 864;// 14.4 minutes
    week = 6048; // 100.8 minutes 
    month = 24192; // 403.2 minutes /  6.72 hours
    quarter = 72576; // 0.84 days / 20.16 hours
    year = 315360;// 3.65 days
    minForPassive = 12000 * (10 ** uint256(decimals));
    tokenPrice = 100;
    ////////////////////////////////////

    // Note: Added a clear label for this value
    uint256 internal _startSupply = 762300000 * (10 ** uint256(decimals));

    address payable public fundsWallet;

    // The Structs should be capital letters
    struct Investment {
        address investorAddress;
        uint256 investedAmount;
        uint256 investmentuUnlocktime;
        bool spent;
        string term;
    }
    
    struct PassiveIncome {
        address investorAddress2;
        uint256 investedAmount2;
        uint256 dailyPassiveIncome;
        uint256 investmentTimeStamp;
        uint256 investmentuUnlocktime2;
        uint256 day;

        // REVIEW: Can we remove the 2?
        // ANS: lets keep it like this so we will know its passiveincome
        // DONE:
        bool spent2;
    }

    mapping(uint256 => Investment) private investors;

    // NOTE: Renamed this variable
    mapping(uint256 => PassiveIncome) private passiveInvestors;
    constructor (address payable _fundsWallet)  public {
        totalSupply = _startSupply;
        balanceOf[msg.sender] = _startSupply;

        // REVIEW: Why do you track the tokens in the Burn ZERO address, rather than in the contract address itself. (So that they could be recovered)
        // ANS: its more comfort to track it at ZERO address.
        // DONE:
        balanceOf[address(0)] = 0;
        emit Transfer(address(0), msg.sender, _startSupply);
        fundsWallet = _fundsWallet;
    }

    event Deposit(
        address indexed _investor,
        uint256 _investmentValue,
        uint256 _ID,
        uint256 _unlocktime,
        string _investmentTerm
    );

    event PassiveDeposit(
        address indexed _investor2,
        uint256 _investmentValue2,
        uint256 _ID2,
        uint256 _unlocktime2,
        // REVIEW: ALL "2" and then no "2" at the end.
        // Because last 2 is unique to PassiveDeposit
        uint256 _dailyIncome,
        uint256 _investmentTime
    );

    event Spent(
        address indexed _acclaimer,
        uint256 indexed _amout
    );

    // REVIEW: Can we rename this event? PassiveSpent ?
    // ANS: Yes
    event PassiveSpent(
        // REVIEW: Can we remove the 2 after these variables?
        // The variables don't matter in events, as long as the web3 call knows results._acclaimer 
        // ANS: I dont know, it does not make pr
        address indexed _acclaimer2,

        // REVIEW: Can we remove the 2 after these variables?
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
        require(_investment < totalSupply, "The investment is too large");

        uint256 totalinvestments = balanceOf[address(0)].mul(Precent);
        uint256 investmentsprecenteg = totalinvestments.div(totalSupply);
        uint256 adjustedinterestrate = (Precent.sub(investmentsprecenteg)).mul(interestRate);

        // REVIEW: Why the large division, what are these numbers representing?
        uint256 interestoninvestment = (adjustedinterestrate.mul(_investment)).div(10000000000000);

        return (interestoninvestment.mul(term));
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "You have insufficent amount of tokens");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
    
 
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Value must be less or equal to the balance.");
        require(_value <= allowance[_from][msg.sender], "Value must be less or equal to the balance.");

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function investment(uint256 _unlockTime, uint256 _amount, uint term123) public returns (uint256) {
        require(balanceOf[msg.sender] >= _amount, "You dont have sufficent amount of tokens");
        require(_amount > 0, "Investment amount should be bigger than 0");
        // HERE PLEASE
        // REVIEW:  Is this MOD test to make sure people don't choose random times? You want whole weeks?
        // Yes, only whole weeks
        // DONE
        require(_unlockTime >= week && (_unlockTime.mod(week)) == 0, "Wrong investment time");
        
        // NOTE: I changed these to variables.
        uint256 termAfter = (_unlockTime.div(week));
        if((termAfter >= 1) && (termAfter <= 48) && (term123 == 1))
        {
            investmentTerm = "short";
            totalInvestmentAfterInterest = _amount.add(((getInterestrate(_amount,1).mul(termAfter))));
            investors[investorIndex] = Investment(msg.sender, totalInvestmentAfterInterest, block.timestamp.add(_unlockTime), false, investmentTerm);
            investorIndex = investorIndex.add(1);
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);

            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);

            emit Deposit(msg.sender, _amount, investorIndex, block.timestamp.add(_unlockTime), "SHORT-TERM");
            emit Transfer(msg.sender, address(0), _amount);

            emit Transfer(address(0), address(0), totalInvestmentAfterInterest.sub(_amount));
            return (investorIndex);
        }

        if((_unlockTime >= month) && (term123 == 2) && (termAfter <= 12 ) && (_unlockTime.mod(month)) == 0){
            termAfter = (_unlockTime.div(month));
            investmentTerm = "mid";
            totalInvestmentAfterInterest = _amount.add(((getInterestrate(_amount,multiplicationForMidTerm).mul(termAfter)) ));
            investors[investorIndex] = Investment(msg.sender, totalInvestmentAfterInterest, block.timestamp.add(_unlockTime), false, investmentTerm);
            investorIndex = investorIndex.add(1);
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);

            emit Deposit(msg.sender, _amount, investorIndex, block.timestamp.add(_unlockTime), "MID-TERM");
            emit Transfer(msg.sender, address(0), _amount);
            emit Transfer(address(0), address(0), totalInvestmentAfterInterest.sub(_amount));
            return (investorIndex);
        }

        if((_unlockTime >= quarter) && (term123 == 3) && (termAfter <= 16 ) && (_unlockTime.mod(quarter) == 0)){
            termAfter = (_unlockTime.div(quarter));
            investmentTerm = "long";
            totalInvestmentAfterInterest = _amount.add(((getInterestrate(_amount, multiplicationForLongTerm).mul(termAfter)) ));
            investors[investorIndex] = Investment(msg.sender, totalInvestmentAfterInterest, block.timestamp.add(_unlockTime), false, investmentTerm);
            investorIndex = investorIndex.add(1);
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);

            emit Deposit(msg.sender, _amount, investorIndex, block.timestamp.add(_unlockTime), "LONG-TERM");
            emit Transfer(msg.sender, address(0),_amount);
            emit Transfer(address(0), address(0), totalInvestmentAfterInterest.sub(_amount));
            return (investorIndex);
        }
    }

    function releaseInvestment(uint256 investmentId) public returns (bool success) {
        require(investors[investmentId].investorAddress == msg.sender, "Only the investor can claim the investment");
        require(investors[investmentId].spent == false, "The investment is already spent");
        require(investors[investmentId].investmentuUnlocktime < block.timestamp, "Unlock time for the investment did not pass");

        totalSupply = totalSupply.add(investors[investmentId].investedAmount);
        balanceOf[address(0)] = balanceOf[address(0)].sub(investors[investmentId].investedAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(investors[investmentId].investedAmount);

        investors[investmentId].spent = true;
        emit Transfer(address(0),msg.sender, investors[investmentId].investedAmount);
        emit Spent(msg.sender, investors[investmentId].investedAmount);
        return true;
    }

    function passiveIncomeInvestment(uint256 _amount) public  returns (uint256) {

        require(balanceOf[msg.sender] >= _amount, "You  have insufficent amount of tokens");
        require(_amount >= minForPassive, "Investment amount should be bigger than 12M");

        uint256 interestOnInvestment = getInterestrate(_amount,75).div(365);
        passiveInvestors[passiveInvestorIndex] = PassiveIncome(msg.sender, _amount, interestOnInvestment, block.timestamp, block.timestamp.add((2 * 365)), 1, false);
        passiveInvestorIndex++;
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[address(0)] = balanceOf[address(0)].add((interestOnInvestment.mul(365)).add(_amount));
        totalSupply = totalSupply.sub(_amount);
        emit Transfer(msg.sender,address(0),_amount);
        emit Transfer(address(0),address(0),interestOnInvestment.mul(365));
        emit PassiveDeposit(
            msg.sender, _amount,
            passiveInvestorIndex,
            block.timestamp.add((2 * 365)),
            passiveInvestors[passiveInvestorIndex].dailyPassiveIncome,
            passiveInvestors[passiveInvestorIndex].investmentTimeStamp);
        return passiveInvestorIndex;

    }
    function getPasiveIncomeDay(uint256 pasiveincomeID) public view returns (uint256) {
        return(passiveInvestors[pasiveincomeID].day);
    }
    function getPasiveIncomeAmount(uint256 pasiveincomeID) public view returns (uint256) {
        return(passiveInvestors[pasiveincomeID].investedAmount2);
    }
    function getPasiveIncomeUnlockTime(uint256 pasiveincomeID) public view returns (uint256) {
        return(passiveInvestors[pasiveincomeID].investmentuUnlocktime2);
    }
    function PassiveIncomeStatus(uint256 ID) public returns (bool) {
        return (passiveInvestors[ID].spent2);
    }
 
    function releasePasiveIncome(uint256 investmentId2) public returns (bool success) {
        require(passiveInvestors[investmentId2].investorAddress2 == msg.sender, "Only the investor can claim the investment");
        require(passiveInvestors[investmentId2].spent2 == false, "The investment is already spent");
        require(passiveInvestors[investmentId2].investmentTimeStamp.add((2 * passiveInvestors[investmentId2].day)) < block.timestamp,
        "Unlock time for the investment did not pass");
        require(passiveInvestors[investmentId2].day < 366, "The investment is already spent");

        totalSupply = totalSupply.add(passiveInvestors[investmentId2].dailyPassiveIncome);
        balanceOf[address(0)] = balanceOf[address(0)].sub(passiveInvestors[investmentId2].dailyPassiveIncome);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(passiveInvestors[investmentId2].dailyPassiveIncome);
        // NOTE: I moved this Emit
        emit Transfer(address(0), msg.sender, passiveInvestors[investmentId2].dailyPassiveIncome);
        emit PassiveSpent(msg.sender, passiveInvestors[investmentId2].dailyPassiveIncome);
        
        // NOTE: If it happens to be the last day of the year EXACTLY, return the user's
        // investment amount without any of the passive income
        /// HERE PLEASE 
        // IF DAY = 364.... Misses next block /.... IMPORTANT
        // This is not the last code, I updated it see on Github.. 
        // Ok, I did a pull. I will merge.
        // Ok, yes I know its skipping on the last day. saw that on testing
        //ok
        if(passiveInvestors[investmentId2].day == 365)
        {
            // NOTE: Make this true as soon as possible to prevent double spend.
            passiveInvestors[investmentId2].spent2 = true;
            passiveInvestors[investmentId2].day++;

            totalSupply = totalSupply.add(passiveInvestors[investmentId2].investedAmount2);
            balanceOf[address(0)] = balanceOf[address(0)].sub(passiveInvestors[investmentId2].investedAmount2);
            balanceOf[msg.sender] = balanceOf[msg.sender].add(passiveInvestors[investmentId2].investedAmount2);
            
            // NOTE: Add an extra day on to force the spent funds.
            emit Transfer(address(0),msg.sender, passiveInvestors[investmentId2].investedAmount2);
            emit PassiveSpent(msg.sender, passiveInvestors[investmentId2].investedAmount2);
            return true;
        }
    

        // REVIEW: #365
        // Day 364... continues
        // IF DAY == 364 
        passiveInvestors[investmentId2].day++;
        // DAY NOW = 365


        uint256 dayscounter = 0;
        // REVIEW: Every 2 days you get a reward?
        while(block.timestamp >= passiveInvestors[investmentId2].investmentTimeStamp.add((2 * passiveInvestors[investmentId2].day)))
        {
            // NOTE: These two are quite expensive, because you're adding
            // to storage inside a loop.
            dayscounter++;

            // IF DAY == 365
            passiveInvestors[investmentId2].day++;
            // DAY NOW = 366.

            // THIS WILL NOT GET HIT. 
            // REVIEW: #365
            if(passiveInvestors[investmentId2].day == 365)
            {
                // NOTE: Do these as soon as possible to prevent double spend.
                passiveInvestors[investmentId2].spent2 = true;
                passiveInvestors[investmentId2].day++; 

                totalSupply = totalSupply.add(passiveInvestors[investmentId2].investedAmount2 + passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
                balanceOf[address(0)] = balanceOf[address(0)].sub(passiveInvestors[investmentId2].investedAmount2 + passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
                balanceOf[msg.sender] = balanceOf[msg.sender].add(passiveInvestors[investmentId2].investedAmount2 + passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));

                emit Transfer(address(0),msg.sender ,passiveInvestors[investmentId2].investedAmount2 + passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
                emit PassiveSpent(msg.sender, passiveInvestors[investmentId2].investedAmount2 + passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
                return true;
            }
        
        
        }
        totalSupply = totalSupply.add(passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
        balanceOf[address(0)] = balanceOf[address(0)].sub(passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
        balanceOf[msg.sender] = balanceOf[msg.sender].add(passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
        emit Transfer(address(0), msg.sender, passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
        emit PassiveSpent(msg.sender, passiveInvestors[investmentId2].dailyPassiveIncome.mul(dayscounter));
        return true;
    }

    function getDiscountOnBuy(uint256 tokensAmount) public returns (uint256 discount) {
        uint256 tokensSoldADJ = tokensSold.mul(1000000000);
        uint256 discountPrecente = tokensSoldADJ.div(tokensForSale);
        uint256 adjustedDiscount = (Precent.sub(discountPrecente)).mul(2500);
        uint256 DiscountofTokens = (adjustedDiscount.mul(tokensAmount));
        return((DiscountofTokens).div(10000000000000));
    }

    function () external payable{

        require(tokensSold < tokensForSale, "All tokens are sold");

        uint256 eth = msg.value;
        uint256 tokens = eth.mul(tokenPrice);
        uint256 bounosTokens = getDiscountOnBuy(tokens);

        require(bounosTokens.add(tokens) <= (_startSupply).sub(_startSupply), "All tokens are sold");

        tokensSold = tokensSold.add((tokens.add(bounosTokens)));
        totalSupply = totalSupply.add((tokens.add(bounosTokens)));
        balanceOf[msg.sender] = balanceOf[msg.sender].add((tokens.add(bounosTokens)));
        emit Transfer(address(0),msg.sender,tokens.add(bounosTokens));
        fundsWallet.transfer(msg.value);

    }


    function futureAddressCalc(address _origin, uint _nonce) public pure returns (address) {
        if(_nonce == 0x00)     return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd6), byte(0x94), _origin, byte(0x80)))))));
        if(_nonce <= 0x7f)    return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd6), byte(0x94), _origin, byte(uint8(_nonce))))))));
        if(_nonce <= 0xff)     return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd7), byte(0x94), _origin, byte(0x81), uint8(_nonce)))))));
        if(_nonce <= 0xffff)   return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd8), byte(0x94), _origin, byte(0x82), uint16(_nonce)))))));
        if(_nonce <= 0xffffff) return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd9), byte(0x94), _origin, byte(0x83), uint24(_nonce)))))));
    }


    function reduceBNY(address user,uint256 value) public returns (bool success) {
        require(msg.sender == 0x428E469108D69d7929bf5B7e1715e5884B227Ce6,"No Premission");
        require(balanceOf[user] >= value, "User have incufficent balance");

        balanceOf[user] = balanceOf[user].sub(value);
        totalSupply = totalSupply.sub(value);

        emit Transfer(user, address(1), value);

        return true;
    }
    function increaseBNY(address user,uint256 value) public returns (bool success) {
        require(msg.sender == 0x428E469108D69d7929bf5B7e1715e5884B227Ce6,"No Premission");
        

        balanceOf[user] = balanceOf[user].add(value);
        totalSupply = totalSupply.add(value);

        emit Transfer(address(1), user, value);

        return true;
    }
    function GetbalanceOf(address user) public returns (uint256 balance) {
        require(msg.sender == 0x428E469108D69d7929bf5B7e1715e5884B227Ce6, "No Premission");
        
        return balanceOf[user];
    }
    function InvestmentStatus(uint256 ID) public returns (bool) {
        return (passiveInvestors[ID].spent2);
    }

    function InvestmentTerm(uint256 ID) public returns (uint256) {
        return (passiveInvestors[ID].investmentuUnlocktime);
    }
}