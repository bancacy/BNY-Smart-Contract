pragma solidity 0.5.10;
import "./SafeMath.sol";
import "./FutureAddressCalc.sol";
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
    string  internal investmentTerm;
    uint256 public decimals = 18 ;
    uint256 public totalSupply;
    uint256 public totalInvestmentAfterInterest;
    uint256 public investorIndex = 1;
    uint256 public passiveInvestorIndex = 1;
    uint256 public interestRate = 16;
    uint256 public multiplicationForMidTerm  = 5;
    uint256 public multiplicationForLongTerm = 20;
    uint256 public minForPassive = 1200000 * (10 ** uint256(decimals));
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
        tokensForSale = 1 * (10 ** uint256(decimals));
        ////////////////////////////////////
        totalSupply = _startSupply;
        fundsWallet = _fundsWallet;
        balanceOf[fundsWallet] = _startSupply;
        balanceOf[address(0)] = 0;
        emit Transfer(
            address(0),
            fundsWallet,
            _startSupply
        );
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
        emit Transfer(
            address(0),
            msg.sender,
            tokens.add(bounosTokens)
        );
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "You have insufficent amount of tokens");
        require(_to != address(0), "address(0) used as _to in transfer()");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(
            msg.sender,
            _to,
            _value
        );
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "address(0) used as _spender in approve()");
        allowance[msg.sender][_spender] = _value;
        emit Approval(
            msg.sender,
            _spender,
            _value
        );
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Value must be less or equal to the balance.");
        require(_value <= allowance[_from][msg.sender], "Value must be less or equal to the balance.");
        require(_to != address(0), "address(0) used as _to in transferFrom()");
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(
            _from,
            _to,
            _value
        );
        return true;
    }
    function investment(uint256 _unlockTime, uint256 _amount, uint term123) public returns (uint256) {
        require(balanceOf[msg.sender] >= _amount, "You dont have sufficent amount of tokens");
        require(_amount > 0, "Investment amount should be bigger than 0");
        require(_unlockTime >= week && (_unlockTime.mod(week)) == 0, "Wrong investment time");

        // Term time is currently in weeks
        uint256 termAfter = (_unlockTime.div(week));
        uint256 currentInvestor = investorIndex;

        /*
        The termAfter in weeks is more than or equal to 1 (week).
        The user must have typed (in weeks) a figure (as termAfter) less than or equal to 48 (when comparing termAfter in weeks). Taken from the UI in (weeks), calculated into (seconds).
        The user has selected "weeks" / "short term" (1) in the UI.
        Previous check: The unlock time is a factor of weeks (in require).
        */
        if((termAfter >= 1) && (termAfter <= 48) && (term123 == 1))
        {
            investorIndex++;
            investmentTerm = "short";
            totalInvestmentAfterInterest = _amount.add(getInterestRate(_amount, 1).mul(termAfter));
            investors[currentInvestor] = Investment(
                msg.sender,
                totalInvestmentAfterInterest,
                block.timestamp.add(_unlockTime),
                false,
                investmentTerm
            );
            emit Deposit(msg.sender,
                _amount,
                currentInvestor,
                block.timestamp.add(_unlockTime),
                "SHORT-TERM"
            );
            emit Transfer(
                msg.sender,
                address(0),
                _amount
            );
            emit Transfer(
                address(0),
                address(0),
                totalInvestmentAfterInterest.sub(_amount)
            );
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);
            return (currentInvestor);
        }

        // Recalculate the original termAfter (set in weeks) from unlocktime (in seconds) (instead as whole months, in seconds) for multiplier.
        termAfter = (_unlockTime.div(month));

        /*
        The unlock time in seconds is more than or equal to 1 month in seconds.
        The user has selected "months" / "mid term" (2) in the UI.
        The user must have typed (in months) a figure (as termAfter) less than or equal to 1 year / 12 (when comparing termAfter in months). Taken from the UI in (months), calculated into seconds.
        The unlock time (in seconds) is a factor of whole months (in seconds).
        */
        if((_unlockTime >= month) && (term123 == 2) && (termAfter <= 12 ) && (_unlockTime.mod(month)) == 0) {
            investorIndex++;

            investmentTerm = "mid";
            totalInvestmentAfterInterest = _amount.add(getInterestRate(_amount, multiplicationForMidTerm).mul(termAfter));
            investors[currentInvestor] = Investment(
                msg.sender,
                totalInvestmentAfterInterest,
                block.timestamp.add(_unlockTime),
                false,
                investmentTerm
            );
            emit Deposit(
                msg.sender,
                _amount,
                currentInvestor,
                block.timestamp.add(_unlockTime),
                "MID-TERM"
            );
            emit Transfer(
                msg.sender,
                address(0),
                _amount
            );
            emit Transfer(
                address(0),
                address(0),
                totalInvestmentAfterInterest.sub(_amount)
            );
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);
            return (currentInvestor);
        }


        // Recalculate the original termAfter (reset as months) from unlocktime (in seconds) (instead as whole quarters, in seconds) for the multiplier.
        termAfter = (_unlockTime.div(quarter));
        /*
        The unlock time in seconds is more than or equal to 1 quarter in seconds.
        The user has selected "quarters" / "long term" (3) in the UI.
        The user must have typed a figure less than or equal to 3 years / 12 (when comparing termAfter in quarters). Taken from the UI in (quarters), calculated into seconds.
        The unlock time (in seconds) is a factor of whole quarters (in seconds).
        */
        if((_unlockTime >= quarter) && (term123 == 3) && (termAfter <= 12 ) && (_unlockTime.mod(quarter) == 0)) {
            investorIndex++;

            investmentTerm = "long";
            totalInvestmentAfterInterest = _amount.add(getInterestRate(_amount, multiplicationForLongTerm).mul(termAfter));
            investors[currentInvestor] = Investment(
                msg.sender,
                totalInvestmentAfterInterest,
                block.timestamp.add(_unlockTime),
                false,
                investmentTerm
            );
            emit Deposit(
                msg.sender,
                _amount,
                currentInvestor,
                block.timestamp.add(_unlockTime),
                "LONG-TERM"
            );
            emit Transfer(
                msg.sender,
                address(0),
                _amount
            );
            emit Transfer(
                address(0),
                address(0),
                totalInvestmentAfterInterest.sub(_amount)
            );
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(0)] = balanceOf[address(0)].add(totalInvestmentAfterInterest);
            totalSupply = totalSupply.sub(_amount);
            return (currentInvestor);
        }
    }
    function releaseInvestment(uint256 _investmentId) external returns (bool success) {
        require(investors[_investmentId].investorAddress == msg.sender, "Only the investor can claim the investment");
        require(investors[_investmentId].spent == false, "The investment is already spent");
        require(investors[_investmentId].investmentUnlocktime < block.timestamp, "Unlock time for the investment did not pass");
        investors[_investmentId].spent = true;
        totalSupply = totalSupply.add(investors[_investmentId].investedAmount);
        balanceOf[address(0)] = balanceOf[address(0)].sub(investors[_investmentId].investedAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(investors[_investmentId].investedAmount);
        emit Transfer(
            address(0),
            msg.sender,
            investors[_investmentId].investedAmount
        );
        emit Spent(
            msg.sender,
            investors[_investmentId].investedAmount
        );
        return true;
    }
    function passiveIncomeInvestment(uint256 _amount) external returns (uint256) {
        require(balanceOf[msg.sender] >= _amount, "You  have insufficent amount of tokens");
        require(_amount >= minForPassive, "Investment amount should be bigger than 12M");
        uint256 interestOnInvestment = getInterestRate(_amount, 75).div(365);
        uint256 currentInvestor = passiveInvestorIndex;
        passiveInvestorIndex++;
        passiveInvestors[currentInvestor] = PassiveIncome(
            msg.sender,
            _amount,
            interestOnInvestment,
            block.timestamp,
            block.timestamp.add(dayseconds * 365),
            1,
            false
        );
        emit Transfer(
            msg.sender,
            address(0),
            _amount
        );
        emit Transfer(
            address(0),
            address(0),
            interestOnInvestment.mul(365)
        );
        emit PassiveDeposit(
            msg.sender,
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
    function releasePassiveIncome(uint256 _passiveIncomeID) external returns (bool success) {
        require(passiveInvestors[_passiveIncomeID].investorAddress2 == msg.sender, "Only the investor can claim the investment");
        require(passiveInvestors[_passiveIncomeID].spent2 == false, "The investment is already spent");
        require(passiveInvestors[_passiveIncomeID].investmentTimeStamp.add((
        dayseconds * passiveInvestors[_passiveIncomeID].day)) < block.timestamp,
        "Unlock time for the investment did not pass");
        require(passiveInvestors[_passiveIncomeID].day < 366, "The investment is already spent");
        uint256 totalReward;
        uint256 numberOfDaysHeld = (block.timestamp - passiveInvestors[_passiveIncomeID].investmentTimeStamp) / dayseconds;
        if(numberOfDaysHeld > 365){
            passiveInvestors[_passiveIncomeID].spent2 = true;
            numberOfDaysHeld = 365;
            totalReward = passiveInvestors[_passiveIncomeID].investedAmount2;
        }
        uint numberOfDaysOwed = numberOfDaysHeld - (passiveInvestors[_passiveIncomeID].day - 1);
        uint totalDailyPassiveIncome = passiveInvestors[_passiveIncomeID].dailyPassiveIncome * numberOfDaysOwed;
        passiveInvestors[_passiveIncomeID].day = numberOfDaysHeld.add(1);
        totalReward = totalReward.add(totalDailyPassiveIncome);
        if(totalReward > 0){
            totalSupply = totalSupply.add(totalReward);
            balanceOf[address(0)] = balanceOf[address(0)].sub(totalReward);
            balanceOf[msg.sender] = balanceOf[msg.sender].add(totalReward);
            emit Transfer(
                address(0),
                msg.sender,
                totalReward
            );
            emit PassiveSpent(
                msg.sender,
                totalReward
            );
            return true;
        }
        else{
            revert(
                "There is no total reward earned."
            );
        }
    }
    function BNY_AssetSolidification(address _user, uint256 _value) external returns (bool success) {
        require(msg.sender == BNY_DATA, "No Permission");
        require(balanceOf[_user] >= _value, "User have incufficent balance");
        balanceOf[_user] = balanceOf[_user].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Transfer(
            _user,
            address(1),
            _value
        );
        return true;
    }
    function BNY_AssetDesolidification(address _user,uint256 _value) external returns (bool success) {
        require(msg.sender == BNY_DATA, "No Permission");
        balanceOf[_user] = balanceOf[_user].add(_value);
        totalSupply = totalSupply.add(_value);
        emit Transfer(
            address(1),
            _user,
            _value
        );
        return true;
    }
    function getBalanceOf(address _user) external view returns (uint256 balance) {
        require(msg.sender == BNY_DATA, "No Permission");
        return balanceOf[_user];
    }
    function getPassiveDetails (uint _passiveIncomeID) external view returns (
        address investorAddress2,
        uint256 investedAmount2,
        uint256 dailyPassiveIncome,
        uint256 investmentTimeStamp,
        uint256 investmentUnlocktime2,
        uint256 day,
        bool spent2
    ){
        return(
            passiveInvestors[_passiveIncomeID].investorAddress2,
            passiveInvestors[_passiveIncomeID].investedAmount2,
            passiveInvestors[_passiveIncomeID].dailyPassiveIncome,
            passiveInvestors[_passiveIncomeID].investmentTimeStamp,
            passiveInvestors[_passiveIncomeID].investmentUnlocktime2,
            passiveInvestors[_passiveIncomeID].day,
            passiveInvestors[_passiveIncomeID].spent2
        );
    }
    function getPassiveIncomeDay(uint256 _passiveIncomeID) external view returns (uint256) {
        return(passiveInvestors[_passiveIncomeID].day);
    }
    function getPassiveIncomeStatus(uint256 _passiveIncomeID) external view returns (bool) {
        return (passiveInvestors[_passiveIncomeID].spent2);
    }
    function getPassiveInvestmentTerm(uint256 _passiveIncomeID) external view returns (uint256){
        return (passiveInvestors[_passiveIncomeID].investmentUnlocktime2);
    }
    function getPassiveNumberOfDays (uint _passiveIncomeID) external view returns (uint256){
        return (block.timestamp - passiveInvestors[_passiveIncomeID].investmentTimeStamp) / dayseconds;
    }
    function getPassiveInvestmentTimeStamp(uint256 _passiveIncomeID) external view returns (uint256){
        return (passiveInvestors[_passiveIncomeID].investmentTimeStamp);
    }
    function getInvestmentStatus(uint256 _ID) external view returns (bool){
        return (investors[_ID].spent);
    }
    function getInvestmentTerm(uint256 _ID) external view returns (uint256){
        return (investors[_ID].investmentUnlocktime);
    }
    function getDiscountOnBuy(uint256 _tokensAmount) public view returns (uint256 discount) {
        uint256 tokensSoldADJ = tokensSold.mul(1000000000);
        uint256 discountPercentage = tokensSoldADJ.div(tokensForSale);
        uint256 adjustedDiscount = (Percent.sub(discountPercentage)).mul(2500);
        uint256 DiscountofTokens = (adjustedDiscount.mul(_tokensAmount));
        return((DiscountofTokens).div(10000000000000));
    }
    function getBlockTimestamp () external view returns (uint blockTimestamp){
        return block.timestamp;
    }
    function getInterestRate(uint256 _investment, uint _term) public view returns (uint256 rate) {
        require(_investment < totalSupply, "The investment is too large");
        uint256 totalinvestments = balanceOf[address(0)].mul(Percent);
        uint256 investmentsPercentage = totalinvestments.div(totalSupply);
        uint256 adjustedinterestrate = (Percent.sub(investmentsPercentage)).mul(interestRate);
        uint256 interestoninvestment = (adjustedinterestrate.mul(_investment)).div(10000000000000);
        return (interestoninvestment.mul(_term));
    }
    function getSimulatedDailyIncome (uint _passiveIncomeID) external view returns (
        uint _numberOfDaysHeld,
        uint _numberOfDaysOwed,
        uint _totalDailyPassiveIncome,
        uint _dailyPassiveIncome,
        uint _totalReward,
        uint _day,
        bool _spent
    ){
        _spent = false;
        _numberOfDaysHeld = (block.timestamp - passiveInvestors[_passiveIncomeID].investmentTimeStamp) / dayseconds;
        if(_numberOfDaysHeld > 365){
            _numberOfDaysHeld = 365;
            _totalReward = passiveInvestors[_passiveIncomeID].investedAmount2;
            _spent = true;
        }
        _numberOfDaysOwed = _numberOfDaysHeld - (passiveInvestors[_passiveIncomeID].day - 1);
        _totalDailyPassiveIncome = passiveInvestors[_passiveIncomeID].dailyPassiveIncome * _numberOfDaysOwed;
        _day = _numberOfDaysHeld.add(1);
        _totalReward = _totalReward.add(_totalDailyPassiveIncome);
        _dailyPassiveIncome = passiveInvestors[_passiveIncomeID].dailyPassiveIncome;
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