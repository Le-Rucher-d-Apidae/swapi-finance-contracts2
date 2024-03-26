// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { console } from "forge-std/src/console.sol";
import {stdMath} from "forge-std/src/StdMath.sol";

import "./StakingRewards2_base.t.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import { IStakingRewards2Errors } from "../src/contracts/IStakingRewards2Errors.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";

// ----------------

abstract contract StakingPreSetup0 is TestLog {
        // Rewards constants

    // Duration of the rewards program
    uint256 constant internal REWARD_INITIAL_DURATION = 10_000; // 10e4 ; 10 000 s. = 2 h. 46 m. 40 s.

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration)
    internal view virtual returns (uint256 expectedRewardsAmount);
}

abstract contract StakingPreSetup1 is StakingPreSetup0 {

    // // Rewards constants

    // // Duration of the rewards program
    // uint256 constant internal REWARD_INITIAL_DURATION = 10_000; // 10e4 ; 10 000 s. = 2 h. 46 m. 40 s.


    // Variable rewards
    // Limit max LP tokens staked
    uint256 constant internal VARIABLE_REWARD_MAXTOTALSUPPLY_LP = 6; // Max LP : 6
    uint256 constant internal VARIABLE_REWARD_MAXTOTALSUPPLY = VARIABLE_REWARD_MAXTOTALSUPPLY_LP * ONE_TOKEN;
    uint256 constant internal CONSTANT_REWARDRATE_PERTOKENSTORED = 1e3; // 1 000 ; for each LP token earn 1 000 reward per second

    uint256 constant internal REWARD_INITIAL_AMOUNT = CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY * REWARD_INITIAL_DURATION;  // Max. budget allocated to rewards


    // function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration)
    // internal view virtual returns (uint256 expectedRewardsAmount);
}

abstract contract StakingPreSetup is StakingPreSetup1 {

    StakingRewards2 internal stakingRewards2;
    uint256 immutable STAKING_START_TIME = block.timestamp;

    uint256  internal TOTAL_STAKED_AMOUNT;
    uint256  STAKING_PERCENTAGE_DURATION;
    uint256  CLAIM_PERCENTAGE_DURATION;

    // Rewards constants
    // Duration of the rewards program
    // uint256 constant internal REWARD_INITIAL_DURATION = 10_000; // 10e4 ; 10 000 s. = 2 h. 46 m. 40 s.




    // // Variable rewards
    // // Limit max LP tokens staked
    // uint256 constant internal VARIABLE_REWARD_MAXTOTALSUPPLY_LP = 6; // Max LP : 6
    // uint256 constant internal VARIABLE_REWARD_MAXTOTALSUPPLY = VARIABLE_REWARD_MAXTOTALSUPPLY_LP * ONE_TOKEN;
    // uint256 constant internal CONSTANT_REWARDRATE_PERTOKENSTORED = 1e3; // 1 000 ; for each LP token earn 1 000 reward per second

    // uint256 constant internal REWARD_INITIAL_AMOUNT = CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY * REWARD_INITIAL_DURATION;  // Max. budget allocated to rewards


    function checkStakingTotalSupplyStaked() internal {
        debugLog( "checkStakingTotalSupplyStaked" );
        uint256 stakingRewardsTotalSupply = stakingRewards2.totalSupply();
        debugLog( "checkStakingTotalSupplyStaked: stakingRewardsTotalSupply = ", stakingRewardsTotalSupply );
        assertEq( TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply );
    }
    function getRewardDurationReached() internal view returns (uint256) {
        debugLog( "getRewardDurationReached" );
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100);
        verboseLog( "getRewardDurationReached: rewardDurationReached = ",  rewardDurationReached);
        return rewardDurationReached;
    }
    function getRewardDurationReached(uint _durationReached) internal view /* pure */ returns (uint256) {
        debugLog( "getRewardDurationReached: ",  _durationReached);
        uint256 rewardDurationReached = (_durationReached >= REWARD_INITIAL_DURATION ? REWARD_INITIAL_DURATION : _durationReached);
        debugLog( "getRewardDurationReached: rewardDurationReached = ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) internal {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
    }

    function checkRewardPerToken(uint256 _expectedRewardPerToken, uint256 _percentDelta, uint8 _unitsDelta) internal {
        debugLog("checkRewardPerToken: _expectedRewardPerToken = ", _expectedRewardPerToken);
        uint256 stakingRewardsRewardPerToken = stakingRewards2.rewardPerToken();
        if (stakingRewardsRewardPerToken != _expectedRewardPerToken) {
            debugLog("checkRewardPerToken: stakingRewardsRewardPerToken = ", stakingRewardsRewardPerToken);
                if (_expectedRewardPerToken == 0) {
                fail("StakingSetup: checkRewardPerToken: stakingRewardsRewardPerToken != _expectedRewardPerToken && _expectedRewardPerToken == 0");
            }
            uint256 percentDelta = stdMath.percentDelta(stakingRewardsRewardPerToken, _expectedRewardPerToken);

            debugLog("checkRewardPerToken: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("checkRewardPerToken: _unitsDelta = ", _unitsDelta);
                    assertApproxEqAbs( stakingRewardsRewardPerToken, _expectedRewardPerToken, _unitsDelta );
                } else {
                    if (_percentDelta == 0) {
                        assertEq( stakingRewardsRewardPerToken, _expectedRewardPerToken );
                    } else {
                        assertApproxEqRel( stakingRewardsRewardPerToken, _expectedRewardPerToken, _percentDelta );
                    }
                }
            }
        }
    }

    function getClaimPercentDelta() internal view returns (uint256) {
        // Longer staking period = better accuracy : less delta
        uint256 claimDelta = CLAIM_PERCENTAGE_DURATION <= PERCENT_10 ? (CLAIM_PERCENTAGE_DURATION <= PERCENT_1 ? DELTA_5 : DELTA_0_4) : DELTA_0_015;
        verboseLog( "claimDelta : ", claimDelta );
        return claimDelta;
    }

    function getRewardPercentDelta() public view returns (uint256) {
        verboseLog("getRewardPercentDelta");
        // Longer staking period = better accuracy : less delta
        uint256 rewardsPercentDelta =
            CLAIM_PERCENTAGE_DURATION > PERCENT_90 ?
                (CLAIM_PERCENTAGE_DURATION > PERCENT_95 ?
                        DELTA_5 : DELTA_0_5)
                :   STAKING_PERCENTAGE_DURATION <= PERCENT_10 ?
                            STAKING_PERCENTAGE_DURATION <= PERCENT_5 ?
                                STAKING_PERCENTAGE_DURATION <= PERCENT_1 ?
                                    DELTA_0_5 :
                                    DELTA_5
                            : DELTA_0_08
            : DELTA_0_015
        ;
        verboseLog( "getRewardDelta = ", rewardsPercentDelta );
        return rewardsPercentDelta;
    }

    function getRewardUnitsDelta() public pure returns (uint8) {
        // Longer staking period = better accuracy : less delta
        return 1;
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _percentDelta, uint8 _unitsDelta) internal {
        debugLog("checkStakingRewards: _stakerName : ", _stakerName);
        debugLog("checkStakingRewards: _expectedRewardAmount : ", _expectedRewardAmount);
        debugLog("checkStakingRewards: _percentDelta : ", _percentDelta);
        uint256 stakerRewards = stakingRewards2.earned( _staker );
        debugLog("checkStakingRewards: stakerRewards = ", stakerRewards);

        if (stakerRewards != _expectedRewardAmount) {
            debugLog("stakerRewards != _expectedRewardAmount");
            if (_expectedRewardAmount == 0) {
                fail("StakingSetup: checkStakingRewards: stakerRewards != _expectedRewardAmount && _expectedRewardAmount == 0");
            }
            uint256 percentDelta = stdMath.percentDelta(stakerRewards, _expectedRewardAmount);
            debugLog("checkStakingRewards: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("checkStakingRewards: _unitsDelta = ", _unitsDelta);
                    debugLog("checkStakingRewards: assertApproxEqAbs stakerRewards= ", stakerRewards);
                    debugLog("checkStakingRewards: assertApproxEqAbs _expectedRewardAmount= ", _expectedRewardAmount);
                    debugLog("checkStakingRewards: assertApproxEqAbs stakerRewards= ", _unitsDelta);
                    assertApproxEqAbs( stakerRewards, _expectedRewardAmount, _unitsDelta );
                } else {
                    debugLog("checkStakingRewards: 1");
                    if (_percentDelta == 0) {
                    debugLog("checkStakingRewards: 2");
                        assertEq( stakerRewards, _expectedRewardAmount );
                    } else {
                    debugLog("checkStakingRewards: 3");
                        assertApproxEqRel( stakerRewards, _expectedRewardAmount, _percentDelta );
                    }
                }
            }
        }
        debugLog("checkStakingRewards: 4");
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function checkUserClaim(address _user, uint256 _stakeAmount, string memory _userName, uint256 _delta, RewardERC20 rewardErc20) internal returns(uint256 claimedRewards_) {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog( "CLAIM:" );
            verboseLog(_userName);
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
            debugLog( "stakingElapsedTime = ", stakingElapsedTime );
            uint256 rewardErc20UserBalance = rewardErc20.balanceOf( _user );
            verboseLog( "CLAIM: before: user reward balance = ", rewardErc20UserBalance );
            uint256 expectedRewards = expectedStakingRewards( _stakeAmount, stakingElapsedTime, REWARD_INITIAL_DURATION );
            vm.prank(_user);
            vm.expectEmit(true,true,false,false, address(stakingRewards2));
            emit StakingRewards2.RewardPaid( _user, expectedRewards );
            stakingRewards2.getReward();
            // Check user rewards balance before/after claim
            uint256 rewardErc20UserBalanceAfterClaim = rewardErc20.balanceOf( _user );
            claimedRewards_ = rewardErc20UserBalanceAfterClaim - rewardErc20UserBalance;
            verboseLog( "CLAIM: after: user reward balance = ", rewardErc20UserBalanceAfterClaim );
            if (_delta == 0) {
                assertEq( expectedRewards, claimedRewards_ );
            } else {
                assertApproxEqRel( expectedRewards, claimedRewards_, _delta );
            }
        }
    }

    function checkRewardForDuration() internal {
        debugLog( "checkRewardForDuration" );
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards2.getRewardForDuration( );
        debugLog( "checkRewardForDuration: getRewardForDuration = ", stakingRewards2.getRewardForDuration() );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        verboseLog( "Staking contract: rewardsDuration ok" );
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) internal {
        debugLog( "checkStakingPeriod: _stakingPercentageDurationReached : ", _stakingPercentageDurationReached );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 stakingTimeReached = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        debugLog( "checkStakingPeriod: stakingTimeReached = ", stakingTimeReached );
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        debugLog( "checkStakingPeriod: lastTimeReward = ", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
    }

    function withdrawStake(address _user, uint256 _amount) public {
        debugLog( "withdrawStake: _user : ", _user );
        debugLog( "withdrawStake: _amount : ", _amount );
        uint256 balanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_user);
        debugLog( "withdrawStake: balanceOfUserBeforeWithdrawal = ", balanceOfUserBeforeWithdrawal );
        // Check emitted event
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Withdrawn( _user, _amount );
        vm.prank(_user);
        stakingRewards2.withdraw( _amount );
        uint256 balanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_user);
        debugLog( "withdrawStake: balanceOfUserBeforeWithdrawal = ", balanceOfUserBeforeWithdrawal );
        assertEq( balanceOfUserBeforeWithdrawal - _amount, balanceOfUserAfterWithdrawal );
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) internal returns (uint256) {
        debugLog( "gotoStakingPeriod: _stakingPercentageDurationReached : ", _stakingPercentageDurationReached );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        debugLog( "getStakingTimeReached" );
        uint256 rewardDurationReached = getRewardDurationReached();
        debugLog( "getStakingTimeReached: rewardDurationReached : ", rewardDurationReached );
        return STAKING_START_TIME + rewardDurationReached;
    }

    function getStakingDuration() internal view returns (uint256) {
        debugLog( "getStakingDuration" );
        uint256 stakingDuration = REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100;
        verboseLog( "getStakingDuration: stakingDuration = ",  stakingDuration);
        return stakingDuration;
    }

    function getRewardedStakingDuration(uint8 _divide) internal view returns (uint256) {
        debugLog( "getRewardedStakingDuration: _divide : ", _divide );
        uint256 stakingDuration = getStakingDuration() / _divide;
        debugLog( "getRewardedStakingDuration: stakingDuration = ",  stakingDuration);
        uint256 rewardedStakingDuration = getRewardDurationReached( stakingDuration );
        verboseLog( "getRewardedStakingDuration: rewardedStakingDuration = ",  rewardedStakingDuration);
        return rewardedStakingDuration;
    }

