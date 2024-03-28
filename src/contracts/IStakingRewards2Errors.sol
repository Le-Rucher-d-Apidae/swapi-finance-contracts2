// SPDX-License-Identifier: GPL-3.0-or-later

// pragma solidity ^0.8.23;
pragma solidity >=0.8.20 < 0.9.0;

/**
 * @dev StakingRewards2 Errors
 */
interface IStakingRewards2Errors {
    /**
     * @dev Previous rewards period must be complete before changing the duration for the new period
     * @param currentTimestamp.
     * @param periodFinish.
     */
    // ""
    error RewardPeriodInProgress(uint256 currentTimestamp, uint256 periodFinish);

    /**
     * @dev Cannot withdraw the staking token
     */
    error CantWithdrawStakingToken();

    /**
     * @dev Provided reward too high (insufficient balance in staking contract).
     * @param reward amount.
     */
    // error ProvidedRewardTooHigh(uint256 reward);
    error ProvidedRewardTooHigh(uint256 reward, uint256 rewardBalance, uint256 rewardsDuration);

    /**
     * @dev Rewards can't be zero address
     */
    error RewardTokenZeroAddress();

    /**
     * @dev Staking can't be zero address
     */
    error StakingTokenZeroAddress();

    /**
     * @dev Cannot stake 0
     */
    error StakeZero();

    /**
     * @dev Cannot withdraw 0
     */
    error WithdrawZero();

    /**
     * @dev Cannot compound different token. Staking and rewards token must be the same
     */
    error CompoundDifferentTokens();

    /**
     * @dev Withdraw : Cannot withdraw more than deposited
     */
    error NotEnoughToWithdraw(uint256 amountToWithdraw, uint256 currentBalance);
    /**
     * @dev Nothing deposited: Cannot withdraw. = NotEnoughToWithdraw ( , 0 )
     */
    error NothingToWithdraw();

    /* variable reward rate */

    /**
     * @dev Provided reward too high (insufficient balance in staking contract).
     */
    error ProvidedVariableRewardTooHigh(
        uint256 constantRewardPerTokenStored, uint256 variableRewardMaxTotalSupply, uint256 rewardBalance
    );

    /**
     * @dev Total supply exceeds allowed max
     * @param newTotalSupply amount after deposit.
     * @param variableRewardMaxTotalSupply current cap amount.
     */
    error StakeTotalSupplyExceedsAllowedMax(uint256 newTotalSupply, uint256 variableRewardMaxTotalSupply);

    /**
     * @dev After compounding total supply would exceeds allowed max
     * @param newTotalSupply amount after deposit.
     * @param variableRewardMaxTotalSupply current cap amount.
     */
    error CompounedTotalSupplyExceedsAllowedMax(uint256 newTotalSupply, uint256 variableRewardMaxTotalSupply);

    /**
     * @dev Variable reward rate must be enabled
     */
    error NotVariableRewardRater();

    /**
     * @dev Insufficient reward balance after Max total supply increase.
     * More reward than available balance amount could be spent.
     * @param variableRewardMaxTotalSupply .
     */
    error UpdateVariableRewardMaxTotalSupply(uint256 variableRewardMaxTotalSupply, uint256 rewardsBalance);
}
