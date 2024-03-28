// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { console } from "forge-std/src/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";
import { stdMath } from "forge-std/src/StdMath.sol";

import { Utils } from "./utils/Utils.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";

import { IERC20 } from "../src/contracts/Uniswap/v2-core/interfaces/IERC20.sol";

import { RewardERC20 } from "./contracts/RewardERC20.sol";
import { StakingERC20 } from "./contracts/StakingERC20.sol";

import "./TestsConstants.sol";

// TODO : move to utils
contract TestLog is Test {
    bool debug = false;
    bool verbose = false;
    Utils internal utils;

    function debugLog(string memory _msg) public view {
        if (debug) console.log(_msg);
    }

    function debugLog(string memory _msg1, string memory _msg2) public view {
        if (debug) console.log(_msg1, _msg2);
    }

    function debugLog(string memory _msg, uint256 _val256) public view {
        if (debug) console.log(_msg, _val256);
    }

    function debugLog(string memory _msg, address _address) public view {
        if (debug) console.log(_msg, _address);
    }

    function debugLogTime(string memory _msg1, string memory _msg2) public view {
        if (debug) console.log(_msg1, _msg2, " ts: ", block.timestamp);
    }

    function debugLogTime(string memory _msg) public view {
        if (debug) console.log(_msg, " ts: ", block.timestamp);
    }

    function debugLogTime(string memory _msg, uint256 _val256) public view {
        if (debug) console.log(_msg, _val256, " ts: ", block.timestamp);
    }

    function debugLogTime(string memory _msg, address _address) public view {
        if (debug) console.log(_msg, _address, " ts: ", block.timestamp);
    }

    function verboseLog(string memory _msg1, string memory _msg2) public view {
        if (verbose) console.log(_msg1, _msg2);
    }

    function verboseLog(string memory _msg) public view {
        if (verbose) console.log(_msg);
    }

    function verboseLog(string memory _msg, uint256 _val256) public view {
        if (verbose) console.log(_msg, _val256);
    }

    function verboseLog(string memory _msg, address _address) public view {
        if (verbose) console.log(_msg, _address);
    }

    function verboseLogTime(string memory _msg1, string memory _msg2) public view {
        if (verbose) console.log(_msg1, _msg2, " ts: ", block.timestamp);
    }

    function verboseLogTime(string memory _msg) public view {
        if (verbose) console.log(_msg, " ts: ", block.timestamp);
    }

    function verboseLogTime(string memory _msg, uint256 _val256) public view {
        if (verbose) console.log(_msg, _val256, " ts: ", block.timestamp);
    }

    function verboseLogTime(string memory _msg, address _address) public view {
        if (verbose) console.log(_msg, _address, " ts: ", block.timestamp);
    }
}

// ----------------

contract UsersSetup1 is TestLog {
    address payable[] internal users;

    address internal erc20Admin;
    address internal erc20Minter;
    address internal userStakingRewardAdmin;

    address internal userAlice;

    function setUp() public virtual {
        verboseLog("UsersSetup1 setUp()");
        debugLog("UsersSetup1 setUp() start");
        utils = new Utils();
        users = utils.createUsers(5);

        erc20Admin = users[0];
        vm.label(erc20Admin, "ERC20Admin");
        erc20Minter = users[1];
        vm.label(erc20Minter, "ERC20Minter");
        userStakingRewardAdmin = users[2];
        vm.label(userStakingRewardAdmin, "StakingRewardAdmin");

        userAlice = users[3];
        vm.label(userAlice, "Alice");
        debugLog("UsersSetup1 setUp() end");
    }
}

contract UsersSetup2 is TestLog {
    address payable[] internal users;

    address internal erc20Admin;
    address internal erc20Minter;
    address internal userStakingRewardAdmin;

    address internal userAlice;
    address internal userBob;

    function setUp() public virtual {
        verboseLog("UsersSetup2 setUp()");
        debugLog("UsersSetup2 setUp() start");
        utils = new Utils();
        users = utils.createUsers(5);

        erc20Admin = users[0];
        vm.label(erc20Admin, "ERC20Admin");
        erc20Minter = users[1];
        vm.label(erc20Minter, "ERC20Minter");
        userStakingRewardAdmin = users[2];
        vm.label(userStakingRewardAdmin, "StakingRewardAdmin");

        userAlice = users[3];
        vm.label(userAlice, "Alice");
        userBob = users[4];
        vm.label(userBob, "Bob");
        debugLog("UsersSetup2 setUp() end");
    }
}