//   function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached , uint256 _rewardTotalDuration) public view /* pure */ returns (uint256 expectedRewardsAmount) {
//         debugLog("expectedStakingRewards: _stakedAmount = ", _stakedAmount);
//         debugLog("expectedStakingRewards: _rewardDurationReached = ", _rewardDurationReached);
//         debugLog("expectedStakingRewards: _rewardTotalDuration = ", _rewardTotalDuration);
//         uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
//         verboseLog( "expectedStakingRewards: rewardsDuration= ", rewardsDuration );
//         uint256 expectedStakingRewardsAmount = CONSTANT_REWARDRATE_PERTOKENSTORED * _stakedAmount / ONE_TOKEN * rewardsDuration;
//         verboseLog( "expectedStakingRewards: expectedStakingRewardsAmount= ", expectedStakingRewardsAmount );
//         return expectedStakingRewardsAmount;
//     }
    // function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration)
    // internal view virtual returns (uint256 expectedRewardsAmount);
}

/*

contract StakingSetup is TestLog {

    StakingRewards2 internal stakingRewards2;
    uint256 immutable STAKING_START_TIME = block.timestamp;

    uint256  internal TOTAL_STAKED_AMOUNT;
    uint256  STAKING_PERCENTAGE_DURATION;
    uint256  CLAIM_PERCENTAGE_DURATION;

    // Rewards constants
    // Duration of the rewards program
    uint256 constant internal REWARD_INITIAL_DURATION = 10_000; // 10e4 ; 10 000 s. = 2h 46m 40s

    // Variable rewards
    // Limit max LP tokens staked
    uint256 constant internal VARIABLE_REWARD_MAXTOTALSUPPLY_LP = 6; // Max LP : 6
    uint256 constant internal VARIABLE_REWARD_MAXTOTALSUPPLY = VARIABLE_REWARD_MAXTOTALSUPPLY_LP * ONE_TOKEN;
    uint256 constant internal CONSTANT_REWARDRATE_PERTOKENSTORED = 1e3; // 1 000 ; for each LP token earn 1 000 reward per second

    uint256 constant internal REWARD_INITIAL_AMOUNT = CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY * REWARD_INITIAL_DURATION;  // Max. budget allocated to rewards

    function checkStakingTotalSupplyStaked() internal {
        debugLog( "checkStakingTotalSupplyStaked" );
        uint256 stakingRewardsTotalSupply = stakingRewards2.totalSupply();
        debugLog( "checkStakingTotalSupplyStaked: stakingRewardsTotalSupply = ", stakingRewardsTotalSupply );
        assertEq( TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply );
    }
    function getRewardDurationReached() internal view returns (uint256) {
        debugLog( "getRewardDurationReached" );
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100);
        verboseLog( "getRewardDurationReached: rewardDurationReached = ",  rewardDurationReached);
        return rewardDurationReached;
    }
    function getRewardDurationReached(uint _durationReached) internal view  returns (uint256) {
        debugLog( "getRewardDurationReached: ",  _durationReached);
        uint256 rewardDurationReached = (_durationReached >= REWARD_INITIAL_DURATION ? REWARD_INITIAL_DURATION : _durationReached);
        debugLog( "getRewardDurationReached: rewardDurationReached = ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) internal {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
    }

    function checkRewardPerToken(uint256 _expectedRewardPerToken, uint256 _percentDelta, uint8 _unitsDelta) internal {
        debugLog("checkRewardPerToken: _expectedRewardPerToken = ", _expectedRewardPerToken);
        uint256 stakingRewardsRewardPerToken = stakingRewards2.rewardPerToken();
        if (stakingRewardsRewardPerToken != _expectedRewardPerToken) {
            debugLog("checkRewardPerToken: stakingRewardsRewardPerToken = ", stakingRewardsRewardPerToken);
                if (_expectedRewardPerToken == 0) {
                fail("StakingSetup: checkRewardPerToken: stakingRewardsRewardPerToken != _expectedRewardPerToken && _expectedRewardPerToken == 0");
            }
            uint256 percentDelta = stdMath.percentDelta(stakingRewardsRewardPerToken, _expectedRewardPerToken);

            debugLog("checkRewardPerToken: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("checkRewardPerToken: _unitsDelta = ", _unitsDelta);
                    assertApproxEqAbs( stakingRewardsRewardPerToken, _expectedRewardPerToken, _unitsDelta );
                } else {
                    if (_percentDelta == 0) {
                        assertEq( stakingRewardsRewardPerToken, _expectedRewardPerToken );
                    } else {
                        assertApproxEqRel( stakingRewardsRewardPerToken, _expectedRewardPerToken, _percentDelta );
                    }
                }
            }
        }
    }

    function getClaimPercentDelta() internal view returns (uint256) {
        // Longer staking period = better accuracy : less delta
        uint256 claimDelta = CLAIM_PERCENTAGE_DURATION <= PERCENT_10 ? (CLAIM_PERCENTAGE_DURATION <= PERCENT_1 ? DELTA_5 : DELTA_0_4) : DELTA_0_015;
        verboseLog( "claimDelta : ", claimDelta );
        return claimDelta;
    }

    function getRewardPercentDelta() public view returns (uint256) {
        verboseLog("getRewardPercentDelta");
        // Longer staking period = better accuracy : less delta
        uint256 rewardsPercentDelta =
            CLAIM_PERCENTAGE_DURATION > PERCENT_90 ?
                (CLAIM_PERCENTAGE_DURATION > PERCENT_95 ?
                        DELTA_5 : DELTA_0_5)
                :   STAKING_PERCENTAGE_DURATION <= PERCENT_10 ?
                            STAKING_PERCENTAGE_DURATION <= PERCENT_5 ?
                                STAKING_PERCENTAGE_DURATION <= PERCENT_1 ?
                                    DELTA_0_5 :
                                    DELTA_5
                            : DELTA_0_08
            : DELTA_0_015
        ;
        verboseLog( "getRewardDelta = ", rewardsPercentDelta );
        return rewardsPercentDelta;
    }

    function getRewardUnitsDelta() public pure returns (uint8) {
        // Longer staking period = better accuracy : less delta
        return 1;
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _percentDelta, uint8 _unitsDelta) internal {
        debugLog("checkStakingRewards: _stakerName : ", _stakerName);
        debugLog("checkStakingRewards: _expectedRewardAmount : ", _expectedRewardAmount);
        debugLog("checkStakingRewards: _percentDelta : ", _percentDelta);
        uint256 stakerRewards = stakingRewards2.earned( _staker );
        debugLog("checkStakingRewards: stakerRewards = ", stakerRewards);

        if (stakerRewards != _expectedRewardAmount) {
            debugLog("stakerRewards != _expectedRewardAmount");
            if (_expectedRewardAmount == 0) {
                fail("StakingSetup: checkStakingRewards: stakerRewards != _expectedRewardAmount && _expectedRewardAmount == 0");
            }
            uint256 percentDelta = stdMath.percentDelta(stakerRewards, _expectedRewardAmount);
            debugLog("checkStakingRewards: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("checkStakingRewards: _unitsDelta = ", _unitsDelta);
                    debugLog("checkStakingRewards: assertApproxEqAbs stakerRewards= ", stakerRewards);
                    debugLog("checkStakingRewards: assertApproxEqAbs _expectedRewardAmount= ", _expectedRewardAmount);
                    debugLog("checkStakingRewards: assertApproxEqAbs stakerRewards= ", _unitsDelta);
                    assertApproxEqAbs( stakerRewards, _expectedRewardAmount, _unitsDelta );
                } else {
                    debugLog("checkStakingRewards: 1");
                    if (_percentDelta == 0) {
                    debugLog("checkStakingRewards: 2");
                        assertEq( stakerRewards, _expectedRewardAmount );
                    } else {
                    debugLog("checkStakingRewards: 3");
                        assertApproxEqRel( stakerRewards, _expectedRewardAmount, _percentDelta );
                    }
                }
            }
        }
        debugLog("checkStakingRewards: 4");
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function checkUserClaim(address _user, uint256 _stakeAmount, string memory _userName, uint256 _delta, RewardERC20 rewardErc20) internal returns(uint256 claimedRewards_) {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog( "CLAIM:" );
            verboseLog(_userName);
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
            debugLog( "stakingElapsedTime = ", stakingElapsedTime );
            uint256 rewardErc20UserBalance = rewardErc20.balanceOf( _user );
            verboseLog( "CLAIM: before: user reward balance = ", rewardErc20UserBalance );
            uint256 expectedRewards = expectedStakingRewards( _stakeAmount, stakingElapsedTime, REWARD_INITIAL_DURATION );
            vm.prank(_user);
            vm.expectEmit(true,true,false,false, address(stakingRewards2));
            emit StakingRewards2.RewardPaid( _user, expectedRewards );
            stakingRewards2.getReward();
            // Check user rewards balance before/after claim
            uint256 rewardErc20UserBalanceAfterClaim = rewardErc20.balanceOf( _user );
            claimedRewards_ = rewardErc20UserBalanceAfterClaim - rewardErc20UserBalance;
            verboseLog( "CLAIM: after: user reward balance = ", rewardErc20UserBalanceAfterClaim );
            if (_delta == 0) {
                assertEq( expectedRewards, claimedRewards_ );
            } else {
                assertApproxEqRel( expectedRewards, claimedRewards_, _delta );
            }
        }
    }

    function checkRewardForDuration() internal {
        debugLog( "checkRewardForDuration" );
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards2.getRewardForDuration( );
        debugLog( "checkRewardForDuration: getRewardForDuration = ", stakingRewards2.getRewardForDuration() );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        verboseLog( "Staking contract: rewardsDuration ok" );
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) internal {
        debugLog( "checkStakingPeriod: _stakingPercentageDurationReached : ", _stakingPercentageDurationReached );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 stakingTimeReached = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        debugLog( "checkStakingPeriod: stakingTimeReached = ", stakingTimeReached );
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        debugLog( "checkStakingPeriod: lastTimeReward = ", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
    }

    function withdrawStake(address _user, uint256 _amount) public {
        debugLog( "withdrawStake: _user : ", _user );
        debugLog( "withdrawStake: _amount : ", _amount );
        uint256 balanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_user);
        debugLog( "withdrawStake: balanceOfUserBeforeWithdrawal = ", balanceOfUserBeforeWithdrawal );
        // Check emitted event
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Withdrawn( _user, _amount );
        vm.prank(_user);
        stakingRewards2.withdraw( _amount );
        uint256 balanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_user);
        debugLog( "withdrawStake: balanceOfUserBeforeWithdrawal = ", balanceOfUserBeforeWithdrawal );
        assertEq( balanceOfUserBeforeWithdrawal - _amount, balanceOfUserAfterWithdrawal );
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) internal returns (uint256) {
        debugLog( "gotoStakingPeriod: _stakingPercentageDurationReached : ", _stakingPercentageDurationReached );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        debugLog( "getStakingTimeReached" );
        uint256 rewardDurationReached = getRewardDurationReached();
        debugLog( "getStakingTimeReached: rewardDurationReached : ", rewardDurationReached );
        return STAKING_START_TIME + rewardDurationReached;
    }

    function getStakingDuration() internal view returns (uint256) {
        debugLog( "getStakingDuration" );
        uint256 stakingDuration = REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100;
        verboseLog( "getStakingDuration: stakingDuration = ",  stakingDuration);
        return stakingDuration;
    }

    function getRewardedStakingDuration(uint8 _divide) internal view returns (uint256) {
        debugLog( "getRewardedStakingDuration: _divide : ", _divide );
        uint256 stakingDuration = getStakingDuration() / _divide;
        debugLog( "getRewardedStakingDuration: stakingDuration = ",  stakingDuration);
        uint256 rewardedStakingDuration = getRewardDurationReached( stakingDuration );
        verboseLog( "getRewardedStakingDuration: rewardedStakingDuration = ",  rewardedStakingDuration);
        return rewardedStakingDuration;
    }

    // function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration) internal view returns (uint256 expectedRewardsAmount) {
    //     debugLog("expectedStakingRewards: _stakedAmount = ", _stakedAmount);
    //     debugLog("expectedStakingRewards: _rewardDurationReached = ", _rewardDurationReached);
    //     debugLog("expectedStakingRewards: _rewardTotalDuration = ", _rewardTotalDuration);
    //     uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
    //     debugLog("expectedStakingRewards: rewardsDuration = ", rewardsDuration);
    //     uint256 expectedStakingRewards_ =
    //      (rewardsDuration == _rewardTotalDuration ?
    //         REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
    //         REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
    //     );
    //     debugLog("expectedStakingRewards: expectedStakingRewards_ = ", expectedStakingRewards_);
    //     return expectedStakingRewards_;
    // }
    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached , uint256 _rewardTotalDuration) public view returns (uint256 expectedRewardsAmount) {
        debugLog("expectedStakingRewards: _stakedAmount = ", _stakedAmount);
        debugLog("expectedStakingRewards: _rewardDurationReached = ", _rewardDurationReached);
        debugLog("expectedStakingRewards: _rewardTotalDuration = ", _rewardTotalDuration);
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
        verboseLog( "expectedStakingRewards: rewardsDuration= ", rewardsDuration );
        uint256 expectedStakingRewardsAmount = CONSTANT_REWARDRATE_PERTOKENSTORED * _stakedAmount / ONE_TOKEN * rewardsDuration;
        verboseLog( "expectedStakingRewards: expectedStakingRewardsAmount= ", expectedStakingRewardsAmount );
        return expectedStakingRewardsAmount;
    }

}
*/

