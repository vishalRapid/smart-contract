//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Stake {
    uint256 public planDuration = 2592000; // 30 days
    uint256 public timePeriod = 15552000; // timestamp for next 6 months
    IERC20 token;
    uint256 minTokenRequired = 10 * (10**18);
    uint8 public interestRate = 32;
    IERC20 rewardToken;

    struct StakeInfo {
        uint256 startTS;
        uint256 endTS;
        uint256 amount;
        uint256 claimed;
        bool staked;
    }

    mapping(address => StakeInfo) public stakeInfos;
    uint256 public totalStaked;
    uint256 public planExpired;

    constructor(address _stakeToken, address _rewardToken) {
        require(
            address(_stakeToken) != address(0),
            "Token Address cannot be address 0"
        );
        token = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
        totalStaked = 0;
        planExpired = block.timestamp + timePeriod;
    }

    //Staking token so that we can opt in for rewards
    function stakeToken(uint256 _stakeAmount) external {
        require(
            _stakeAmount > minTokenRequired,
            "Stake token has a min requirement."
        );

        require(
            stakeInfos[msg.sender].staked == false,
            "You already staked the token"
        );

        require(block.timestamp < planExpired, "Staking has expired");

        require(
            token.balanceOf(msg.sender) > _stakeAmount,
            "Not have enough balance"
        );

        // transfer token to this contract
        token.transferFrom(msg.sender, address(this), _stakeAmount);

        // update that this address has already staked
        stakeInfos[msg.sender].staked = true;

        totalStaked = totalStaked + _stakeAmount;

        // keeping track of staked amount and when it was staked
        stakeInfos[msg.sender] = StakeInfo({
            startTS: block.timestamp,
            endTS: block.timestamp + planDuration,
            amount: _stakeAmount,
            claimed: 0,
            staked: true
        });
    }

    // function to be called by the user to claim the rewards
    function claimReward() external returns (bool) {
        require(
            stakeInfos[msg.sender].staked == true,
            "You have no amount staked."
        );

        // current user infor
        StakeInfo memory currentUserStakedInfo = stakeInfos[msg.sender];

        require(
            currentUserStakedInfo.endTS < block.timestamp,
            "Still time required for maturity."
        );

        // only distrubuting rewards if maturity date has reached
        if (currentUserStakedInfo.endTS > block.timestamp) {
            require(currentUserStakedInfo.claimed == 0, "Already claimed");
            // calculate rewards
            uint256 rewards = (currentUserStakedInfo.amount * interestRate) /
                100;

            // we need to transfer the rewards token to user in ERC20 token 2
            rewardToken.transfer(msg.sender, rewards);

            // update staking info
            currentUserStakedInfo.claimed = rewards;
        }

        // and we need to transfer the initial token for that user as well in same token t1
        token.transfer(msg.sender, currentUserStakedInfo.amount);

        // update total staked tokens
        totalStaked = totalStaked - currentUserStakedInfo.amount;
        return true;
    }
}
