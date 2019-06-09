pragma solidity ^0.5.0;

library AddressCalc {


    function futureAddressCalc(address payable  _origin, uint _nonce) internal pure  returns (address) {

        if(_nonce == 0x00) return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd6),
         byte(0x94), _origin, byte(0x80)))))));

        if(_nonce <= 0x7f) return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd6),
         byte(0x94), _origin, byte(uint8(_nonce))))))));

        if(_nonce <= 0xff) return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd7),
         byte(0x94), _origin, byte(0x81), uint8(_nonce)))))));

        if(_nonce <= 0xffff) return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd8),
         byte(0x94), _origin, byte(0x82), uint16(_nonce)))))));

        if(_nonce <= 0xffffff) return address(uint160(uint256((keccak256(abi.encodePacked(byte(0xd9),
         byte(0x94), _origin, byte(0x83), uint24(_nonce)))))));
    }

}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract BNY   {

    using SafeMath for uint256;
    using AddressCalc for address payable;

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
        uint256 _dailyIncome,
        uint256 _investmentTime
    );

    event Spent(
        address indexed _acclaimer,
        uint256 indexed _amout
    );

    event PassiveSpent(
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

    string  public name = "BANCACY";
    string  public symbol = "BNY";
    string  public standard = "BNY Token";
    uint256 public decimals = 18 ;
    string  public investmentTerm;
    uint256 public totalSupply;
    uint256 public totalInvestmentAfterInterest;
    uint256 public investorIndex = 1;
    uint256 public passiveInvestorIndex = 1;
    uint256 public interestRate = 16;
    uint256 public multiplicationForMidTerm  = 5;
    uint256 public multiplicationForLongTerm = 20;
    uint256 public minForPassive = 12000000 * (10 ** uint256(decimals));
    uint256 public tokensForSale = 227700000 * (10 ** uint256(decimals));
    uint256 public tokensSold = 1 * (10 ** uint256(decimals));

    uint256 public tokensPerWei = 200000;
    uint256 public Percent = 1000000000;

    uint256 internal dayseconds = 86400;
    uint256 internal week = 604800;
    uint256 internal month = 2419200;
    uint256 internal quarter = 7257600;
    uint256 internal year = 31536000;
    uint256 internal _startSupply = 762300000 * (10 ** uint256(decimals));

    address payable public fundsWallet;
    address public XBNY;
    address public BNY_DATA;

    mapping(uint256 => Investment) private investors;
    mapping(uint256 => PassiveIncome) private passiveInvestors;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    struct Investment {
        address investorAddress;
        uint256 investedAmount;
        uint256 investmentUnlocktime;
        bool spent;
        string term;
    }

    struct PassiveIncome {
        address investorAddress2;
        uint256 investedAmount2;
        uint256 dailyPassiveIncome;
        uint256 investmentTimeStamp;
        uint256 investmentUnlocktime2;
        uint256 day;
        bool spent2;
    }

    constructor (address payable _fundsWallet)  public {
        // TESTNET Overrides
        dayseconds = 2;// 2 seconds
        week = 60; // 100.8 minutes
        month = 120; // 403.2 minutes /  6.72 hours
        quarter = 180; // 0.84 days / 20.16 hours
        year = 0;// 3.65 days
        minForPassive = 12000 * (10 ** uint256(decimals));
        tokensPerWei = 100000000;
        ////////////////////////////////////

        totalSupply = _startSupply;
        fundsWallet = _fundsWallet;
        balanceOf[fundsWallet] = _startSupply;
        balanceOf[address(0)] = 0;
        emit Transfer(address(0), fundsWallet, _startSupply);
        XBNY = msg.sender.futureAddressCalc(1);
        BNY_DATA = msg.sender.futureAddressCalc(2);

    }

    function () external payable{

        require(tokensSold < tokensForSale, "All tokens are sold");
        require(msg.value > 0, "Value must be > 0");
        uint256 eth = msg.value;
        uint256 tokens = eth.mul(tokensPerWei);
        uint256 bounosTokens = getDiscountOnBuy(tokens);

        require(bounosTokens.add(tokens) <= (tokensForSale).sub(tokensSold), "All tokens are sold");
        fundsWallet.transfer(msg.value);
        tokensSold = tokensSold.add((tokens.add(bounosTokens)));
        totalSupply = totalSupply.add((tokens.add(bounosTokens)));
        balanceOf[msg.sender] = balanceOf[msg.sender].add((tokens.add(bounosTokens)));
        emit Transfer(address(0),msg.sender,tokens.add(bounosTokens));
        

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
        require(_unlockTime >= week && (_unlockTime.mod(week)) == 0, "Wrong investment time");

        uint256 termAfter = (_unlockTime.div(week));

        uint currentInvestor = investorIndex;

        if((termAfter >= 1) && (termAfter <= 48) && (term123 == 1))
        {
            investorIndex++;
            investmentTerm = "short";
            totalInvestmentAfterInterest = _amount.add(((getInterestrate(_amount,1).mul(termAfter))));
            investors[currentInvestor] = Investment(
                msg.sender,
                totalInvestmentAfterInterest,
                block.timestamp.add(_unlockTime),
                false,
                investmentTerm);

            emit Deposit(msg.sender,
                _amount,
                currentInvestor,
                block.timestamp.add(_unlockTime),
                "SHORT-TERM");
            emit Transfer(msg.sender, address(0), _amount);
            emit Transfer(address(0), address(0), totalInvestmentAfterInterest.sub(_amount));


            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);

            return (currentInvestor);
        }

        if((_unlockTime >= month) && (term123 == 2) && (termAfter <= 12 ) && (_unlockTime.mod(month)) == 0) {
            investorIndex++;
            termAfter = (_unlockTime.div(month));
            investmentTerm = "mid";
            totalInvestmentAfterInterest = _amount.add(((getInterestrate(_amount,multiplicationForMidTerm).mul(termAfter))));
            investors[currentInvestor] = Investment(msg.sender, totalInvestmentAfterInterest, block.timestamp.add(_unlockTime), false, investmentTerm);

            emit Deposit(msg.sender, _amount, currentInvestor, block.timestamp.add(_unlockTime), "MID-TERM");
            emit Transfer(msg.sender, address(0), _amount);
            emit Transfer(address(0), address(0), totalInvestmentAfterInterest.sub(_amount));


            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);

            return (currentInvestor);
        }

        if((_unlockTime >= quarter) && (term123 == 3) && (termAfter <= 16 ) && (_unlockTime.mod(quarter) == 0)) {
            investorIndex++;
            termAfter = (_unlockTime.div(quarter));
            investmentTerm = "long";
            totalInvestmentAfterInterest = _amount.add(getInterestrate(_amount, multiplicationForLongTerm).mul(termAfter));
            investors[currentInvestor] = Investment(msg.sender, totalInvestmentAfterInterest, block.timestamp.add(_unlockTime), false, investmentTerm);

            emit Deposit(msg.sender, _amount, currentInvestor, block.timestamp.add(_unlockTime), "LONG-TERM");
            emit Transfer(msg.sender, address(0), _amount);
            emit Transfer(address(0), address(0), totalInvestmentAfterInterest.sub(_amount));


            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);

            return (currentInvestor);
        }
    }

    function releaseInvestment(uint256 investmentId) public returns (bool success) {
        require(investors[investmentId].investorAddress == msg.sender, "Only the investor can claim the investment");
        require(investors[investmentId].spent == false, "The investment is already spent");
        require(investors[investmentId].investmentUnlocktime < block.timestamp, "Unlock time for the investment did not pass");
        investors[investmentId].spent = true;
        totalSupply = totalSupply.add(investors[investmentId].investedAmount);
        balanceOf[address(0)] = balanceOf[address(0)].sub(investors[investmentId].investedAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(investors[investmentId].investedAmount);

        emit Transfer(address(0),msg.sender, investors[investmentId].investedAmount);
        emit Spent(msg.sender, investors[investmentId].investedAmount);
        return true;
    }

    function passiveIncomeInvestment(uint256 _amount) public returns (uint256) {

        require(balanceOf[msg.sender] >= _amount,"You  have insufficent amount of tokens");
        require(_amount >= minForPassive,"Investment amount should be bigger than 12M");
        
        uint256 interestOnInvestment = ((getInterestrate(_amount,75)).div(365));

        uint currentInvestor = passiveInvestorIndex;
        passiveInvestorIndex++;
        passiveInvestors[currentInvestor] = PassiveIncome(
            msg.sender,
            _amount,
            interestOnInvestment,
            block.timestamp,
            block.timestamp.add((dayseconds * 365)),
            1,
            false);

        emit Transfer(msg.sender, address(0), _amount);
        emit Transfer(address(0), address(0), interestOnInvestment.mul(365));

        emit PassiveDeposit(msg.sender,
        _amount,
            currentInvestor,
            block.timestamp.add((dayseconds * 365)),
            passiveInvestors[currentInvestor].dailyPassiveIncome,
            passiveInvestors[currentInvestor].investmentTimeStamp
        );

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[address(0)] = balanceOf[address(0)].add((interestOnInvestment.mul(365)).add(_amount));
        totalSupply = totalSupply.sub(_amount);

        return (currentInvestor);
    }

    function releasePassiveIncome(uint256 passiveIncomeID) public returns (bool success) {
        require(passiveInvestors[passiveIncomeID].investorAddress2 == msg.sender, "Only the investor can claim the investment");
        require(passiveInvestors[passiveIncomeID].spent2 == false, "The investment is already spent");
        require(passiveInvestors[passiveIncomeID].investmentTimeStamp.add((
        dayseconds * passiveInvestors[passiveIncomeID].day)) < block.timestamp,
        "Unlock time for the investment did not pass");
        require(passiveInvestors[passiveIncomeID].day < 366, "The investment is already spent");
        
        uint totalReward;
        uint numberOfDaysHeld = (block.timestamp - passiveInvestors[passiveIncomeID].investmentTimeStamp) / dayseconds;

        if(numberOfDaysHeld > 365){
            passiveInvestors[passiveIncomeID].spent2 = true;
            numberOfDaysHeld = 365;
            totalReward = passiveInvestors[passiveIncomeID].investedAmount2;
        }

        uint numberOfDaysOwed = numberOfDaysHeld - (passiveInvestors[passiveIncomeID].day - 1);

        uint totalDailyPassiveIncome = passiveInvestors[passiveIncomeID].dailyPassiveIncome * numberOfDaysOwed;
        passiveInvestors[passiveIncomeID].day = numberOfDaysHeld + 1;

        totalReward = totalReward + totalDailyPassiveIncome;
        if(totalReward > 0){
            totalSupply = totalSupply.add(totalReward);
            balanceOf[address(0)] = balanceOf[address(0)].sub(totalReward);
            balanceOf[msg.sender] = balanceOf[msg.sender].add(totalReward);

            emit Transfer(address(0), msg.sender,totalReward);
            emit PassiveSpent(msg.sender, totalReward);
            return true;
        }
        else{
            revert(
                "There is no total reward earned."
            );
        }
    }

    function BNY_AssetSolidification(address user,uint256 value) public returns (bool success) {
        require(msg.sender == BNY_DATA, "No Permission");
        require(balanceOf[user] >= value, "User have incufficent balance");

        balanceOf[user] = balanceOf[user].sub(value);
        totalSupply = totalSupply.sub(value);

        emit Transfer(user, address(1), value);

        return true;
    }
    function BNY_AssetDesolidification(address user,uint256 value) public returns (bool success) {
        require(msg.sender == BNY_DATA, "No Permission");

        balanceOf[user] = balanceOf[user].add(value);
        totalSupply = totalSupply.add(value);

        emit Transfer(address(1), user, value);

        return true;
    }
    function getBalanceOf(address user) public view returns (uint256 balance) {
        require(msg.sender == BNY_DATA, "No Permission");
        return balanceOf[user];
    }
    function getPassiveDetails (uint passiveIncomeID) public view returns (
        address investorAddress2,
        uint256 investedAmount2,
        uint256 dailyPassiveIncome,
        uint256 investmentTimeStamp,
        uint256 investmentUnlocktime2,
        uint256 day,
        bool spent2
    ){
        return(
            passiveInvestors[passiveIncomeID].investorAddress2,
            passiveInvestors[passiveIncomeID].investedAmount2,
            passiveInvestors[passiveIncomeID].dailyPassiveIncome,
            passiveInvestors[passiveIncomeID].investmentTimeStamp,
            passiveInvestors[passiveIncomeID].investmentUnlocktime2,
            passiveInvestors[passiveIncomeID].day,
            passiveInvestors[passiveIncomeID].spent2
        );
    }
    function getPassiveIncomeDay(uint256 passiveincomeID) public view returns (uint256) {
        return(passiveInvestors[passiveincomeID].day);
    }
    function getPassiveIncomeStatus(uint256 passiveIncomeID) public view returns (bool) {
        return (passiveInvestors[passiveIncomeID].spent2);
    }
    function getPassiveInvestmentTerm(uint256 passiveIncomeID) public view returns (uint256){
        return (passiveInvestors[passiveIncomeID].investmentUnlocktime2);
    }
    function getPassiveNumberOfDays (uint passiveIncomeID) public view returns (uint256){
        return (block.timestamp - passiveInvestors[passiveIncomeID].investmentTimeStamp) / dayseconds;
    }
    function getPassiveInvestmentTimeStamp(uint256 passiveIncomeID) public view returns (uint256){
        return (passiveInvestors[passiveIncomeID].investmentTimeStamp);
    }
    function getInvestmentStatus(uint256 ID) public view returns (bool){
        return (investors[ID].spent);
    }
    function getInvestmentTerm(uint256 ID) public view returns (uint256){
        return (investors[ID].investmentUnlocktime);
    }
    function getDiscountOnBuy(uint256 tokensAmount) public view returns (uint256 discount) {
        uint256 tokensSoldADJ = tokensSold.mul(1000000000);
        uint256 discountPercentage = tokensSoldADJ.div(tokensForSale);
        uint256 adjustedDiscount = (Percent.sub(discountPercentage)).mul(2500);
        uint256 DiscountofTokens = (adjustedDiscount.mul(tokensAmount));
        return((DiscountofTokens).div(10000000000000));
    }
    function getBlockTimestamp () public view returns (uint blockTimestamp){
        return block.timestamp;
    }
    function getInterestrate(uint256 _investment, uint term) public view returns (uint256 rate) {
        require(_investment < totalSupply,"The investment is too large");

        uint256 totalinvestments = balanceOf[address(0)].mul(Percent);
        uint256 investmentsPercentage = totalinvestments.div(totalSupply);
        uint256 adjustedinterestrate = (Percent.sub(investmentsPercentage)).mul(interestRate);

        uint256 interestoninvestment = (adjustedinterestrate.mul(_investment)).div(10000000000000);

        return (interestoninvestment.mul(term));
    }
    function getSimulatedDailyIncome (uint passiveIncomeID) public view returns (
        uint _numberOfDaysHeld,
        uint _numberOfDaysOwed,
        uint _totalDailyPassiveIncome,
        uint _dailyPassiveIncome,
        uint _totalReward,
        uint _day,
        bool _spent
    ){
        _spent = false;
        _numberOfDaysHeld = (block.timestamp - passiveInvestors[passiveIncomeID].investmentTimeStamp) / dayseconds;
        if(_numberOfDaysHeld > 365){
            _numberOfDaysHeld = 365;
            _totalReward = passiveInvestors[passiveIncomeID].investedAmount2;
            _spent = true;
        }

        _numberOfDaysOwed = _numberOfDaysHeld - (passiveInvestors[passiveIncomeID].day - 1);

        _totalDailyPassiveIncome = passiveInvestors[passiveIncomeID].dailyPassiveIncome * _numberOfDaysOwed;

        _day = _numberOfDaysHeld + 1;

        _totalReward = _totalReward + _totalDailyPassiveIncome;
        _dailyPassiveIncome = passiveInvestors[passiveIncomeID].dailyPassiveIncome;
        return (
            _numberOfDaysHeld,
            _numberOfDaysOwed,
            _totalDailyPassiveIncome,
            _dailyPassiveIncome,
            _totalReward,
            _day,
            _spent
        );
    }
}