contract StakingSetup is StakingPreSetup {


    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached , uint256 _rewardTotalDuration)
    internal view virtual override returns (uint256 expectedRewardsAmount) {
        debugLog("expectedStakingRewards: _stakedAmount = ", _stakedAmount);
        debugLog("expectedStakingRewards: _rewardDurationReached = ", _rewardDurationReached);
        debugLog("expectedStakingRewards: _rewardTotalDuration = ", _rewardTotalDuration);
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
        verboseLog( "expectedStakingRewards: rewardsDuration= ", rewardsDuration );
        uint256 expectedStakingRewardsAmount = CONSTANT_REWARDRATE_PERTOKENSTORED * _stakedAmount / ONE_TOKEN * rewardsDuration;
        verboseLog( "expectedStakingRewards: expectedStakingRewardsAmount= ", expectedStakingRewardsAmount );
        return expectedStakingRewardsAmount;
    }

}

contract StakingSetup1 is Erc20Setup1, StakingSetup {

    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override {
        // console.log("StakingSetup1 setUp()");
        debugLog("StakingSetup1 setUp() start");
        Erc20Setup1.setUp();
        vm.prank( userStakingRewardAdmin );
        stakingRewards2 = new StakingRewards2( address(rewardErc20), address(stakingERC20) );
        assertEq( userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner" );

        vm.prank( userStakingRewardAdmin );
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), REWARD_INITIAL_AMOUNT );

        vm.prank( userStakingRewardAdmin );
        stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY);

        // TODO : check event MaxTotalSupply(variableRewardMaxTotalSupply;
        // TODO : check event RewardAddedPerTokenStored( _constantRewardRatePerTokenStored );

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup1 setUp() end");
    }

}