// ----------------

contract UsersSetup3 is TestLog {
    address payable[] internal users;

    address internal erc20Admin;
    address internal erc20Minter;
    address internal userStakingRewardAdmin;

    address internal userAlice;
    address internal userBob;
    address internal userCherry;

    function setUp() public virtual {
        verboseLog("UsersSetup3 setUp()");
        debugLog("UsersSetup3 setUp() start");
        utils = new Utils();
        users = utils.createUsers(6);

        erc20Admin = users[0];
        vm.label(erc20Admin, "ERC20Admin");
        erc20Minter = users[1];
        vm.label(erc20Minter, "ERC20Minter");
        userStakingRewardAdmin = users[2];
        vm.label(userStakingRewardAdmin, "StakingRewardAdmin");

        userAlice = users[3];
        vm.label(userAlice, "Alice");
        userBob = users[4];
        vm.label(userBob, "Bob");
        userCherry = users[5];
        vm.label(userCherry, "Cherry");

        debugLog("UsersSetup3 setUp() end");
    }
}

// ------------------------------------

contract Erc20Setup1 is UsersSetup1 {
    RewardERC20 internal rewardErc20;
    StakingERC20 internal stakingERC20;
    uint256 constant ALICE_STAKINGERC20_MINTEDAMOUNT = 2 * ONE_TOKEN;

    function setUp() public virtual override {
        debugLog("Erc20Setup1 setUp() start");
        UsersSetup1.setUp();
        verboseLog("Erc20Setup1 setUp()");
        vm.startPrank(erc20Minter);
        rewardErc20 = new RewardERC20(erc20Admin, erc20Minter, "TestReward", "TSTRWD");
        stakingERC20 = new StakingERC20(erc20Admin, erc20Minter, "Uniswap V2 Staking", "UNI-V2 Staking");
        stakingERC20.mint(userAlice, ALICE_STAKINGERC20_MINTEDAMOUNT);
        vm.stopPrank();
        debugLog("Erc20Setup1 setUp() end");
    }
}

contract Erc20Setup2 is UsersSetup2 {
    RewardERC20 internal rewardErc20;
    StakingERC20 internal stakingERC20;
    uint256 constant ALICE_STAKINGERC20_MINTEDAMOUNT = 2 * ONE_TOKEN;
    uint256 constant BOB_STAKINGERC20_MINTEDAMOUNT = 1 * ONE_TOKEN;

    function setUp() public virtual override {
        debugLog("Erc20Setup2 setUp() start");
        UsersSetup2.setUp();
        verboseLog("Erc20Setup2 setUp()");
        vm.startPrank(erc20Minter);
        rewardErc20 = new RewardERC20(erc20Admin, erc20Minter, "TestReward", "TSTRWD");
        stakingERC20 = new StakingERC20(erc20Admin, erc20Minter, "Uniswap V2 Staking", "UNI-V2 Staking");
        stakingERC20.mint(userAlice, ALICE_STAKINGERC20_MINTEDAMOUNT);
        stakingERC20.mint(userBob, BOB_STAKINGERC20_MINTEDAMOUNT);
        vm.stopPrank();
        debugLog("Erc20Setup2 setUp() end");
    }
}

contract Erc20Setup3 is UsersSetup3 {
    RewardERC20 internal rewardErc20;
    StakingERC20 internal stakingERC20;
    uint256 constant ALICE_STAKINGERC20_MINTEDAMOUNT = 3 * ONE_TOKEN;
    uint256 constant BOB_STAKINGERC20_MINTEDAMOUNT = 2 * ONE_TOKEN;
    uint256 constant CHERRY_STAKINGERC20_MINTEDAMOUNT = 1 * ONE_TOKEN;

    function setUp() public virtual override {
        debugLog("Erc20Setup3 setUp() start");
        UsersSetup3.setUp();
        verboseLog("Erc20Setup3 setUp()");
        vm.startPrank(erc20Minter);
        rewardErc20 = new RewardERC20(erc20Admin, erc20Minter, "TestReward", "TSTRWD");
        stakingERC20 = new StakingERC20(erc20Admin, erc20Minter, "Uniswap V2 Staking", "UNI-V2 Staking");
        stakingERC20.mint(userAlice, ALICE_STAKINGERC20_MINTEDAMOUNT);
        stakingERC20.mint(userBob, BOB_STAKINGERC20_MINTEDAMOUNT);
        stakingERC20.mint(userCherry, CHERRY_STAKINGERC20_MINTEDAMOUNT);
        vm.stopPrank();
        debugLog("Erc20Setup3 setUp() end");
    }
}

