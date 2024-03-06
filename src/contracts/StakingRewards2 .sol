// SPDX-License-Identifier: GPL-3.0-or-later
// pragma solidity ^0.7.6;
// pragma solidity >=0.8.23 < 0.9.0;
// pragma solidity ^0.8.23;
pragma solidity >=0.8.20 < 0.9.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// import { Ownable } from "@openzeppelin/contracts@3.4.1/access/Ownable.sol";
// import { Math } from "@openzeppelin/contracts@3.4.1/math/Math.sol";
// import { SafeMath } from "@openzeppelin/contracts@3.4.1/math/SafeMath.sol";
// import { IERC20, SafeERC20 } from "@openzeppelin/contracts@3.4.1/token/ERC20/SafeERC20.sol";
// import { ReentrancyGuard } from "@openzeppelin/contracts@3.4.1/utils/ReentrancyGuard.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
// import { SafeMath } from "@openzeppelin/contracts@3.4.1/math/SafeMath.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts@5.0.2/utils/ReentrancyGuard.sol";

import { IUniswapV2ERC20 } from "./Uniswap/v2-core/interfaces/IUniswapV2ERC20.sol";

// https://docs.synthetix.io/contracts/source/contracts/stakingrewards
contract StakingRewards2 is ReentrancyGuard, Ownable(msg.sender) {
    // using SafeMath for uint256;
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
    uint256 public constantRewardPerTokenStored;
    uint256 public variableRewardMaxTotalSupply;
    // uint256 public variableRewardRateInitialTotalSupply;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rewardsToken, address _stakingToken) {
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

    // function rewardPerToken() public view returns (uint256) {
    function rewardPerToken() public /* view */ returns (uint256) {
        if (isVariableRewardRate) {
            emit Uint256ValueEvent(1, "isVariableRewardRate");
            emit Uint256ValueEvent(constantRewardPerTokenStored, "constantRewardPerTokenStored");

            // Uint256ValueEvent(_totalSupply, "_totalSupply");

            // if (_totalSupply == 0) {
            //     Uint256ValueEvent(constantRewardPerTokenStored,
            //          "constantRewardPerTokenStored");
            //     return constantRewardPerTokenStored;
            // }

            // Uint256ValueEvent(lastTimeRewardApplicable(), "lastTimeRewardApplicable()");
            // Uint256ValueEvent(lastUpdateTime, "lastUpdateTime");
            // Uint256ValueEvent(variableRewardRate, "variableRewardRate");

            // Uint256ValueEvent(lastTimeRewardApplicable().sub(lastUpdateTime),
            //          "laslastTimeRewardApplicable().sub(lastUpdateTime)");
            // Uint256ValueEvent(lastTimeRewardApplicable().sub(lastUpdateTime).mul(variableRewardRate),
            //      "lastTimeRewardApplicable().sub(lastUpdateTime).mul(variableRewardRate)");
            // Uint256ValueEvent(lastTimeRewardApplicable().sub(lastUpdateTime).mul(variableRewardRate).mul(1e18),
            //      "lastTimeRewardApplicable().sub(lastUpdateTime).mul(variableRewardRate).mul(1e18)");

            // return lastTimeRewardApplicable().sub(lastUpdateTime).mul(variableRewardRate)
            return constantRewardPerTokenStored;
        }
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored +
            (( lastTimeRewardApplicable() - lastUpdateTime) * (rewardRate) * (1e18) / (_totalSupply));
    }

    // function earned(address account) public view returns (uint256) {
    function earned(address account) public /* view */ returns (uint256) {
        if (isVariableRewardRate) {
            emit Uint256ValueEvent(_balances[account], "_balances[account]");
            emit Uint256ValueEvent(constantRewardPerTokenStored, "constantRewardPerTokenStored");
            emit Uint256ValueEvent(userRewardPerTokenPaid[account], "userRewardPerTokenPaid[account]");
            emit Uint256ValueEvent(rewards[account], "rewards[account]");
            emit Uint256ValueEvent(
                _balances[account] * (constantRewardPerTokenStored - userRewardPerTokenPaid[account]) +
                    rewards[account]
                ,
                "_balances[account] * (constantRewardPerTokenStored-userRewardPerTokenPaid[account])+"
                "rewards[account]"
            );

            return _balances[account] * ((constantRewardPerTokenStored) - userRewardPerTokenPaid[account]) +
                rewards[account];
        }
        return _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18 + rewards[account];
    }

    function getRewardForDuration() external view returns (uint256) {
        //  if (isVariableRewardRate) {
        //     return variableRewardRate.mul(rewardsDuration);
        // }
        if (isVariableRewardRate) {
            return variableRewardRate * rewardsDuration;
        }
        return rewardRate * rewardsDuration;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply + amount;
        if (isVariableRewardRate) {
            require(_totalSupply <= variableRewardMaxTotalSupply, "Total supply exceeds allowed max");
        }
        _balances[msg.sender] = _balances[msg.sender] + amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        if (isVariableRewardRate) {
            // Update variable reward rate
            variableRewardRate = constantRewardPerTokenStored * _totalSupply;
        }

        // if (isVariableRewardRate) {
        //  variableRewardRate = variableRewardRate * _totalSupply / variableRewardRateInitialTotalSupply;
        //  constantRewardPerTokenStored = constantRewardPerTokenStored.add(
        //       lastTimeRewardApplicable().sub(lastUpdateTime).mul(variableRewardRate).mul(1e18).div(_totalSupply)
        //   );
        // }

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
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply + amount;
        if (isVariableRewardRate) {
            require(_totalSupply <= variableRewardMaxTotalSupply, "Total supply exceeds current allowed max");
        }
        _balances[msg.sender] = _balances[msg.sender] + amount;

        // permit
        IUniswapV2ERC20(address(stakingToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        // if (isVariableRewardRate) {
        //  variableRewardRate = variableRewardRate * _totalSupply / variableRewardRateInitialTotalSupply;
        //  constantRewardPerTokenStored = constantRewardPerTokenStored.add(
        //         lastTimeRewardApplicable().sub(lastUpdateTime).mul(variableRewardRate).mul(1e18).div(_totalSupply)
        //   );
        // }
        if (isVariableRewardRate) {
            // Update variable reward rate
            variableRewardRate = constantRewardPerTokenStored * _totalSupply;
        }
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        stakingToken.safeTransfer(msg.sender, amount);
        // if (isVariableRewardRate) {
        //  variableRewardRate = variableRewardRate * _totalSupply / variableRewardRateInitialTotalSupply;
        //  constantRewardPerTokenStored = constantRewardPerTokenStored.sub(
        //     lastTimeRewardApplicable().sub(lastUpdateTime).mul(variableRewardRate).mul(1e18).div(_totalSupply)
        //   );
        // }
        if (isVariableRewardRate) {
            // Update variable reward rate
            variableRewardRate = constantRewardPerTokenStored * _totalSupply;
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
        require(stakingToken == rewardsToken, "Staking and rewards token must be the same");
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
            require(_totalSupply <= variableRewardMaxTotalSupply, "Total supply exceeds current allowed max");
            // Update variable reward rate
            variableRewardRate = constantRewardPerTokenStored * _totalSupply;
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    // Always needs to update the balance of the contract when calling this method
    function notifyVariableRewardAmount(
        uint256 _constantRewardPerTokenStored,
        uint256 _variableRewardMaxTotalSupply
    )
        external
        onlyOwner
    {
        isVariableRewardRate = true;
        constantRewardPerTokenStored = _constantRewardPerTokenStored;
        emit Uint256ValueEvent(constantRewardPerTokenStored, "constantRewardPerTokenStored");
        emit Uint256ValueEvent(_totalSupply, "_totalSupply");
        variableRewardRate = constantRewardPerTokenStored * _totalSupply;
        emit Uint256ValueEvent(variableRewardRate, "variableRewardRate");
        variableRewardMaxTotalSupply = _variableRewardMaxTotalSupply; // Set max LP cap ; if 0, no cap
        emit Uint256ValueEvent(variableRewardMaxTotalSupply, "variableRewardMaxTotalSupply");

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        emit Uint256ValueEvent(balance, "balance");

        // TODO: add and set a max cap when variable reward rate
        // require(variableRewardRate *  variableRewardMaxTotalSupply <= balance.div(rewardsDuration),
        //  "Provided reward too high");
        emit Uint256ValueEvent(
            variableRewardMaxTotalSupply * constantRewardPerTokenStored,
            "variableRewardMaxTotalSupply * constantRewardPerTokenStored"
        );
        emit Uint256ValueEvent(balance / rewardsDuration , "balance / rewardsDuration");
        require(
            variableRewardMaxTotalSupply * _constantRewardPerTokenStored <= balance / rewardsDuration,
            "Provided reward too high"
        );
        emit MaxTotalSupply(variableRewardMaxTotalSupply);

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit Uint256ValueEvent(periodFinish, "periodFinish");
        emit RewardAddedPerTokenStored(_constantRewardPerTokenStored);
    }

    function updateVariableRewardMaxTotalSupply(uint256 _variableRewardMaxTotalSupply) external onlyOwner {
        require(isVariableRewardRate, "Variable reward rate must be enabled");
        variableRewardMaxTotalSupply = _variableRewardMaxTotalSupply; // Set max LP cap ; if 0, no cap

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));

        // TODO: add and set a max cap when variable reward rate
        // require(variableRewardRate *  variableRewardMaxTotalSupply <= balance.div(rewardsDuration),
        //      "Provided reward too high for new max total supply");
        require(
            variableRewardMaxTotalSupply * constantRewardPerTokenStored <= balance / rewardsDuration,
            "Provided reward too high"
        );
        emit MaxTotalSupply(variableRewardMaxTotalSupply);
        lastUpdateTime = block.timestamp;
    }

    function notifyRewardAmount(uint256 reward) external onlyOwner updateReward(address(0)) {
        isVariableRewardRate = false;

        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
        }
        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance / rewardsDuration, "Provided reward too high");
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(stakingToken), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    // variable reward rate
    // when set, keeps reward rate proportional to the total supply
    // reward rate at the time of activation is taken as reference

    // /**
    //  * @param _variableRewardRate Enable/Disable variable reward rate
    //  * @dev If variable reward rate is enabled, variableRewardRate will be updated
    //  *      every time a user interacts with the contract
    //  */
    // function setVariableRewardRate(
    //     bool _variableRewardRate,
    //     // uint256 _minTotalSupply
    //      uint256 _constantRewardPerTokenStored
    //     ) external onlyOwner {
    //     isVariableRewardRate = _variableRewardRate;
    //     // variableRewardRate = rewardRate;
    //     // current total supply is taken as reference: must be > 0 and significant enough
    //     // require(_totalSupply > 0 && _totalSupply > _minTotalSupply,
    //     //       "Total supply must be > 0 and significant enough");
    //     // variableRewardRateInitialTotalSupply = _totalSupply;
    //     constantRewardPerTokenStored = _constantRewardPerTokenStored;
    //     variableRewardRate = constantRewardPerTokenStored * _totalSupply;
    // }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        emit AddressEvent(account, "updateReward");
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        emit Uint256ValueEvent(rewardPerTokenStored, "rewardPerTokenStored");
        if (account != address(0)) {
            rewards[account] = earned(account);
            emit Uint256ValueEvent(rewards[account], "rewards[account]");
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
            emit Uint256ValueEvent(userRewardPerTokenPaid[account], "userRewardPerTokenPaid[account]");
        }
        _;
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

    /**
     * @dev Withdraw without caring about rewards. EMERGENCY ONLY.
     */
    function withdrawOnly() external {
        withdraw(_balances[msg.sender]);
    }
    /**
     * @dev for testing only. remove after debugging
     */

    function emergencyWithdrawUnsafe() external {
        uint256 amount = _balances[msg.sender];
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = 0;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    /**
     * @dev for testing only. remove after debugging
     */

    function emergencyWithdrawAllUnsafe() external onlyOwner {
        uint256 amount = _totalSupply;
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = 0;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    event Uint256ValueEvent(uint256 value, string message);
    event AddressEvent(address value, string message);

    //////////////////////////////////////////////////////////
}