// ----------------

contract StakingSetup2 is Erc20Setup2, StakingSetup {

    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override {
        // console.log("StakingSetup2 setUp()");
        debugLog("StakingSetup2 setUp() start");
        Erc20Setup2.setUp();
        vm.prank( userStakingRewardAdmin );
        stakingRewards2 = new StakingRewards2( address(rewardErc20), address(stakingERC20) );
        assertEq( userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner" );

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards2), bytes4(keccak256("setRewardsDuration")) );

        vm.prank( userStakingRewardAdmin );
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);

        // console.log("StakingSetup2 setUp() mint REWARD_INITIAL_AMOUNT to contract", REWARD_INITIAL_AMOUNT);
        rewardErc20.mint( address(stakingRewards2), REWARD_INITIAL_AMOUNT );

        vm.prank( userStakingRewardAdmin );
        stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY);

        // TODO : check event MaxTotalSupply(variableRewardMaxTotalSupply;
        // TODO : check event RewardAddedPerTokenStored( _constantRewardRatePerTokenStored );

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup2 setUp() end");
    }

}

// ----------------

contract StakingSetup3 is Erc20Setup3, StakingSetup {

    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant CHERRY_STAKINGERC20_STAKEDAMOUNT = CHERRY_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override {
        // console.log("StakingSetup3 setUp()");
        debugLog("StakingSetup3 setUp() start");
        Erc20Setup3.setUp();
        vm.prank( userStakingRewardAdmin );
        stakingRewards2 = new StakingRewards2( address(rewardErc20), address(stakingERC20) );
        assertEq( userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner" );

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards2), bytes4(keccak256("setRewardsDuration")) );

        vm.prank( userStakingRewardAdmin );
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), REWARD_INITIAL_AMOUNT );

        vm.prank( userStakingRewardAdmin );
        stakingRewards2.notifyVariableRewardAmount(CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY);

        // TODO : check event MaxTotalSupply(variableRewardMaxTotalSupply;
        // TODO : check event RewardAddedPerTokenStored( _constantRewardRatePerTokenStored );

        // debugLog("Staking start time", stakingStartTime);
        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup3 setUp() end");
    }

}


// ------------------------------------