// --------------------------------------------------------

abstract contract StakingPreSetup0 is TestLog {
    // Rewards constants

    // Duration of the rewards program
    uint256 internal constant REWARD_INITIAL_DURATION = 10_000; // 10e4 ; 10 000 s. = 2 h. 46 m. 40 s.

    uint256 internal REWARD_INITIAL_AMOUNT;

    function expectedStakingRewards(
        uint256 _stakedAmount,
        uint256 _rewardDurationReached,
        uint256 _rewardTotalDuration
    )
        internal
        view
        virtual
        returns (uint256 expectedRewardsAmount);
}

abstract contract StakingPreSetup is /* TestLog, */ StakingPreSetup0 {
    StakingRewards2 internal stakingRewards2;
    uint256 immutable STAKING_START_TIME = block.timestamp;

    uint256 /* constant */ internal TOTAL_STAKED_AMOUNT;
    uint256 /* immutable */ STAKING_PERCENTAGE_DURATION;
    uint256 /* immutable */ CLAIM_PERCENTAGE_DURATION;

    function checkStakingTotalSupplyStaked() internal {
        debugLog("checkStakingTotalSupplyStaked");
        uint256 stakingRewardsTotalSupply = stakingRewards2.totalSupply();
        debugLog("checkStakingTotalSupplyStaked: stakingRewardsTotalSupply = ", stakingRewardsTotalSupply);
        assertEq(TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply);
    }

    function getRewardDurationReached() internal view returns (uint256) {
        debugLog("getRewardDurationReached");
        uint256 rewardDurationReached = (
            STAKING_PERCENTAGE_DURATION >= PERCENT_100
                ? REWARD_INITIAL_DURATION
                : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100
        );
        verboseLog("getRewardDurationReached: rewardDurationReached = ", rewardDurationReached);
        return rewardDurationReached;
    }

    function getRewardDurationReached(uint256 _durationReached) internal view /* pure */ returns (uint256) {
        debugLog("getRewardDurationReached: ", _durationReached);
        uint256 rewardDurationReached =
            (_durationReached >= REWARD_INITIAL_DURATION ? REWARD_INITIAL_DURATION : _durationReached);
        debugLog("getRewardDurationReached: rewardDurationReached = ", rewardDurationReached);
        return rewardDurationReached;
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) internal {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq(_stakeAmount, userStakedBalance);
    }

    function checkRewardPerToken(
        uint256 _expectedRewardPerToken,
        uint256 _percentDelta,
        uint8 _unitsDelta
    )
        internal
    {
        debugLog("checkRewardPerToken: _expectedRewardPerToken = ", _expectedRewardPerToken);
        uint256 stakingRewardsRewardPerToken = stakingRewards2.rewardPerToken();
        if (stakingRewardsRewardPerToken != _expectedRewardPerToken) {
            debugLog("checkRewardPerToken: stakingRewardsRewardPerToken = ", stakingRewardsRewardPerToken);
            if (_expectedRewardPerToken == 0) {
                fail(
                    "StakingPreSetup0: checkRewardPerToken: stakingReward != expected && _expectedRewardPerToken == 0"
                );
            }
            uint256 percentDelta = stdMath.percentDelta(stakingRewardsRewardPerToken, _expectedRewardPerToken);

            debugLog("checkRewardPerToken: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("checkRewardPerToken: _unitsDelta = ", _unitsDelta);
                    assertApproxEqAbs(stakingRewardsRewardPerToken, _expectedRewardPerToken, _unitsDelta);
                } else {
                    if (_percentDelta == 0) {
                        assertEq(stakingRewardsRewardPerToken, _expectedRewardPerToken);
                    } else {
                        assertApproxEqRel(stakingRewardsRewardPerToken, _expectedRewardPerToken, _percentDelta);
                    }
                }
            }
        }
    }

    function getClaimPercentDelta() internal view returns (uint256) {
        // Longer staking period = better accuracy : less delta
        uint256 claimDelta = CLAIM_PERCENTAGE_DURATION <= PERCENT_10
            ? (CLAIM_PERCENTAGE_DURATION <= PERCENT_1 ? DELTA_5 : DELTA_0_4)
            : DELTA_0_015;
        verboseLog("claimDelta : ", claimDelta);
        return claimDelta;
    }

    function getRewardPercentDelta() public view returns (uint256) {
        verboseLog("getRewardPercentDelta");
        // Longer staking period = better accuracy : less delta
        uint256 rewardsPercentDelta = CLAIM_PERCENTAGE_DURATION > PERCENT_90
            ? (CLAIM_PERCENTAGE_DURATION > PERCENT_95 ? DELTA_5 : DELTA_0_5)
            : STAKING_PERCENTAGE_DURATION <= PERCENT_10
                ? STAKING_PERCENTAGE_DURATION <= PERCENT_5
                    ? STAKING_PERCENTAGE_DURATION <= PERCENT_1 ? DELTA_0_5 : DELTA_5
                    : DELTA_0_08
                : DELTA_0_015;

        verboseLog("getRewardDelta = ", rewardsPercentDelta);
        return rewardsPercentDelta;
    }

    function getRewardUnitsDelta() public pure returns (uint8) {
        // Longer staking period = better accuracy : less delta
        return 1;
    }

    function checkStakingRewards(
        address _staker,
        string memory _stakerName,
        uint256 _expectedRewardAmount,
        uint256 _percentDelta,
        uint8 _unitsDelta
    )
        internal
    {
        debugLog("checkStakingRewards: _stakerName : ", _stakerName);
        debugLog("checkStakingRewards: _expectedRewardAmount : ", _expectedRewardAmount);
        debugLog("checkStakingRewards: _percentDelta : ", _percentDelta);
        uint256 stakerRewards = stakingRewards2.earned(_staker);
        debugLog("checkStakingRewards: stakerRewards = ", stakerRewards);

        if (stakerRewards != _expectedRewardAmount) {
            debugLog("stakerRewards != _expectedRewardAmount");
            if (_expectedRewardAmount == 0) {
                fail("StakingSetup: checkStakingRewards: rewards != _expected && _expectedRewardAmount == 0");
            }
            uint256 percentDelta = stdMath.percentDelta(stakerRewards, _expectedRewardAmount);
            debugLog("checkStakingRewards: delta = ", percentDelta);
            if (percentDelta > _percentDelta) {
                if (_unitsDelta > 0) {
                    debugLog("checkStakingRewards: _unitsDelta = ", _unitsDelta);
                    debugLog("checkStakingRewards: assertApproxEqAbs stakerRewards= ", stakerRewards);
                    debugLog("checkStakingRewards: assertApproxEqAbs _expectedRewardAmount= ", _expectedRewardAmount);
                    debugLog("checkStakingRewards: assertApproxEqAbs stakerRewards= ", _unitsDelta);
                    assertApproxEqAbs(stakerRewards, _expectedRewardAmount, _unitsDelta);
                } else {
                    debugLog("checkStakingRewards: 1");
                    if (_percentDelta == 0) {
                        debugLog("checkStakingRewards: 2");
                        assertEq(stakerRewards, _expectedRewardAmount);
                    } else {
                        debugLog("checkStakingRewards: 3");
                        assertApproxEqRel(stakerRewards, _expectedRewardAmount, _percentDelta);
                    }
                }
            }
        }
        debugLog("checkStakingRewards: 4");
        verboseLog(_stakerName);
        verboseLog(" rewards: ", stakerRewards);
    }

    function checkUserClaim(
        address _user,
        uint256 _stakeAmount,
        string memory _userName,
        uint256 _delta,
        RewardERC20 rewardErc20
    )
        internal
        returns (uint256 claimedRewards_)
    {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog("checkUserClaim:");
            verboseLog("_userName:", _userName);
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
            debugLog("stakingElapsedTime = ", stakingElapsedTime);
            uint256 rewardErc20UserBalance = rewardErc20.balanceOf(_user);
            verboseLog("CLAIM: before: user reward balance = ", rewardErc20UserBalance);
            uint256 expectedRewards =
                expectedStakingRewards(_stakeAmount, stakingElapsedTime, REWARD_INITIAL_DURATION);
            vm.prank(_user);
            vm.expectEmit(true, true, false, false, address(stakingRewards2));
            emit StakingRewards2.RewardPaid(_user, expectedRewards);
            stakingRewards2.getReward();
            // Check user rewards balance before/after claim
            uint256 rewardErc20UserBalanceAfterClaim = rewardErc20.balanceOf(_user);
            claimedRewards_ = rewardErc20UserBalanceAfterClaim - rewardErc20UserBalance;
            verboseLog("CLAIM: after: user reward balance = ", rewardErc20UserBalanceAfterClaim);
            if (_delta == 0) {
                assertEq(expectedRewards, claimedRewards_);
            } else {
                assertApproxEqRel(expectedRewards, claimedRewards_, _delta);
            }
        }
    }

    function checkRewardForDuration() internal {
        debugLog("checkRewardForDuration");
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards2.getRewardForDuration();
        debugLog("checkRewardForDuration: getRewardForDuration = ", stakingRewards2.getRewardForDuration());
        assertEq(rewardForDuration, REWARD_INITIAL_AMOUNT);

        vm.warp(STAKING_START_TIME + REWARD_INITIAL_DURATION); // epoch last time reward
        rewardForDuration = stakingRewards2.getRewardForDuration();
        assertEq(rewardForDuration, REWARD_INITIAL_AMOUNT);

        vm.warp(STAKING_START_TIME + REWARD_INITIAL_DURATION + 1); // epoch ended
        rewardForDuration = stakingRewards2.getRewardForDuration();
        assertEq(rewardForDuration, REWARD_INITIAL_AMOUNT);

        verboseLog("Staking contract: rewardsDuration ok");
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) internal {
        debugLog("checkStakingPeriod: _stakingPercentageDurationReached : ", _stakingPercentageDurationReached);
        assertTrue(
            _stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION,
            "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"
        );
        uint256 stakingTimeReached = STAKING_START_TIME
            + (
                _stakingPercentageDurationReached >= PERCENT_100
                    ? REWARD_INITIAL_DURATION
                    : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100
            );
        debugLog("checkStakingPeriod: stakingTimeReached = ", stakingTimeReached);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        debugLog("checkStakingPeriod: lastTimeReward = ", lastTimeReward);
        assertEq(block.timestamp, stakingTimeReached, "Wrong block.timestamp");
        assertEq(lastTimeReward, stakingTimeReached, "Wrong lastTimeReward");
    }

    function withdrawStake(address _user, uint256 _amount) public {
        debugLog("withdrawStake: _user : ", _user);
        debugLog("withdrawStake: _amount : ", _amount);
        uint256 balanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_user);
        debugLog("withdrawStake: balanceOfUserBeforeWithdrawal = ", balanceOfUserBeforeWithdrawal);
        // Check emitted event
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2.Withdrawn(_user, _amount);
        vm.prank(_user);
        stakingRewards2.withdraw(_amount);
        uint256 balanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_user);
        debugLog("withdrawStake: balanceOfUserBeforeWithdrawal = ", balanceOfUserBeforeWithdrawal);
        assertEq(balanceOfUserBeforeWithdrawal - _amount, balanceOfUserAfterWithdrawal);
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) internal returns (uint256) {
        debugLog("gotoStakingPeriod: _stakingPercentageDurationReached : ", _stakingPercentageDurationReached);
        assertTrue(
            _stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION,
            "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"
        );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME
            + (
                _stakingPercentageDurationReached >= PERCENT_100
                    ? REWARD_INITIAL_DURATION
                    : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100
            );
        verboseLog("gotoStakingPeriod: gotoStakingPeriodResult = ", gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        debugLog("getStakingTimeReached");
        uint256 rewardDurationReached = getRewardDurationReached();
        debugLog("getStakingTimeReached: rewardDurationReached : ", rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    function getStakingDuration() internal view returns (uint256) {
        debugLog("getStakingDuration");
        uint256 stakingDuration = REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100;
        verboseLog("getStakingDuration: stakingDuration = ", stakingDuration);
        return stakingDuration;
    }

    function getRewardedStakingDuration(uint8 _divide) internal view returns (uint256) {
        debugLog("getRewardedStakingDuration: _divide : ", _divide);
        uint256 stakingDuration = getStakingDuration() / _divide;
        debugLog("getRewardedStakingDuration: stakingDuration = ", stakingDuration);
        uint256 rewardedStakingDuration = getRewardDurationReached(stakingDuration);
        verboseLog("getRewardedStakingDuration: rewardedStakingDuration = ", rewardedStakingDuration);
        return rewardedStakingDuration;
    }
}
