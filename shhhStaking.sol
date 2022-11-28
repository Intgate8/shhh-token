// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./shhh.sol";

contract ShhhStakingContract is Context, Owner {
    using SafeMath for uint256;
    using Strings for uint256;
    using Strings for address;

    // Token contract
    ShhhToken public token;

    address LPAddress = 0x1a7aF564273Ca6b80A950d42205186252190eF1e;
    ERC20 LPContract;

    struct StakingStruct {
        address Address;
        uint256 amount;
        uint256 toClaim;
        uint256 claimed;
        uint256 created;
        uint256 lastClaimed;
        uint256 lastClaimedCheck;
    }
    uint256 claimPercentRate = 30;
    mapping(address => StakingStruct) private stakingAddresses;
    address[] private registeredAddresses;

    event StakingCreated(string _msg, address _address, uint256 _amount);
    event Claimed(string _msg, address _address, uint256 _amount);
    event StakingCashout(string _msg, address _address, uint256 _amount);
    event ListOfStakingAddressesAmount(string _address, string _amount, string _claimed, string _toClaim, string _created, string _lastClaimedCheck, string _lastClaimed);


    constructor(ShhhToken _token) {
        require(address(_token) != address(0));
        token = _token;
        LPContract = ERC20(LPAddress);
    }

    /*
    * Setting a new payout percentage. Only for testing!
    */
    function setNewDate(uint256 _newDate) public returns(bool) {
        require(stakingAddresses[_msgSender()].lastClaimedCheck > 0, 'No staking found');
        stakingAddresses[_msgSender()].created = _newDate;
        stakingAddresses[_msgSender()].lastClaimedCheck = _newDate;
        return true;
    }

    function sendSHHH() public returns(bool) {
        token.transfer(_msgSender() , 100000000000000000000);
        return true;
    }

    /*
    * Setting a new payout percentage. Only for the owner
    */
    function setClaimPercentRate(uint256 _newRate) public isOwner returns(uint256) {
        claimPercentRate = _newRate;
        return claimPercentRate;
    }
    /*
    * Creating new staking (or adding new amounts to existting)
    */
    function stake(uint256 _amount) public payable returns(bool) {
        require(token.balanceOf(_msgSender()) >= _amount,'Insufficient number of tokens');

        require(token.transferFrom(_msgSender(),address(this), _amount));

        if(isAddressExists(_msgSender())) {
            setNewClaim(_msgSender());
        }

        stakingAddresses[_msgSender()] = StakingStruct({
            Address : _msgSender(),
            amount : stakingAddresses[_msgSender()].amount+_amount,
            toClaim : stakingAddresses[_msgSender()].toClaim,
            claimed : stakingAddresses[_msgSender()].claimed,
            created : block.timestamp,
            lastClaimed : block.timestamp,
            lastClaimedCheck : block.timestamp
        });

        if(!isAddressExists(_msgSender())) {
            registeredAddresses.push(_msgSender());
        }

        emit StakingCreated('Staking has been created', _msgSender(), _amount);
        return true;
    }

    /*
    * Checking if address already added Staking
    */
    function isAddressExists(address _address) internal view returns(bool){
        for(uint256 i=0; i<registeredAddresses.length; ++i) {
            if(registeredAddresses[i] == _address) {
                return true;
            }
        }
        return false;
    }

    /*
    * Calculating actually tokens to can be claimed. Checking since last checking date
    */
    function calculateClaim(address _address) private view returns(uint256) {
        require(stakingAddresses[_address].lastClaimedCheck > 0, 'No staking found');
        uint256 lastClaimedCheck = stakingAddresses[_address].lastClaimedCheck;
        uint256 _now = block.timestamp;
        uint256 _year = 31536000;
        uint256 calc = _now.sub(lastClaimedCheck);
        uint256 amount = stakingAddresses[_address].amount.div(100).mul(claimPercentRate);
        uint256 precision = 10000000000;
        calc = calc.mul(precision).div(_year).mul(amount).div(precision);
        return calc;
    }

    /*
    * Calculating tokens to can be claimed for sender
    */
    function calculateClaimForSender() public view returns(uint256) {
        return calculateClaim(_msgSender())+stakingAddresses[_msgSender()].toClaim;
    }

    /*
    * Calculating tokens to can be claimed for passed address. Only for owner
    */
    function calculateClaimForAddress(address _address) public view isOwner returns(uint256) {
        return calculateClaim(_address)+stakingAddresses[_msgSender()].toClaim;
    }

    /*
    * Calculate the tokens to claim, and if found we add them and save the new check date
    */
    function setNewClaim(address _address) internal returns(uint256) {
        uint256 calc = calculateClaim(_address);
        if(calc > 0) {
            stakingAddresses[_address].toClaim = stakingAddresses[_address].toClaim+calc;
            stakingAddresses[_address].lastClaimedCheck = block.timestamp;
        }
        return stakingAddresses[_address].toClaim;
    }

    /*
    * Check if staking exists. If the amount is 0, we assume that staking does not exist (but there may be tokens for claim)
    */
    function isStakeExists(address _address) internal view returns(bool) {
        return stakingAddresses[_address].amount>0;
    }

    /*
    * Receiving tokens if possible. Record the date of the last submission and increase the number of claimed tokens
    */
    function claim() public returns(bool) {
        require(calculateClaimForSender()+stakingAddresses[_msgSender()].toClaim > 0, 'Nothing to claim');

        setNewClaim(_msgSender());

        require(token.transfer(_msgSender() , stakingAddresses[_msgSender()].toClaim));

        stakingAddresses[_msgSender()].lastClaimed = block.timestamp;
        stakingAddresses[_msgSender()].claimed = stakingAddresses[_msgSender()].claimed.add(stakingAddresses[_msgSender()].toClaim);
        emit Claimed('User claimed tokens', _msgSender(), stakingAddresses[_msgSender()].toClaim);
        stakingAddresses[_msgSender()].toClaim = 0;
        return true;
    }

    /*
    * Send stakings tokens. Calculate the new amount of token to can be claimed before sending. After sending, we reduce the number of staking tokens
    */
    function unstake(uint256 _amount) public returns(bool) {
        require(isStakeExists(_msgSender()), 'Number of staked tokens: 0');
        require(stakingAddresses[_msgSender()].amount >= _amount,'Insufficient number of tokens');
        uint256 erc20balance = token.balanceOf(address(this));
        require(_amount <= erc20balance, "Balance is too low");

        setNewClaim(_msgSender());
        //token.approve(_msgSender(), _amount);
        require(token.transfer(_msgSender(), _amount));
        stakingAddresses[_msgSender()].amount = stakingAddresses[_msgSender()].amount - _amount;
        emit StakingCashout('User unstaked tokens', _msgSender(), _amount);
        return true;
    }

    /*
    * list of registerred addresses, amounts and claimed amounts
    */
    function dump() public isOwner {
        string memory accounts;
        string memory amounts;
        string memory claimed;
        string memory toclaim;
        string memory created;
        string memory lastChecked;
        string memory lastClaimed;
        for (uint256 i = 0; i < registeredAddresses.length; i++) {
            accounts = string(abi.encodePacked(accounts, registeredAddresses[i].toAsciiString(),' '));
            amounts = string(abi.encodePacked(amounts, stakingAddresses[registeredAddresses[i]].amount.uint2str(),' '));
            claimed = string(abi.encodePacked(claimed, stakingAddresses[registeredAddresses[i]].claimed.uint2str(),' '));
            toclaim = string(abi.encodePacked(toclaim, stakingAddresses[registeredAddresses[i]].toClaim.uint2str(),' '));
            created = string(abi.encodePacked(created, stakingAddresses[registeredAddresses[i]].created.uint2str(),' '));
            lastChecked = string(abi.encodePacked(lastChecked, stakingAddresses[registeredAddresses[i]].lastClaimedCheck.uint2str(),' '));
            lastClaimed = string(abi.encodePacked(lastClaimed, stakingAddresses[registeredAddresses[i]].lastClaimed.uint2str(),' '));
        }
        emit ListOfStakingAddressesAmount(accounts, amounts, claimed, toclaim, created, lastChecked, lastClaimed);
    }
    /*
    * Return information about staking current address
    */
    function showMyStakingInfo() public view returns(uint256 amount, uint256 claimed, uint256 toClaim, uint256 created) {
        if(isAddressExists(_msgSender())) {
            return (
                stakingAddresses[_msgSender()].amount,
                stakingAddresses[_msgSender()].claimed,
                calculateClaimForSender(),
                stakingAddresses[_msgSender()].created
            );
        }else {
            return(0,0,0,0);
        }
    }
}