contract DepositSetup1 is StakingSetup1 {

    // uint256 constant internal TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT;

    function setUp() public virtual override {
        // console.log("DepositSetup1 setUp()");
        debugLog("DepositSetup1 setUp() start");
        verboseLog("DepositSetup1 setUp()");
        StakingSetup1.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve( address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Staked( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards2.stake( ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup1 setUp() end");
    }

}

// ----------------

contract DepositSetup2 is StakingSetup2 {

    function setUp() public virtual override {
        // console.log("DepositSetup2 setUp()");
        debugLog("DepositSetup2 setUp() start");
        verboseLog("DepositSetup2 setUp()");
        StakingSetup2.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve( address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Staked( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards2.stake( ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.startPrank(userBob);
        stakingERC20.approve( address(stakingRewards2), BOB_STAKINGERC20_STAKEDAMOUNT );
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Staked( userBob, BOB_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards2.stake( BOB_STAKINGERC20_STAKEDAMOUNT );
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup2 setUp() end");
    }

}

// ----------------

contract DepositSetup3 is StakingSetup3 {

    function setUp() public virtual override {
        // console.log("DepositSetup3 setUp()");
        debugLog("DepositSetup3 setUp() start");
        verboseLog("DepositSetup3 setUp()");
        StakingSetup3.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve( address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Staked( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards2.stake( ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.startPrank(userBob);
        stakingERC20.approve( address(stakingRewards2), BOB_STAKINGERC20_STAKEDAMOUNT );
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Staked( userBob, BOB_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards2.stake( BOB_STAKINGERC20_STAKEDAMOUNT );
        vm.startPrank(userCherry);
        stakingERC20.approve( address(stakingRewards2), CHERRY_STAKINGERC20_STAKEDAMOUNT );
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Staked( userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards2.stake( CHERRY_STAKINGERC20_STAKEDAMOUNT );
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT
        + BOB_STAKINGERC20_STAKEDAMOUNT + CHERRY_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup3 setUp() end");
    }

}

// ----------------------------------------------------------------------------

contract DuringStaking1_WithoutWithdral is DepositSetup1 {

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithoutWithdral setUp() start");
        DepositSetup1.setUp();
        // console.log("DuringStaking1_WithoutWithdral");
        debugLog("DuringStaking1_WithoutWithdral setUp() end");
    }

    function checkAliceStake() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkUsersStake() public {
        checkAliceStake();
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {

        uint256 stakerRewards = stakingRewards2.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " address = ",  _staker );
        verboseLog( " rewards earned = ",  stakerRewards);
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED , 0, 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION );
        uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION );
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , DELTA_0 );
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0 ); // no delta needed
    }
}

// ------------------------------------

contract DuringStaking2_WithoutWithdral is DepositSetup2 {

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithoutWithdral setUp() start");
        DepositSetup2.setUp();
        // console.log("DuringStaking2_WithoutWithdral");
        debugLog("DuringStaking2_WithoutWithdral setUp() end");
    }

    function checkAliceStake() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkBobStake() public {
        itStakesCorrectly(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob" );
    }
    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {

        uint256 stakerRewards = stakingRewards2.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED , 0, 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION );
        uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION );
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , DELTA_0_31 );
        checkStakingRewards( userBob, "Bob", expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , DELTA_0_31 );
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0 ); // no delta needed
    }
}

// ------------------------------------

contract DuringStaking3_WithoutWithdral is DepositSetup3 {

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithoutWithdral setUp() start");
        DepositSetup3.setUp();
        // console.log("DuringStaking3_WithoutWithdral");
        debugLog("DuringStaking3_WithoutWithdral setUp() end");
    }

    function checkAliceStake() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkBobStake() public {
        itStakesCorrectly(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob" );
    }
    function checkCherryStake() public {
        itStakesCorrectly(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Bob" );
    }
    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {

        uint256 stakerRewards = stakingRewards2.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED , 0, 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION );
        uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION );
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , DELTA_0_4 );
        checkStakingRewards( userBob, "Bob", expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , DELTA_0_31 );
        checkStakingRewards( userCherry, "Cherry", expectedStakingRewards( CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , DELTA_0_31 );
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0 ); // no delta needed
    }
}

// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking1_WithWithdral is DepositSetup1 {

    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithWithdral setUp() start");
        DepositSetup1.setUp();
        // console.log("DuringStaking1_WithWithdral");
        debugLog("DuringStaking1_WithWithdral setUp() end");
    }

    function checkAliceStake() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkUsersStake() public {
        checkAliceStake();
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {
        uint256 stakerRewards = stakingRewards2.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED , 0, 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        checkUsersStake();
        verboseLog( "Staking duration reached (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );

        verboseLog( "Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        // Alice withdraws all
        withdrawStake( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT );

        uint256 usersStakingElapsedTime = block.timestamp - STAKING_START_TIME;
        // uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN; / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        verboseLog( "Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION );

        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , DELTA_0 );

        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0 ); // no delta needed
    }
}

// ------------------------------------
// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking2_WithWithdral is DepositSetup2 {

    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithWithdral setUp() start");
        DepositSetup2.setUp();
        // console.log("DuringStaking2_WithWithdral");
        debugLog("DuringStaking2_WithWithdral setUp() end");
    }

    function checkAliceStake() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkBobStake() public {
        itStakesCorrectly( userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob" );
    }
    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {
        uint256 stakerRewards = stakingRewards2.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED , 0, 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        checkUsersStake();
        verboseLog( "Staking duration reached (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );

        verboseLog( "Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        // Alice withdraws all
        withdrawStake( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT );

        // Bob withdraws all
        withdrawStake( userBob, BOB_STAKINGERC20_STAKEDAMOUNT );

        uint256 usersStakingElapsedTime = block.timestamp - STAKING_START_TIME;
        // uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        verboseLog( "Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION );

        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period = better accuracy : less delta
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );
        checkStakingRewards( userBob, "Bob", expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );

        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0 ); // no delta needed
    }
}

// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking3_WithWithdral is DepositSetup3 {

    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithWithdral setUp() start");
        DepositSetup3.setUp();
        // console.log("DuringStaking3_WithWithdral");
        debugLog("DuringStaking3_WithWithdral setUp() end");
    }

    function checkAliceStake() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkBobStake() public {
        itStakesCorrectly( userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob" );
    }
    function checkCherryStake() public {
        itStakesCorrectly( userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry" );
    }
    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {

        uint256 stakerRewards = stakingRewards2.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED , 0, 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        checkUsersStake();
        verboseLog( "Staking duration reached (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );

        verboseLog( "Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        // Alice withdraws all
        withdrawStake( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT );

        // Bob withdraws all
        withdrawStake( userBob, BOB_STAKINGERC20_STAKEDAMOUNT );
        // Cherry withdraws all
        withdrawStake( userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT );

        uint256 usersStakingElapsedTime = block.timestamp - STAKING_START_TIME;
        // uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) *  ONE_TOKEN; / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        verboseLog( "Staking duration reached (%%) : ", STAKING_PERCENTAGE_DURATION );

        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period = better accuracy : less delta
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );
        checkStakingRewards( userBob, "Bob", expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );
        checkStakingRewards( userCherry, "Cherry", expectedStakingRewards( CHERRY_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );

        checkRewardPerToken( CONSTANT_REWARDRATE_PERTOKENSTORED, 0, 0 ); // no delta needed
    }
}

// ----------------------------------------------------------------------------


// 1 staker deposits right after staking starts and keeps staked amount until the end of staking period
// TODO: test claim rewards
// 22 tests
// /*
contract DuringStaking1_WithoutWithdral_0 is DuringStaking1_WithoutWithdral(0) {
}
contract DuringStaking1_WithoutWithdral_1 is DuringStaking1_WithoutWithdral(PERCENT_1) {
}
contract DuringStaking1_WithoutWithdral_10 is DuringStaking1_WithoutWithdral(PERCENT_10) {
}
contract DuringStaking1_WithoutWithdral_20 is DuringStaking1_WithoutWithdral(PERCENT_20) {
}
contract DuringStaking1_WithoutWithdral_30 is DuringStaking1_WithoutWithdral(PERCENT_30) {
}
contract DuringStaking1_WithoutWithdral_33 is DuringStaking1_WithoutWithdral(PERCENT_33) {
}
contract DuringStaking1_WithoutWithdral_40 is DuringStaking1_WithoutWithdral(PERCENT_40) {
}
contract DuringStaking1_WithoutWithdral_50 is DuringStaking1_WithoutWithdral(PERCENT_50) {
}
contract DuringStaking1_WithoutWithdral_60 is DuringStaking1_WithoutWithdral(PERCENT_60) {
}
contract DuringStaking1_WithoutWithdral_66 is DuringStaking1_WithoutWithdral(PERCENT_66) {
}
contract DuringStaking1_WithoutWithdral_70 is DuringStaking1_WithoutWithdral(PERCENT_70) {
}
contract DuringStaking1_WithoutWithdral_80 is DuringStaking1_WithoutWithdral(PERCENT_80) {
}
contract DuringStaking1_WithoutWithdral_90 is DuringStaking1_WithoutWithdral(PERCENT_90) {
}
contract DuringStaking1_WithoutWithdral_99 is DuringStaking1_WithoutWithdral(PERCENT_99) {
}
contract DuringStaking1_WithoutWithdral_100 is DuringStaking1_WithoutWithdral(PERCENT_100) {
}
contract DuringStaking1_WithoutWithdral_101 is DuringStaking1_WithoutWithdral(PERCENT_101) {
}
contract DuringStaking1_WithoutWithdral_110 is DuringStaking1_WithoutWithdral(PERCENT_110) {
}
contract DuringStaking1_WithoutWithdral_150 is DuringStaking1_WithoutWithdral(PERCENT_150) {
}
contract DuringStaking1_WithoutWithdral_190 is DuringStaking1_WithoutWithdral(PERCENT_190) {
}
contract DuringStaking1_WithoutWithdral_200 is DuringStaking1_WithoutWithdral(PERCENT_200) {
}
contract DuringStaking1_WithoutWithdral_201 is DuringStaking1_WithoutWithdral(PERCENT_201) {
}
contract DuringStaking1_WithoutWithdral_220 is DuringStaking1_WithoutWithdral(PERCENT_220) {
}
// */
// ------------------------------------

// 2 stakers deposit right after staking starts and keep staked amount until the end of staking period
// TODO: test claim rewards
// 22 tests
// /*
contract DuringStaking2_WithoutWithdral_0 is DuringStaking2_WithoutWithdral(0) {
}
contract DuringStaking2_WithoutWithdral_1 is DuringStaking2_WithoutWithdral(PERCENT_1) {
}
contract DuringStaking2_WithoutWithdral_10 is DuringStaking2_WithoutWithdral(PERCENT_10) {
}
contract DuringStaking2_WithoutWithdral_20 is DuringStaking2_WithoutWithdral(PERCENT_20) {
}
contract DuringStaking2_WithoutWithdral_30 is DuringStaking2_WithoutWithdral(PERCENT_30) {
}
contract DuringStaking2_WithoutWithdral_33 is DuringStaking2_WithoutWithdral(PERCENT_33) {
}
contract DuringStaking2_WithoutWithdral_40 is DuringStaking2_WithoutWithdral(PERCENT_40) {
}
contract DuringStaking2_WithoutWithdral_50 is DuringStaking2_WithoutWithdral(PERCENT_50) {
}
contract DuringStaking2_WithoutWithdral_60 is DuringStaking2_WithoutWithdral(PERCENT_60) {
}
contract DuringStaking2_WithoutWithdral_66 is DuringStaking2_WithoutWithdral(PERCENT_66) {
}
contract DuringStaking2_WithoutWithdral_70 is DuringStaking2_WithoutWithdral(PERCENT_70) {
}
contract DuringStaking2_WithoutWithdral_80 is DuringStaking2_WithoutWithdral(PERCENT_80) {
}
contract DuringStaking2_WithoutWithdral_90 is DuringStaking2_WithoutWithdral(PERCENT_90) {
}
contract DuringStaking2_WithoutWithdral_99 is DuringStaking2_WithoutWithdral(PERCENT_99) {
}
contract DuringStaking2_WithoutWithdral_100 is DuringStaking2_WithoutWithdral(PERCENT_100) {
}
contract DuringStaking2_WithoutWithdral_101 is DuringStaking2_WithoutWithdral(PERCENT_101) {
}
contract DuringStaking2_WithoutWithdral_110 is DuringStaking2_WithoutWithdral(PERCENT_110) {
}
contract DuringStaking2_WithoutWithdral_150 is DuringStaking2_WithoutWithdral(PERCENT_150) {
}
contract DuringStaking2_WithoutWithdral_190 is DuringStaking2_WithoutWithdral(PERCENT_190) {
}
contract DuringStaking2_WithoutWithdral_200 is DuringStaking2_WithoutWithdral(PERCENT_200) {
}
contract DuringStaking2_WithoutWithdral_201 is DuringStaking2_WithoutWithdral(PERCENT_201) {
}
contract DuringStaking2_WithoutWithdral_220 is DuringStaking2_WithoutWithdral(PERCENT_220) {
}

// */
// ------------------------------------

// 3 stakers deposit right after staking starts and keep staked amount until the end of staking period
// TODO: test claim rewards
// 22 tests
// contract DuringStaking3_WithoutWithdral_100 is DuringStaking3_WithoutWithdral(PERCENT_100) {
// }

// /*
contract DuringStaking3_WithoutWithdral_0 is DuringStaking3_WithoutWithdral(0) {
}
contract DuringStaking3_WithoutWithdral_1 is DuringStaking3_WithoutWithdral(PERCENT_1) {
}
contract DuringStaking3_WithoutWithdral_10 is DuringStaking3_WithoutWithdral(PERCENT_10) {
}
contract DuringStaking3_WithoutWithdral_20 is DuringStaking3_WithoutWithdral(PERCENT_20) {
}
contract DuringStaking3_WithoutWithdral_30 is DuringStaking3_WithoutWithdral(PERCENT_30) {
}
contract DuringStaking3_WithoutWithdral_33 is DuringStaking3_WithoutWithdral(PERCENT_33) {
}
contract DuringStaking3_WithoutWithdral_40 is DuringStaking3_WithoutWithdral(PERCENT_40) {
}
contract DuringStaking3_WithoutWithdral_50 is DuringStaking3_WithoutWithdral(PERCENT_50) {
}
contract DuringStaking3_WithoutWithdral_60 is DuringStaking3_WithoutWithdral(PERCENT_60) {
}
contract DuringStaking3_WithoutWithdral_66 is DuringStaking3_WithoutWithdral(PERCENT_66) {
}
contract DuringStaking3_WithoutWithdral_70 is DuringStaking3_WithoutWithdral(PERCENT_70) {
}
contract DuringStaking3_WithoutWithdral_80 is DuringStaking3_WithoutWithdral(PERCENT_80) {
}
contract DuringStaking3_WithoutWithdral_90 is DuringStaking3_WithoutWithdral(PERCENT_90) {
}
contract DuringStaking3_WithoutWithdral_99 is DuringStaking3_WithoutWithdral(PERCENT_99) {
}
contract DuringStaking3_WithoutWithdral_100 is DuringStaking3_WithoutWithdral(PERCENT_100) {
}
contract DuringStaking3_WithoutWithdral_101 is DuringStaking3_WithoutWithdral(PERCENT_101) {
}
contract DuringStaking3_WithoutWithdral_110 is DuringStaking3_WithoutWithdral(PERCENT_110) {
}
contract DuringStaking3_WithoutWithdral_190 is DuringStaking3_WithoutWithdral(PERCENT_190) {
}
contract DuringStaking3_WithoutWithdral_150 is DuringStaking3_WithoutWithdral(PERCENT_150) {
}
contract DuringStaking3_WithoutWithdral_200 is DuringStaking3_WithoutWithdral(PERCENT_200) {
}
contract DuringStaking3_WithoutWithdral_201 is DuringStaking3_WithoutWithdral(PERCENT_201) {
}
contract DuringStaking3_WithoutWithdral_220 is DuringStaking3_WithoutWithdral(PERCENT_220) {
}
// */
// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration
// TODO: test claim rewards
// 22 tests
// /*
contract DuringStaking1_WithWithdral0 is DuringStaking1_WithWithdral(0) {
}
contract DuringStaking1_WithWithdral1 is DuringStaking1_WithWithdral(PERCENT_1) {
}
contract DuringStaking1_WithWithdral10 is DuringStaking1_WithWithdral(PERCENT_10) {
}
contract DuringStaking1_WithWithdral20 is DuringStaking1_WithWithdral(PERCENT_20) {
}
contract DuringStaking1_WithWithdral30 is DuringStaking1_WithWithdral(PERCENT_30) {
}
contract DuringStaking1_WithWithdral33 is DuringStaking1_WithWithdral(PERCENT_33) {
}
contract DuringStaking1_WithWithdral40 is DuringStaking1_WithWithdral(PERCENT_40) {
}
contract DuringStaking1_WithWithdral50 is DuringStaking1_WithWithdral(PERCENT_50) {
}
contract DuringStaking1_WithWithdral60 is DuringStaking1_WithWithdral(PERCENT_60) {
}
contract DuringStaking1_WithWithdral66 is DuringStaking1_WithWithdral(PERCENT_66) {
}
contract DuringStaking1_WithWithdral70 is DuringStaking1_WithWithdral(PERCENT_70) {
}
contract DuringStaking1_WithWithdral80 is DuringStaking1_WithWithdral(PERCENT_80) {
}
contract DuringStaking1_WithWithdral90 is DuringStaking1_WithWithdral(PERCENT_90) {
}
contract DuringStaking1_WithWithdral99 is DuringStaking1_WithWithdral(PERCENT_99) {
}
contract DuringStaking1_WithWithdral100 is DuringStaking1_WithWithdral(PERCENT_100) {
}
contract DuringStaking1_WithWithdral101 is DuringStaking1_WithWithdral(PERCENT_101) {
}
contract DuringStaking1_WithWithdral110 is DuringStaking1_WithWithdral(PERCENT_110) {
}
contract DuringStaking1_WithWithdral150 is DuringStaking1_WithWithdral(PERCENT_150) {
}
contract DuringStaking1_WithWithdral190 is DuringStaking1_WithWithdral(PERCENT_190) {
}
contract DuringStaking1_WithWithdral200 is DuringStaking1_WithWithdral(PERCENT_200) {
}
contract DuringStaking1_WithWithdral201 is DuringStaking1_WithWithdral(PERCENT_201) {
}
contract DuringStaking1_WithWithdral220 is DuringStaking1_WithWithdral(PERCENT_220) {
}
// */
// ------------------------------------

// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage duration
// TODO: test claim rewards
// 22 tests
// /*
contract DuringStaking2_WithWithdral0 is DuringStaking2_WithWithdral(0) {
}
contract DuringStaking2_WithWithdral1 is DuringStaking2_WithWithdral(PERCENT_1) {
}
contract DuringStaking2_WithWithdral10 is DuringStaking2_WithWithdral(PERCENT_10) {
}
contract DuringStaking2_WithWithdral20 is DuringStaking2_WithWithdral(PERCENT_20) {
}
contract DuringStaking2_WithWithdral30 is DuringStaking2_WithWithdral(PERCENT_30) {
}
contract DuringStaking2_WithWithdral33 is DuringStaking2_WithWithdral(PERCENT_33) {
}
contract DuringStaking2_WithWithdral40 is DuringStaking2_WithWithdral(PERCENT_40) {
}
contract DuringStaking2_WithWithdral50 is DuringStaking2_WithWithdral(PERCENT_50) {
}
contract DuringStaking2_WithWithdral60 is DuringStaking2_WithWithdral(PERCENT_60) {
}
contract DuringStaking2_WithWithdral66 is DuringStaking2_WithWithdral(PERCENT_66) {
}
contract DuringStaking2_WithWithdral70 is DuringStaking2_WithWithdral(PERCENT_70) {
}
contract DuringStaking2_WithWithdral80 is DuringStaking2_WithWithdral(PERCENT_80) {
}
contract DuringStaking2_WithWithdral90 is DuringStaking2_WithWithdral(PERCENT_90) {
}
contract DuringStaking2_WithWithdral99 is DuringStaking2_WithWithdral(PERCENT_99) {
}
contract DuringStaking2_WithWithdral100 is DuringStaking2_WithWithdral(PERCENT_100) {
}
contract DuringStaking2_WithWithdral101 is DuringStaking2_WithWithdral(PERCENT_101) {
}
contract DuringStaking2_WithWithdral110 is DuringStaking2_WithWithdral(PERCENT_110) {
}
contract DuringStaking2_WithWithdral150 is DuringStaking2_WithWithdral(PERCENT_150) {
}
contract DuringStaking2_WithWithdral190 is DuringStaking2_WithWithdral(PERCENT_190) {
}
contract DuringStaking2_WithWithdral200 is DuringStaking2_WithWithdral(PERCENT_200) {
}
contract DuringStaking2_WithWithdral201 is DuringStaking2_WithWithdral(PERCENT_201) {
}
contract DuringStaking2_WithWithdral220 is DuringStaking2_WithWithdral(PERCENT_220) {
}
// */
// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage duration
// TODO: test claim rewards
// 22 tests

// /*
contract DuringStaking3_WithWithdral0 is DuringStaking3_WithWithdral(0) {
}
contract DuringStaking3_WithWithdral1 is DuringStaking3_WithWithdral(PERCENT_1) {
}
contract DuringStaking3_WithWithdral10 is DuringStaking3_WithWithdral(PERCENT_10) {
}
contract DuringStaking3_WithWithdral20 is DuringStaking3_WithWithdral(PERCENT_20) {
}
contract DuringStaking3_WithWithdral30 is DuringStaking3_WithWithdral(PERCENT_30) {
}
contract DuringStaking3_WithWithdral33 is DuringStaking3_WithWithdral(PERCENT_33) {
}
contract DuringStaking3_WithWithdral40 is DuringStaking3_WithWithdral(PERCENT_40) {
}
contract DuringStaking3_WithWithdral50 is DuringStaking3_WithWithdral(PERCENT_50) {
}
contract DuringStaking3_WithWithdral60 is DuringStaking3_WithWithdral(PERCENT_60) {
}
contract DuringStaking3_WithWithdral66 is DuringStaking3_WithWithdral(PERCENT_66) {
}
contract DuringStaking3_WithWithdral70 is DuringStaking3_WithWithdral(PERCENT_70) {
}
contract DuringStaking3_WithWithdral80 is DuringStaking3_WithWithdral(PERCENT_80) {
}
contract DuringStaking3_WithWithdral90 is DuringStaking3_WithWithdral(PERCENT_90) {
}
contract DuringStaking3_WithWithdral99 is DuringStaking3_WithWithdral(PERCENT_99) {
}
contract DuringStaking3_WithWithdral100 is DuringStaking3_WithWithdral(PERCENT_100) {
}
contract DuringStaking3_WithWithdral101 is DuringStaking3_WithWithdral(PERCENT_101) {
}
contract DuringStaking3_WithWithdral110 is DuringStaking3_WithWithdral(PERCENT_110) {
}
contract DuringStaking3_WithWithdral150 is DuringStaking3_WithWithdral(PERCENT_150) {
}
contract DuringStaking3_WithWithdral190 is DuringStaking3_WithWithdral(PERCENT_190) {
}
contract DuringStaking3_WithWithdral200 is DuringStaking3_WithWithdral(PERCENT_200) {
}
contract DuringStaking3_WithWithdral201 is DuringStaking3_WithWithdral(PERCENT_201) {
}
contract DuringStaking3_WithWithdral220 is DuringStaking3_WithWithdral(PERCENT_220) {
}
// */
// --------------------------------------------------------

// Permissions tests

// 8 tests

// /*
contract CheckStakingPermissions2 is StakingSetup2 {

    function setUp() public virtual override {
        // console.log("CheckStakingPermissions2 setUp()");
        debugLog("CheckStakingPermissions2 setUp() start");
        StakingSetup2.setUp();
        debugLog("CheckStakingPermissions2 setUp() end");
    }


    // TODO: Check staking MAX amount

    function testStakingPause() public {

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );
        verboseLog( "Only staking reward contract owner can pause" );

        stakingRewards2.setPaused(true);
        assertEq( stakingRewards2.paused(), false );
        verboseLog( "Staking contract: Alice can't pause" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );

        stakingRewards2.setPaused(true);
        assertEq( stakingRewards2.paused(), false );
        verboseLog( "Staking contract: Bob can't pause" );

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit Pausable.Paused(userStakingRewardAdmin);
        stakingRewards2.setPaused(true);
        assertEq( stakingRewards2.paused(), true );
        verboseLog( "Staking contract: Only owner can pause" );
        verboseLog( "Staking contract: Event Paused emitted" );

        // Pausing again should not throw nor emit event and leave pause unchanged
        stakingRewards2.setPaused(true);
        // Check no event emitted ?
        assertEq( stakingRewards2.paused(), true );
        vm.stopPrank();

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );
        verboseLog( "Only staking reward contract owner can unpause" );

        stakingRewards2.setPaused(false);
        assertEq( stakingRewards2.paused(), true );
        verboseLog( "Staking contract: Alice can't unpause" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );

        stakingRewards2.setPaused(false);
        assertEq( stakingRewards2.paused(), true );
        verboseLog( "Staking contract: Bob can't unpause" );

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit Pausable.Unpaused(userStakingRewardAdmin);
        stakingRewards2.setPaused(false);
        assertEq( stakingRewards2.paused(), false );

        verboseLog( "Staking contract: Only owner can unpause" );
        verboseLog( "Staking contract: Event Unpaused emitted" );

        // Unausing again should not throw nor emit event and leave pause unchanged
        stakingRewards2.setPaused(false);
        // Check no event emitted ?
        assertEq( stakingRewards2.paused(), false );

        vm.stopPrank();
    }

    function testStakingnotifyVariableRewardAmountMin() public {

        verboseLog( "Only staking reward contract owner can notifyVariableRewardAmount" );

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );

        stakingRewards2.notifyVariableRewardAmount( 1, 1 );
        verboseLog( "Staking contract: Alice can't notifyVariableRewardAmount" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );
        stakingRewards2.notifyVariableRewardAmount( 1, 1 );
        verboseLog( "Staking contract: Bob can't notifyVariableRewardAmount" );

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.MaxTotalSupply( 1 );
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardAddedPerTokenStored( 1 );
        stakingRewards2.notifyVariableRewardAmount( 1, 1 );
        verboseLog( "Staking contract: Only owner can notifyVariableRewardAmount of ", 1 );
        verboseLog( "Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted" );
    }

    function testStakingNotifyVariableRewardAmount0() public {

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.MaxTotalSupply( 1 );
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardAddedPerTokenStored( 0 );
        stakingRewards2.notifyVariableRewardAmount( 0, 0 );
        verboseLog( "Staking contract: Only owner can notifyVariableRewardAmount of ", 0 );
        verboseLog( "Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted" );
    }

    function testStakingNotifyVariableRewardAmount() public {

        // vm.prank(erc20Minter);
        // rewardErc20.mint( address(stakingRewards2), REWARD_INITIAL_AMOUNT );

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );
        verboseLog( "Only staking reward contract owner can notifyVariableRewardAmount" );

        stakingRewards2.notifyVariableRewardAmount( 1, 1 );
        verboseLog( "Staking contract: Alice can't notifyVariableRewardAmount" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );
        stakingRewards2.notifyVariableRewardAmount( 1, 1 );
        verboseLog( "Staking contract: Bob can't notifyVariableRewardAmount" );

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.MaxTotalSupply( VARIABLE_REWARD_MAXTOTALSUPPLY );
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardAddedPerTokenStored( CONSTANT_REWARDRATE_PERTOKENSTORED );
        stakingRewards2.notifyVariableRewardAmount( 1, 1 );
        verboseLog( "Staking contract: Only owner can notifyVariableRewardAmount" );
        verboseLog( "Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted" );
    }

    function testStakingnotifyVariableRewardAmountLimit1() public {

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.MaxTotalSupply( VARIABLE_REWARD_MAXTOTALSUPPLY );
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardAddedPerTokenStored( CONSTANT_REWARDRATE_PERTOKENSTORED );
        stakingRewards2.notifyVariableRewardAmount( CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY  );
        verboseLog( "Staking contract: Only owner can notifyVariableRewardAmount of ", CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY );
        verboseLog( "Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted" );
    }

    function testStakingnotifyVariableRewardAmountFail() public {

        vm.prank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector( IStakingRewards2Errors.ProvidedVariableRewardTooHigh.selector, CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY + 1, REWARD_INITIAL_AMOUNT )
        );
        stakingRewards2.notifyVariableRewardAmount( CONSTANT_REWARDRATE_PERTOKENSTORED, VARIABLE_REWARD_MAXTOTALSUPPLY + 1 );

        verboseLog( "Staking contract: Only owner can notifyVariableRewardAmount of ", CONSTANT_REWARDRATE_PERTOKENSTORED * VARIABLE_REWARD_MAXTOTALSUPPLY );
        verboseLog( "Staking contract: Events MaxTotalSupply, RewardAddedPerTokenStored emitted" );
    }

    function testStakingSetRewardsDuration() public {

        // Previous reward epoch must have ended before setting a new duration
        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );
        verboseLog( "Only staking reward contract owner can notifyVariableRewardAmount" );

        stakingRewards2.setRewardsDuration( 1 );
        verboseLog( "Staking contract: Alice can't setRewardsDuration" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );

        stakingRewards2.setRewardsDuration( 1 );
        verboseLog( "Staking contract: Bob can't setRewardsDuration" );

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardsDurationUpdated( 1 );
        stakingRewards2.setRewardsDuration( 1 );
        verboseLog( "Staking contract: Only owner can setRewardsDuration" );
        verboseLog( "Staking contract: Event RewardsDurationUpdated emitted" );
    }

    function testStakingSetRewardsDurationBeforeEpochEnd() public {

        // Previous reward epoch must have ended before setting a new duration
        vm.startPrank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                IStakingRewards2Errors.RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIME + REWARD_INITIAL_DURATION )
        );
        // vm.expectRevert( bytes(_MMPOR000) );
        stakingRewards2.setRewardsDuration( 1 );

        // Previous reward epoch must have ended before setting a new duration
        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        vm.expectRevert(
            abi.encodeWithSelector(
                IStakingRewards2Errors.RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIME + REWARD_INITIAL_DURATION )
        );
        stakingRewards2.setRewardsDuration( 1 );

        verboseLog( "Staking contract: Owner can't setRewardsDuration before previous epoch end" );
        vm.stopPrank();
    }

}
// */
