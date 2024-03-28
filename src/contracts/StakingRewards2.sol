// SPDX-License-Identifier: GPL-3.0-or-later

// pragma solidity ^0.8.23;
pragma solidity >=0.8.20 < 0.9.0;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";
import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts@5.0.2/utils/ReentrancyGuard.sol";

import { IStakingRewards2Errors } from "./IStakingRewards2Errors.sol";

import { IUniswapV2ERC20 } from "./Uniswap/v2-core/interfaces/IUniswapV2ERC20.sol";

// DEBUG
// import { console } from "forge-std/src/console.sol";

// https://docs.synthetix.io/contracts/source/contracts/stakingrewards
contract StakingRewards2 is ReentrancyGuard, Ownable(msg.sender), Pausable, IStakingRewards2Errors {
    uint256 constant ONE_TOKEN = 1e18;

    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 1 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address user => uint256 amount) public userRewardPerTokenPaid;
    mapping(address user => uint256 amount) public rewards;

    uint256 private _totalSupply;
    mapping(address user => uint256 balance) private _balances;

    /* ========== Variable Reward Rate ========== */
    bool public isVariableRewardRate = false;
    uint256 public variableRewardRate = 0;
    uint256 public constantRewardRatePerTokenStored;
    uint256 public variableRewardMaxTotalSupply;
    // Naïve implementation for rewards computation: lastUpdateTime user map, updated every time a user interacts
    // with the contract
    mapping(address user => uint256 timeStamp) public userLastUpdateTime;

    // Pausable
    uint256 public lastPauseTime;
    uint256 public lastUnpauseTime;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rewardsToken, address _stakingToken) {
        if (_rewardsToken == address(0)) revert RewardTokenZeroAddress();
        if (_stakingToken == address(0)) revert StakingTokenZeroAddress();
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (isVariableRewardRate) {
            return constantRewardRatePerTokenStored;
        }
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored
            + ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * ONE_TOKEN / _totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        if (isVariableRewardRate) {
            // forgefmt: disable-next-line
            // console.log( "earned: isVariableRewardRate" );
            // console.log( "earned: account = ", account );
            // console.log( "earned: _balances[account] = ", _balances[account] );
            // console.log( "earned: constantRewardRatePerTokenStored = ", constantRewardRatePerTokenStored );
            // console.log( "earned: lastTimeRewardApplicable() = ", lastTimeRewardApplicable() );
            // console.log( "earned: userLastUpdateTime[account] = ", userLastUpdateTime[account] );
            // console.log( "earned: rewards[account] = ", rewards[account] );
            // console.log( "earned: = ", _balances[account] * constantRewardRatePerTokenStored *
            // (lastTimeRewardApplicable() - userLastUpdateTime[account]) / ONE_TOKEN + rewards[account] );
            // uint256 _earned = _balances[account] * constantRewardRatePerTokenStored * (lastTimeRewardApplicable() -
            // userLastUpdateTime[account]) / ONE_TOKEN + rewards[account];
            // return _earned;
            return _balances[account] * constantRewardRatePerTokenStored
                * (lastTimeRewardApplicable() - userLastUpdateTime[account]) / ONE_TOKEN + rewards[account];
        }

        // uint256 _earned = _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / ONE_TOKEN +
        // rewards[account];
        // console.log( "earned: ! isVariableRewardRate" );
        // console.log( "earned: _balances[account] = ", _balances[account] );
        // console.log( "earned: rewardPerToken() = ", rewardPerToken() );
        // console.log( "earned: userRewardPerTokenPaid[account] = ", userRewardPerTokenPaid[account] );
        // console.log( "earned: rewards[account] = ", rewards[account] );
        // console.log( "earned: _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / ONE_TOKEN
        // = ", _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / ONE_TOKEN );
        // console.log( "earned: = ", _earned );
        // return _earned;
        return
            _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / ONE_TOKEN + rewards[account];
    }

    function getRewardForDuration() external view returns (uint256) {
        if (isVariableRewardRate) {
            // Current MAX possible reward for duration
            return constantRewardRatePerTokenStored * variableRewardMaxTotalSupply * rewardsDuration;
        }
        return rewardRate * rewardsDuration;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount) external nonReentrant whenNotPaused updateReward(msg.sender) {
        if (amount == 0) revert StakeZero();
        _totalSupply = _totalSupply + amount;
        if (isVariableRewardRate) {
            if (_totalSupply > variableRewardMaxTotalSupply) {
                revert StakeTotalSupplyExceedsAllowedMax(_totalSupply, variableRewardMaxTotalSupply);
            }
        }
        _balances[msg.sender] = _balances[msg.sender] + amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        if (isVariableRewardRate) {
            // Update variable reward rate
            variableRewardRate = constantRewardRatePerTokenStored * _totalSupply;
        }
        emit Staked(msg.sender, amount);
    }

    function stakeWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        nonReentrant
        whenNotPaused
        updateReward(msg.sender)
    {
        if (amount == 0) revert StakeZero();
        _totalSupply = _totalSupply + amount;
        if (isVariableRewardRate) {
            if (_totalSupply > variableRewardMaxTotalSupply) {
                revert StakeTotalSupplyExceedsAllowedMax(_totalSupply, variableRewardMaxTotalSupply);
            }
        }
        _balances[msg.sender] = _balances[msg.sender] + amount;

        // permit
        IUniswapV2ERC20(address(stakingToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        if (isVariableRewardRate) {
            // Update variable reward rate
            variableRewardRate = constantRewardRatePerTokenStored * _totalSupply;
        }
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        // console.log( "withdraw: amount = ", amount );
        if (amount == 0) revert WithdrawZero();
        if (_balances[msg.sender] == 0) revert NothingToWithdraw();
        if (amount > _balances[msg.sender]) revert NotEnoughToWithdraw(amount, _balances[msg.sender]);

        // console.log( "withdraw: after 0 amount check" );
        _totalSupply = _totalSupply - amount;
        // console.log( "withdraw: _totalSupply = ", _totalSupply );
        // console.log( "withdraw: current _balances[msg.sender] = ", _balances[msg.sender] );
        _balances[msg.sender] = _balances[msg.sender] - amount;
        // console.log( "withdraw: new _balances[msg.sender] = ", _balances[msg.sender] );
        stakingToken.safeTransfer(msg.sender, amount);
        // console.log( "withdraw: after safeTransfer" );
        if (isVariableRewardRate) {
            // Update variable reward rate
            variableRewardRate = constantRewardRatePerTokenStored * _totalSupply;
            // console.log( "withdraw: ISVARIABLEREWARDRATE" );
            // console.log( "withdraw: variableRewardRate = ", variableRewardRate );
        }
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function compoundReward() public nonReentrant updateReward(msg.sender) {
        if (stakingToken != rewardsToken) revert CompoundDifferentTokens();
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            _totalSupply = _totalSupply + reward;
            _balances[msg.sender] = _balances[msg.sender] + reward;
            rewards[msg.sender] = 0;
            emit Staked(msg.sender, reward);
        }
        // total supply updated
        if (isVariableRewardRate) {
            // Prevents compounding if total supply exceeds max
            // require(_totalSupply <= variableRewardMaxTotalSupply, "Total supply exceeds current allowed max");
            if (_totalSupply > variableRewardMaxTotalSupply) {
                revert CompounedTotalSupplyExceedsAllowedMax(_totalSupply, variableRewardMaxTotalSupply);
            }
            // Update variable reward rate
            variableRewardRate = constantRewardRatePerTokenStored * _totalSupply;
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    // Always needs to update the balance of the contract when calling this method
    function notifyVariableRewardAmount(
        uint256 _constantRewardRatePerTokenStored,
        uint256 _variableRewardMaxTotalSupply
    )
        external
        onlyOwner
    {
        isVariableRewardRate = true;
        constantRewardRatePerTokenStored = _constantRewardRatePerTokenStored;
        variableRewardRate = constantRewardRatePerTokenStored * _totalSupply;
        variableRewardMaxTotalSupply = _variableRewardMaxTotalSupply; // Set max LP cap ; if 0, no cap

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        // console.log( "notifyVariableRewardAmount: balance = ", balance );
        // console.log( "notifyVariableRewardAmount: variableRewardMaxTotalSupply  = ", variableRewardMaxTotalSupply );
        // console.log( "notifyVariableRewardAmount: _constantRewardRatePerTokenStored = ",
        // _constantRewardRatePerTokenStored );
        // console.log( "notifyVariableRewardAmount: rewardsDuration = ", rewardsDuration );
        // console.log( "notifyVariableRewardAmount: variableRewardMaxTotalSupply * _constantRewardRatePerTokenStored
        // = ", variableRewardMaxTotalSupply * _constantRewardRatePerTokenStored );
        // console.log( "notifyVariableRewardAmount: balance / rewardsDuration = ", balance / rewardsDuration );

        if (variableRewardMaxTotalSupply * _constantRewardRatePerTokenStored > balance / rewardsDuration) {
            revert ProvidedVariableRewardTooHigh(
                _constantRewardRatePerTokenStored, _variableRewardMaxTotalSupply, balance
            );
        }
        emit MaxTotalSupply(variableRewardMaxTotalSupply);

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAddedPerTokenStored(_constantRewardRatePerTokenStored);
    }

    function updateVariableRewardMaxTotalSupply(uint256 _variableRewardMaxTotalSupply) external onlyOwner {
        if (!isVariableRewardRate) revert NotVariableRewardRater();
        variableRewardMaxTotalSupply = _variableRewardMaxTotalSupply; // Set max LP cap ; if 0, no cap
        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        if (variableRewardMaxTotalSupply * constantRewardRatePerTokenStored > balance / rewardsDuration) {
            revert UpdateVariableRewardMaxTotalSupply(variableRewardMaxTotalSupply, balance);
        }
        emit MaxTotalSupply(variableRewardMaxTotalSupply);
        lastUpdateTime = block.timestamp; // not useful for rewards computations
    }

    function notifyRewardAmount(uint256 reward) external onlyOwner updateReward(address(0)) {
        isVariableRewardRate = false;

        // console.log( "notifyRewardAmount: block.timestamp = ", block.timestamp );
        if (block.timestamp >= periodFinish) {
            // console.log( "notifyRewardAmount: block.timestamp >= periodFinish");
            rewardRate = reward / rewardsDuration;
        } else {
            // console.log( "notifyRewardAmount: block.timestamp < periodFinish");
            uint256 remaining = periodFinish - block.timestamp;
            // console.log( "notifyRewardAmount: remaining = ", remaining );
            uint256 leftover = remaining * rewardRate;
            // console.log( "notifyRewardAmount: leftover = ", leftover );
            rewardRate = (reward + leftover) / rewardsDuration;
        }
        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        // console.log( "notifyRewardAmount: reward = ", reward );
        // console.log( "notifyRewardAmount: rewardRate = ", rewardRate );
        // console.log( "notifyRewardAmount: balance = ", balance );
        // console.log( "notifyRewardAmount: rewardsDuration = ", rewardsDuration );
        if (rewardRate > balance / rewardsDuration) revert ProvidedRewardTooHigh(reward, balance, rewardsDuration);
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        if (tokenAddress == address(stakingToken)) revert CantWithdrawStakingToken();
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        if (block.timestamp <= periodFinish) revert RewardPeriodInProgress(block.timestamp, periodFinish);
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        // console.log( "updateReward: account = ", account );
        if (isVariableRewardRate) {
            // console.log( "updateReward: isVariableRewardRate" );
            // Update variable reward rate
            rewardPerTokenStored = constantRewardRatePerTokenStored;

            if (account != address(0)) {
                // console.log( "updateReward: earned(account) = ", earned(account) );
                rewards[account] = earned(account);
                // console.log( "updateReward: rewardPerTokenStored = ", rewardPerTokenStored );
                userLastUpdateTime[account] = lastTimeRewardApplicable();
            }

            lastUpdateTime = lastTimeRewardApplicable(); // not useful for rewards computations when variable reward
                // rate
        } else {
            rewardPerTokenStored = rewardPerToken();
            lastUpdateTime = lastTimeRewardApplicable();
            // console.log( "updateReward: ! isVariableRewardRate" );
            // console.log( "updateReward: rewardPerTokenStored = ", rewardPerTokenStored );
            // console.log( "updateReward: lastUpdateTime = ", lastUpdateTime );
            if (account != address(0)) {
                // console.log( "updateReward: earned(account) = ", earned(account) );
                // console.log( "updateReward: rewardPerTokenStored = ", rewardPerTokenStored );
                rewards[account] = earned(account);
                userRewardPerTokenPaid[account] = rewardPerTokenStored;
            }
        }
        _;
    }

    /* ========== PAUSABLE ========== */

    function setPaused(bool _paused) external onlyOwner {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused()) {
            return;
        }
        // Set our paused state.
        if (_paused) {
            lastPauseTime = block.timestamp;
            _pause();
        } else {
            lastUnpauseTime = block.timestamp;
            _unpause();
        }
        // Let everyone know that our pause state has changed.
        // Events Paused/Unpaused emmited by _pause()/_un_pause()
    }
    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event RewardAddedPerTokenStored(uint256 rewardPerTokenStored);
    event MaxTotalSupply(uint256 maxTotalSupply);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);

    //////////////////////////////////////////////////////////

    /* ========== DEBUG ========== */

    // DELETE all the following functions after debugging
    /*
    //  * @dev Withdraw without caring about rewards. EMERGENCY ONLY.
    function withdrawAllOnly() external {
        withdraw(_balances[msg.sender]);
    }

    //  * @dev for testing only. remove after debugging

    function emergencyWithdrawUnsafe() external {
        uint256 amount = _balances[msg.sender];
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = 0;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    //  * @dev for testing only. remove after debugging

    function emergencyWithdrawAllUnsafe() external onlyOwner {
        uint256 amount = _totalSupply;
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = 0;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    */
    //////////////////////////////////////////////////////////
}
