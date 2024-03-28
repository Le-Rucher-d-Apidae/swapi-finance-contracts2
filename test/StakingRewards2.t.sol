// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { console } from "forge-std/src/console.sol";
import { stdMath } from "forge-std/src/StdMath.sol";

import "./StakingRewards2_base.t.sol";

import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import { IStakingRewards2Errors } from "../src/contracts/IStakingRewards2Errors.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";

// ----------------

abstract contract StakingPreSetupCRR is StakingPreSetup {
    // Rewards constants

    // Duration of the rewards program
    // see StakingPreSetup0

    function setUp() public virtual /* override */ {
        debugLog("StakingPreSetupCRR setUp() start");

        // Constant reward amount allocated to the staking program during the reward duration
        // Same reward amount is distributed at each block
        // Stakers will share the reward budget based on their staked amount
        REWARD_INITIAL_AMOUNT = 100_000; // 10e5

        verboseLog("StakingPreSetupCRR setUp()");
        debugLog("StakingPreSetupCRR setUp() end");
    }
}

contract StakingSetup is StakingPreSetupCRR {
    function setUp() public virtual override {
        debugLog("StakingSetup setUp() start");
        StakingPreSetupCRR.setUp();
        verboseLog("StakingSetup setUp()");
        debugLog("StakingSetup setUp() end");
    }

    function expectedStakingRewards(
        uint256 _stakedAmount,
        uint256 _rewardDurationReached,
        uint256 _rewardTotalDuration
    )
        internal
        view
        virtual
        override
        returns (uint256 expectedRewardsAmount)
    {
        debugLog("expectedStakingRewards: _stakedAmount = ", _stakedAmount);
        debugLog("expectedStakingRewards: _rewardDurationReached = ", _rewardDurationReached);
        debugLog("expectedStakingRewards: _rewardTotalDuration = ", _rewardTotalDuration);
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
        debugLog("expectedStakingRewards: rewardsDuration = ", rewardsDuration);
        uint256 expectedStakingRewards_ = (
            rewardsDuration == _rewardTotalDuration
                ? REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT
                : REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
        );
        debugLog("expectedStakingRewards: expectedStakingRewards_ = ", expectedStakingRewards_);
        return expectedStakingRewards_;
    }
}

contract StakingSetup1 is Erc20Setup1, StakingSetup {
    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override(Erc20Setup1, StakingSetup) {
        debugLog("StakingSetup1 setUp() start");
        Erc20Setup1.setUp();
        StakingSetup.setUp();
        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        vm.prank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);
        stakingRewards2.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        // TODO : check event RewardAdded(REWARD_INITIAL_AMOUNT;

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup1 setUp() end");
    }

    function checkAliceStake() internal {
        itStakesCorrectly(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice");
    }
}

// ----------------

contract StakingSetup2 is Erc20Setup2, StakingSetup {
    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override(Erc20Setup2, StakingSetup) {
        debugLog("StakingSetup2 setUp() start");
        Erc20Setup2.setUp();
        StakingSetup.setUp();
        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards2),
        // bytes4(keccak256("setRewardsDuration")) );

        vm.prank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);
        stakingRewards2.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        // TODO : check event RewardAdded(REWARD_INITIAL_AMOUNT;

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup2 setUp() end");
    }

    function checkAliceStake() internal {
        itStakesCorrectly(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice");
    }

    function checkBobStake() internal {
        itStakesCorrectly(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob");
    }
}

// ----------------

contract StakingSetup3 is Erc20Setup3, StakingSetup {
    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant CHERRY_STAKINGERC20_STAKEDAMOUNT = CHERRY_STAKINGERC20_MINTEDAMOUNT;

    function setUp() public virtual override(Erc20Setup3, StakingSetup) {
        debugLog("StakingSetup3 setUp() start");
        Erc20Setup3.setUp();
        StakingSetup.setUp();
        vm.prank(userStakingRewardAdmin);
        stakingRewards2 = new StakingRewards2(address(rewardErc20), address(stakingERC20));
        assertEq(userStakingRewardAdmin, stakingRewards2.owner(), "stakingRewards2: Wrong owner");

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards2),
        // bytes4(keccak256("setRewardsDuration")) );

        vm.prank(userStakingRewardAdmin);
        stakingRewards2.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), REWARD_INITIAL_AMOUNT);

        vm.prank(userStakingRewardAdmin);
        stakingRewards2.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        // TODO : check event RewardAdded(REWARD_INITIAL_AMOUNT;

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup3 setUp() end");
    }

    function checkAliceStake() internal {
        itStakesCorrectly(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice");
    }

    function checkBobStake() internal {
        itStakesCorrectly(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob");
    }

    function checkCherryStake() internal {
        itStakesCorrectly(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry");
    }
}

// ------------------------------------

contract DepositSetup1 is StakingSetup1 {
    function setUp() public virtual override {
        debugLog("DepositSetup1 setUp() start");
        StakingSetup1.setUp();
        verboseLog("DepositSetup1 setUp()");
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2.Staked(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup1 setUp() end");
    }
}

// ----------------

contract DepositSetup2 is StakingSetup2 {
    function setUp() public virtual override {
        debugLog("DepositSetup2 setUp() start");
        StakingSetup2.setUp();
        verboseLog("DepositSetup2 setUp()");
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2.Staked(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.startPrank(userBob);
        stakingERC20.approve(address(stakingRewards2), BOB_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2.Staked(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(BOB_STAKINGERC20_STAKEDAMOUNT);
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup2 setUp() end");
    }
}

// ----------------

contract DepositSetup3 is StakingSetup3 {
    function setUp() public virtual override {
        debugLog("DepositSetup3 setUp() start");
        StakingSetup3.setUp();
        verboseLog("DepositSetup3 setUp()");
        vm.startPrank(userAlice);
        stakingERC20.approve(address(stakingRewards2), ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2.Staked(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(ALICE_STAKINGERC20_STAKEDAMOUNT);
        vm.startPrank(userBob);
        stakingERC20.approve(address(stakingRewards2), BOB_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2.Staked(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(BOB_STAKINGERC20_STAKEDAMOUNT);
        vm.startPrank(userCherry);
        stakingERC20.approve(address(stakingRewards2), CHERRY_STAKINGERC20_STAKEDAMOUNT);
        vm.expectEmit(true, true, false, false, address(stakingRewards2));
        emit StakingRewards2.Staked(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT);
        stakingRewards2.stake(CHERRY_STAKINGERC20_STAKEDAMOUNT);
        vm.stopPrank();
        TOTAL_STAKED_AMOUNT =
            ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT + CHERRY_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup3 setUp() end");
    }
}

// ----------------------------------------------------------------------------

contract DuringStaking1_WithoutWithdral is DepositSetup1 {
    /**
     * @param _stakingPercentageDuration : 0 - infinite
     * @param _claimPercentageDuration : 0 - 100
     */
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithoutWithdral setUp() start");
        DepositSetup1.setUp();
        verboseLog("DuringStaking1_WithoutWithdral");
        debugLog("DuringStaking1_WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);

        uint256 expectedRewardPerToken = (
            getRewardDurationReached() == REWARD_INITIAL_DURATION
                ? REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                    / REWARD_INITIAL_DURATION
        );
        checkRewardPerToken(expectedRewardPerToken, 0, 0); // no delta needed
    }
}

// ------------------------------------

contract DuringStaking2_WithoutWithdral is DepositSetup2 {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithoutWithdral setUp() start");
        DepositSetup2.setUp();
        verboseLog("DuringStaking2_WithoutWithdral");
        debugLog("DuringStaking2_WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015, rewardErc20);
        }

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0_31, 0);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        userBobExpectedRewards -= userBobClaimedRewards;
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, DELTA_0_31, 0);

        uint256 expectedRewardPerToken = (
            getRewardDurationReached() == REWARD_INITIAL_DURATION
                ? REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                    / REWARD_INITIAL_DURATION
        );
        checkRewardPerToken(expectedRewardPerToken, DELTA_0_015, 0);
    }
}

// ------------------------------------

contract DuringStaking3_WithoutWithdral is DepositSetup3 {
    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithoutWithdral setUp() start");
        DepositSetup3.setUp();
        verboseLog("DuringStaking3_WithoutWithdral");
        debugLog("DuringStaking3_WithoutWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function testUsersStakingRewards() public {
        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userCherryExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;
        uint256 userCherryClaimedRewards;

        uint256 claimDelta = getClaimPercentDelta();
        uint256 rewardsDelta = getRewardPercentDelta();

        debugLog("STAKING_PERCENTAGE_DURATION : ", STAKING_PERCENTAGE_DURATION);
        debugLog("CLAIM_PERCENTAGE_DURATION > PERCENT_90 : ", (CLAIM_PERCENTAGE_DURATION > PERCENT_90 ? 1 : 0));
        debugLog("STAKING_PERCENTAGE_DURATION <= PERCENT_1 : ", (STAKING_PERCENTAGE_DURATION <= PERCENT_1 ? 1 : 0));
        debugLog("STAKING_PERCENTAGE_DURATION <= PERCENT_5 : ", (STAKING_PERCENTAGE_DURATION <= PERCENT_5 ? 1 : 0));
        debugLog("rewardsDelta : ", rewardsDelta);

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            debugLog("claimDelta : ", claimDelta);
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
            userCherryClaimedRewards =
                checkUserClaim(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", claimDelta, rewardErc20);
        }

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        checkUsersStake();
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, rewardsDelta, 0);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
        userBobExpectedRewards -= userBobClaimedRewards;
        debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, rewardsDelta, 0);

        userCherryExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userCherryExpectedRewards = ", userCherryExpectedRewards);
        userCherryExpectedRewards -= userCherryClaimedRewards;
        debugLog("userCherryExpectedRewards = ", userCherryExpectedRewards);
        checkStakingRewards(userCherry, "Cherry", userCherryExpectedRewards, rewardsDelta, 0);

        uint256 expectedRewardPerToken = (
            getRewardDurationReached() == REWARD_INITIAL_DURATION
                ? REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                : REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT
                    / REWARD_INITIAL_DURATION
        );
        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

        checkRewardPerToken(expectedRewardPerToken, DELTA_0_015, 0);
    }
}

// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking1_WithWithdral is DepositSetup1 {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computaton will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking1_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithWithdral setUp() start");
        DepositSetup1.setUp();
        verboseLog("DuringStaking1_WithWithdral");
        debugLog("DuringStaking1_WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
    }

    function testUsersStakingRewards() public {
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking1_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
            return;
        }

        verboseLog("STAKING_START_TIME = ", STAKING_START_TIME);
        checkUsersStake();
        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            // uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            // / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
            // checkRewardPerToken( expectedRewardPerToken, 0, 0 ); // no delta needed
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015, rewardErc20);
        }

        verboseLog(
            "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE
        );
        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE);
        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;

        // gotoStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );
        // checkStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);

        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, DELTA_0, 0);
        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

        checkRewardPerToken(expectedRewardPerToken, 0, 0); // no delta needed
    }
}

// ------------------------------------
// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking2_WithWithdral is DepositSetup2 {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computaton will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking2_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        require(
            _claimPercentageDuration <= (_stakingPercentageDuration / DIVIDE),
            "DuringStaking1_WithoutWithdral: _claimPercentageDuration > _stakingPercentageDuration / DIVIDE"
        );
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithWithdral setUp() start");
        DepositSetup2.setUp();
        verboseLog("DuringStaking2_WithWithdral");
        debugLog("DuringStaking2_WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
    }

    function testUsersStakingRewards() public {
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking2_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
            return;
        }

        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        checkUsersStake();

        uint256 claimDelta = getClaimPercentDelta();
        uint256 rewardsDelta = getRewardPercentDelta();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            // checkRewardPerToken( expectedRewardPerToken, 0, 0 ); // no delta needed
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
        }

        verboseLog(
            "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE
        );
        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE);
        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        // Bob withdraws all
        withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);
        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        debugLog("userAliceExpectedRewards = ", userAliceExpectedRewards);
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, rewardsDelta, 2);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
        userBobExpectedRewards -= userBobClaimedRewards;
        debugLog("userBobExpectedRewards = ", userBobExpectedRewards);
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, rewardsDelta, 1);
        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);

        checkRewardPerToken(expectedRewardPerToken, 0, 1);
    }
}

// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration

contract DuringStaking3_WithWithdral is DepositSetup3 {
    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor(uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computaton will underflow
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking3_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral:
        // _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithWithdral setUp() start");
        DepositSetup3.setUp();
        verboseLog("DuringStaking3_WithWithdral");
        debugLog("DuringStaking3_WithWithdral setUp() end");
    }

    function checkUsersStake() public {
        checkAliceStake();
        checkBobStake();
        checkCherryStake();
    }

    function testUsersStakingRewards() public {
        if (CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE) {
            fail("DuringStaking3_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
            return;
        }

        checkRewardPerToken(0, 0, 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        checkUsersStake();

        uint256 claimDelta = getClaimPercentDelta();
        uint256 rewardsPercentDelta = getRewardPercentDelta();
        uint8 rewardsUnitsDelta = getRewardUnitsDelta();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userCherryExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;
        uint256 userCherryClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod(CLAIM_PERCENTAGE_DURATION);
            // checkRewardPerToken( expectedRewardPerToken, 0, 0 ); // no delta needed
            userAliceClaimedRewards =
                checkUserClaim(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta, rewardErc20);
            debugLog("testUsersStakingRewards: userAliceClaimedRewards = ", userAliceClaimedRewards);
            userBobClaimedRewards =
                checkUserClaim(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta, rewardErc20);
            debugLog("testUsersStakingRewards: userBobClaimedRewards = ", userBobClaimedRewards);
            userCherryClaimedRewards =
                checkUserClaim(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", claimDelta, rewardErc20);
            debugLog("testUsersStakingRewards: userCherryClaimedRewards = ", userCherryClaimedRewards);
        }

        verboseLog(
            "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE
        );
        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);
        checkStakingPeriod(STAKING_PERCENTAGE_DURATION / DIVIDE);

        verboseLog("Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE);

        // Alice withdraws all
        withdrawStake(userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT);
        // Bob withdraws all
        withdrawStake(userBob, BOB_STAKINGERC20_STAKEDAMOUNT);
        // Cherry withdraws all
        withdrawStake(userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT);
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;

        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN
            / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPeriod(STAKING_PERCENTAGE_DURATION);

        debugLog("stakingElapsedTime = ", stakingElapsedTime);
        debugLog("reward duration (%%) of total staking reward duration = ", getRewardDurationReached());
        debugLog(
            "Staking duration (%%) total staking reward duration = ",
            STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100
        );

        userAliceExpectedRewards =
            expectedStakingRewards(ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("testUsersStakingRewards: userAliceExpectedRewards = ", userAliceExpectedRewards);
        userAliceExpectedRewards -= userAliceClaimedRewards;
        debugLog("testUsersStakingRewards: userAliceExpectedRewards = ", userAliceExpectedRewards);
        checkStakingRewards(userAlice, "Alice", userAliceExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 4);

        userBobExpectedRewards =
            expectedStakingRewards(BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("testUsersStakingRewards: userBobExpectedRewards = ", userBobExpectedRewards);
        userBobExpectedRewards -= userBobClaimedRewards;
        debugLog("testUsersStakingRewards: userBobExpectedRewards = ", userBobExpectedRewards);
        checkStakingRewards(userBob, "Bob", userBobExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 2);

        userCherryExpectedRewards =
            expectedStakingRewards(CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION);
        debugLog("testUsersStakingRewards: userCherryExpectedRewards = ", userCherryExpectedRewards);
        userCherryExpectedRewards -= userCherryClaimedRewards;
        debugLog("testUsersStakingRewards: userCherryExpectedRewards = ", userCherryExpectedRewards);
        checkStakingRewards(
            userCherry, "Cherry", userCherryExpectedRewards, rewardsPercentDelta, rewardsUnitsDelta * 1
        );

        debugLog("expectedRewardPerToken = ", expectedRewardPerToken);
        checkRewardPerToken(expectedRewardPerToken, 0, 1);
    }
}

// ----------------------------------------------------------------------------

// 1 staker deposits right after staking starts and keeps staked amount until the end of staking period
// /*
contract DuringStaking1_WithoutWithdral_0 is DuringStaking1_WithoutWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_1_0_1 is DuringStaking1_WithoutWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking1_WithoutWithdral_10__0 is DuringStaking1_WithoutWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_10__5 is DuringStaking1_WithoutWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking1_WithoutWithdral_20__0 is DuringStaking1_WithoutWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_20__10 is DuringStaking1_WithoutWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking1_WithoutWithdral_30__0 is DuringStaking1_WithoutWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_30__20 is DuringStaking1_WithoutWithdral(PERCENT_30, PERCENT_20) { }

contract DuringStaking1_WithoutWithdral_33__0 is DuringStaking1_WithoutWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_33__10 is DuringStaking1_WithoutWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking1_WithoutWithdral_40__0 is DuringStaking1_WithoutWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_40__5 is DuringStaking1_WithoutWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking1_WithoutWithdral_50__0 is DuringStaking1_WithoutWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_50__5 is DuringStaking1_WithoutWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking1_WithoutWithdral_60__0 is DuringStaking1_WithoutWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_60__20 is DuringStaking1_WithoutWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking1_WithoutWithdral_66__0 is DuringStaking1_WithoutWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_66__30 is DuringStaking1_WithoutWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking1_WithoutWithdral_70__0 is DuringStaking1_WithoutWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_70__10 is DuringStaking1_WithoutWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking1_WithoutWithdral_80__0 is DuringStaking1_WithoutWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_80__70 is DuringStaking1_WithoutWithdral(PERCENT_80, PERCENT_70) { }

contract DuringStaking1_WithoutWithdral_90__0 is DuringStaking1_WithoutWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_90__50 is DuringStaking1_WithoutWithdral(PERCENT_90, PERCENT_50) { }

contract DuringStaking1_WithoutWithdral_99__0 is DuringStaking1_WithoutWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_99__33 is DuringStaking1_WithoutWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking1_WithoutWithdral_100__0 is DuringStaking1_WithoutWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_100__30 is DuringStaking1_WithoutWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking1_WithoutWithdral_101__0 is DuringStaking1_WithoutWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_101__50 is DuringStaking1_WithoutWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking1_WithoutWithdral_110__0 is DuringStaking1_WithoutWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_110__60 is DuringStaking1_WithoutWithdral(PERCENT_110, PERCENT_60) { }

contract DuringStaking1_WithoutWithdral_150__0 is DuringStaking1_WithoutWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_150__70 is DuringStaking1_WithoutWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking1_WithoutWithdral_190__0 is DuringStaking1_WithoutWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_190__80 is DuringStaking1_WithoutWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking1_WithoutWithdral_200__0 is DuringStaking1_WithoutWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_200__90 is DuringStaking1_WithoutWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking1_WithoutWithdral_201__0 is DuringStaking1_WithoutWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_201__90 is DuringStaking1_WithoutWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking1_WithoutWithdral_220__0 is DuringStaking1_WithoutWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking1_WithoutWithdral_220__99 is DuringStaking1_WithoutWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 2 stakers deposit right after staking starts and keep staked amount until the end of staking period
// /*
contract DuringStaking2_WithoutWithdral_0__0 is DuringStaking2_WithoutWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_1__0 is DuringStaking2_WithoutWithdral(PERCENT_1, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_1__0_1 is DuringStaking2_WithoutWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking2_WithoutWithdral_10__0 is DuringStaking2_WithoutWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_10__5 is DuringStaking2_WithoutWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking2_WithoutWithdral_20__0 is DuringStaking2_WithoutWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_20__10 is DuringStaking2_WithoutWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking2_WithoutWithdral_30__ is DuringStaking2_WithoutWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_30__20 is DuringStaking2_WithoutWithdral(PERCENT_30, PERCENT_20) { }

contract DuringStaking2_WithoutWithdral_33__0 is DuringStaking2_WithoutWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_33__10 is DuringStaking2_WithoutWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking2_WithoutWithdral_40__ is DuringStaking2_WithoutWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_40__5 is DuringStaking2_WithoutWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking2_WithoutWithdral_50__0 is DuringStaking2_WithoutWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_50__5 is DuringStaking2_WithoutWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking2_WithoutWithdral_60__0 is DuringStaking2_WithoutWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_60__20 is DuringStaking2_WithoutWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking2_WithoutWithdral_66__0 is DuringStaking2_WithoutWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_66__30 is DuringStaking2_WithoutWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking2_WithoutWithdral_70__0 is DuringStaking2_WithoutWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_70__10 is DuringStaking2_WithoutWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking2_WithoutWithdral_80__0 is DuringStaking2_WithoutWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_80__70 is DuringStaking2_WithoutWithdral(PERCENT_80, PERCENT_70) { }

contract DuringStaking2_WithoutWithdral_90__0 is DuringStaking2_WithoutWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_90__50 is DuringStaking2_WithoutWithdral(PERCENT_90, PERCENT_50) { }

contract DuringStaking2_WithoutWithdral_99__0 is DuringStaking2_WithoutWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_99__33 is DuringStaking2_WithoutWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking2_WithoutWithdral_100__0 is DuringStaking2_WithoutWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_100__30 is DuringStaking2_WithoutWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking2_WithoutWithdral_101__0 is DuringStaking2_WithoutWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_101__50 is DuringStaking2_WithoutWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking2_WithoutWithdral_110__0 is DuringStaking2_WithoutWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_110__60 is DuringStaking2_WithoutWithdral(PERCENT_110, PERCENT_60) { }

contract DuringStaking2_WithoutWithdral_150__0 is DuringStaking2_WithoutWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_150__70 is DuringStaking2_WithoutWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking2_WithoutWithdral_190__0 is DuringStaking2_WithoutWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_190__80 is DuringStaking2_WithoutWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking2_WithoutWithdral_200__0 is DuringStaking2_WithoutWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_200__90 is DuringStaking2_WithoutWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking2_WithoutWithdral_201__0 is DuringStaking2_WithoutWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_201__90 is DuringStaking2_WithoutWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking2_WithoutWithdral_220__0 is DuringStaking2_WithoutWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking2_WithoutWithdral_220__99 is DuringStaking2_WithoutWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 3 stakers deposit right after staking starts and keep staked amount until the end of staking period
// /*
contract DuringStaking3_WithoutWithdral_0 is DuringStaking3_WithoutWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_1_0_1 is DuringStaking3_WithoutWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking3_WithoutWithdral_10__0 is DuringStaking3_WithoutWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_10__5 is DuringStaking3_WithoutWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking3_WithoutWithdral_20__0 is DuringStaking3_WithoutWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_20__10 is DuringStaking3_WithoutWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking3_WithoutWithdral_30__0 is DuringStaking3_WithoutWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_30__20 is DuringStaking3_WithoutWithdral(PERCENT_30, PERCENT_20) { }

contract DuringStaking3_WithoutWithdral_33__0 is DuringStaking3_WithoutWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_33__10 is DuringStaking3_WithoutWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking3_WithoutWithdral_40__0 is DuringStaking3_WithoutWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_40__5 is DuringStaking3_WithoutWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking3_WithoutWithdral_50__0 is DuringStaking3_WithoutWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_50__5 is DuringStaking3_WithoutWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking3_WithoutWithdral_60__0 is DuringStaking3_WithoutWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_60__20 is DuringStaking3_WithoutWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking3_WithoutWithdral_66__0 is DuringStaking3_WithoutWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_66__30 is DuringStaking3_WithoutWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking3_WithoutWithdral_70__0 is DuringStaking3_WithoutWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_70__10 is DuringStaking3_WithoutWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking3_WithoutWithdral_80__0 is DuringStaking3_WithoutWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_80__70 is DuringStaking3_WithoutWithdral(PERCENT_80, PERCENT_70) { }

contract DuringStaking3_WithoutWithdral_90__0 is DuringStaking3_WithoutWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_90__50 is DuringStaking3_WithoutWithdral(PERCENT_90, PERCENT_50) { }

contract DuringStaking3_WithoutWithdral_99__0 is DuringStaking3_WithoutWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_99__33 is DuringStaking3_WithoutWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking3_WithoutWithdral_100__0 is DuringStaking3_WithoutWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_100__30 is DuringStaking3_WithoutWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking3_WithoutWithdral_101__0 is DuringStaking3_WithoutWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_101__50 is DuringStaking3_WithoutWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking3_WithoutWithdral_110__0 is DuringStaking3_WithoutWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_110__60 is DuringStaking3_WithoutWithdral(PERCENT_110, PERCENT_60) { }

contract DuringStaking3_WithoutWithdral_150__0 is DuringStaking3_WithoutWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_150__70 is DuringStaking3_WithoutWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking3_WithoutWithdral_190__0 is DuringStaking3_WithoutWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_190__80 is DuringStaking3_WithoutWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking3_WithoutWithdral_200__0 is DuringStaking3_WithoutWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_200__90 is DuringStaking3_WithoutWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking3_WithoutWithdral_201__0 is DuringStaking3_WithoutWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_201__90 is DuringStaking3_WithoutWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking3_WithoutWithdral_220__0 is DuringStaking3_WithoutWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking3_WithoutWithdral_220__99 is DuringStaking3_WithoutWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration
// 42 tests
// /*
contract DuringStaking1_WithWithdral__0 is DuringStaking1_WithWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking1_WithWithdral__1_0_1 is DuringStaking1_WithWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking1_WithWithdral__10__0 is DuringStaking1_WithWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking1_WithWithdral__10__5 is DuringStaking1_WithWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking1_WithWithdral__20__0 is DuringStaking1_WithWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking1_WithWithdral__20__10 is DuringStaking1_WithWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking1_WithWithdral__30__0 is DuringStaking1_WithWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking1_WithWithdral__30__20 is DuringStaking1_WithWithdral(PERCENT_30, PERCENT_15) { }

contract DuringStaking1_WithWithdral__33__0 is DuringStaking1_WithWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking1_WithWithdral__33__10 is DuringStaking1_WithWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking1_WithWithdral__40__0 is DuringStaking1_WithWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking1_WithWithdral__40__5 is DuringStaking1_WithWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking1_WithWithdral__50__0 is DuringStaking1_WithWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking1_WithWithdral__50__5 is DuringStaking1_WithWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking1_WithWithdral__60__0 is DuringStaking1_WithWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking1_WithWithdral__60__20 is DuringStaking1_WithWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking1_WithWithdral__66__0 is DuringStaking1_WithWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking1_WithWithdral__66__30 is DuringStaking1_WithWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking1_WithWithdral__70__0 is DuringStaking1_WithWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking1_WithWithdral__70__10 is DuringStaking1_WithWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking1_WithWithdral__80__0 is DuringStaking1_WithWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking1_WithWithdral__80__70 is DuringStaking1_WithWithdral(PERCENT_80, PERCENT_30) { }

contract DuringStaking1_WithWithdral__90__0 is DuringStaking1_WithWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking1_WithWithdral__90__50 is DuringStaking1_WithWithdral(PERCENT_90, PERCENT_45) { }

contract DuringStaking1_WithWithdral__99__0 is DuringStaking1_WithWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking1_WithWithdral__99__33 is DuringStaking1_WithWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking1_WithWithdral__100__0 is DuringStaking1_WithWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking1_WithWithdral__100__30 is DuringStaking1_WithWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking1_WithWithdral__101__0 is DuringStaking1_WithWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking1_WithWithdral__101__50 is DuringStaking1_WithWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking1_WithWithdral__110__0 is DuringStaking1_WithWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking1_WithWithdral__110__60 is DuringStaking1_WithWithdral(PERCENT_110, PERCENT_40) { }

contract DuringStaking1_WithWithdral__150__0 is DuringStaking1_WithWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking1_WithWithdral__150__70 is DuringStaking1_WithWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking1_WithWithdral__190__0 is DuringStaking1_WithWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking1_WithWithdral__190__80 is DuringStaking1_WithWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking1_WithWithdral__200__0 is DuringStaking1_WithWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking1_WithWithdral__200__90 is DuringStaking1_WithWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking1_WithWithdral__201__0 is DuringStaking1_WithWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking1_WithWithdral__201__90 is DuringStaking1_WithWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking1_WithWithdral__220__0 is DuringStaking1_WithWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking1_WithWithdral__220__99 is DuringStaking1_WithWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration
// /*
// 42 tests
contract DuringStaking2_WithWithdral__0 is DuringStaking2_WithWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking2_WithWithdral__1_0_1 is DuringStaking2_WithWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking2_WithWithdral__10__0 is DuringStaking2_WithWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking2_WithWithdral__10__5 is DuringStaking2_WithWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking2_WithWithdral__20__0 is DuringStaking2_WithWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking2_WithWithdral__20__10 is DuringStaking2_WithWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking2_WithWithdral__30__0 is DuringStaking2_WithWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking2_WithWithdral__30__20 is DuringStaking2_WithWithdral(PERCENT_30, PERCENT_15) { }

contract DuringStaking2_WithWithdral__33__0 is DuringStaking2_WithWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking2_WithWithdral__33__10 is DuringStaking2_WithWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking2_WithWithdral__40__0 is DuringStaking2_WithWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking2_WithWithdral__40__5 is DuringStaking2_WithWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking2_WithWithdral__50__0 is DuringStaking2_WithWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking2_WithWithdral__50__5 is DuringStaking2_WithWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking2_WithWithdral__60__0 is DuringStaking2_WithWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking2_WithWithdral__60__20 is DuringStaking2_WithWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking2_WithWithdral__66__0 is DuringStaking2_WithWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking2_WithWithdral__66__30 is DuringStaking2_WithWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking2_WithWithdral__70__0 is DuringStaking2_WithWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking2_WithWithdral__70__10 is DuringStaking2_WithWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking2_WithWithdral__80__0 is DuringStaking2_WithWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking2_WithWithdral__80__70 is DuringStaking2_WithWithdral(PERCENT_80, PERCENT_30) { }

contract DuringStaking2_WithWithdral__90__0 is DuringStaking2_WithWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking2_WithWithdral__90__50 is DuringStaking2_WithWithdral(PERCENT_90, PERCENT_45) { }

contract DuringStaking2_WithWithdral__99__0 is DuringStaking2_WithWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking2_WithWithdral__99__33 is DuringStaking2_WithWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking2_WithWithdral__100__0 is DuringStaking2_WithWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking2_WithWithdral__100__30 is DuringStaking2_WithWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking2_WithWithdral__101__0 is DuringStaking2_WithWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking2_WithWithdral__101__50 is DuringStaking2_WithWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking2_WithWithdral__110__0 is DuringStaking2_WithWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking2_WithWithdral__110__60 is DuringStaking2_WithWithdral(PERCENT_110, PERCENT_40) { }

contract DuringStaking2_WithWithdral__150__0 is DuringStaking2_WithWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking2_WithWithdral__150__70 is DuringStaking2_WithWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking2_WithWithdral__190__0 is DuringStaking2_WithWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking2_WithWithdral__190__80 is DuringStaking2_WithWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking2_WithWithdral__200__0 is DuringStaking2_WithWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking2_WithWithdral__200__90 is DuringStaking2_WithWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking2_WithWithdral__201__0 is DuringStaking2_WithWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking2_WithWithdral__201__90 is DuringStaking2_WithWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking2_WithWithdral__220__0 is DuringStaking2_WithWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking2_WithWithdral__220__99 is DuringStaking2_WithWithdral(PERCENT_220, PERCENT_99) { }
// */
// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage
// duration
// /*
// 42 tests
contract DuringStaking3_WithWithdral__0 is DuringStaking3_WithWithdral(PERCENT_0, PERCENT_0) { }

contract DuringStaking3_WithWithdral__1_0_1 is DuringStaking3_WithWithdral(PERCENT_1, PERCENT_0_1) { }

contract DuringStaking3_WithWithdral__10__0 is DuringStaking3_WithWithdral(PERCENT_10, PERCENT_0) { }

contract DuringStaking3_WithWithdral__10__5 is DuringStaking3_WithWithdral(PERCENT_10, PERCENT_5) { }

contract DuringStaking3_WithWithdral__20__0 is DuringStaking3_WithWithdral(PERCENT_20, PERCENT_0) { }

contract DuringStaking3_WithWithdral__20__10 is DuringStaking3_WithWithdral(PERCENT_20, PERCENT_10) { }

contract DuringStaking3_WithWithdral__30__0 is DuringStaking3_WithWithdral(PERCENT_30, PERCENT_0) { }

contract DuringStaking3_WithWithdral__30__20 is DuringStaking3_WithWithdral(PERCENT_30, PERCENT_15) { }

contract DuringStaking3_WithWithdral__33__0 is DuringStaking3_WithWithdral(PERCENT_33, PERCENT_0) { }

contract DuringStaking3_WithWithdral__33__10 is DuringStaking3_WithWithdral(PERCENT_33, PERCENT_10) { }

contract DuringStaking3_WithWithdral__40__0 is DuringStaking3_WithWithdral(PERCENT_40, PERCENT_0) { }

contract DuringStaking3_WithWithdral__40__5 is DuringStaking3_WithWithdral(PERCENT_40, PERCENT_5) { }

contract DuringStaking3_WithWithdral__50__0 is DuringStaking3_WithWithdral(PERCENT_50, PERCENT_0) { }

contract DuringStaking3_WithWithdral__50__5 is DuringStaking3_WithWithdral(PERCENT_50, PERCENT_5) { }

contract DuringStaking3_WithWithdral__60__0 is DuringStaking3_WithWithdral(PERCENT_60, PERCENT_0) { }

contract DuringStaking3_WithWithdral__60__20 is DuringStaking3_WithWithdral(PERCENT_60, PERCENT_20) { }

contract DuringStaking3_WithWithdral__66__0 is DuringStaking3_WithWithdral(PERCENT_66, PERCENT_0) { }

contract DuringStaking3_WithWithdral__66__30 is DuringStaking3_WithWithdral(PERCENT_66, PERCENT_30) { }

contract DuringStaking3_WithWithdral__70__0 is DuringStaking3_WithWithdral(PERCENT_70, PERCENT_0) { }

contract DuringStaking3_WithWithdral__70__10 is DuringStaking3_WithWithdral(PERCENT_70, PERCENT_10) { }

contract DuringStaking3_WithWithdral__80__0 is DuringStaking3_WithWithdral(PERCENT_80, PERCENT_0) { }

contract DuringStaking3_WithWithdral__80__70 is DuringStaking3_WithWithdral(PERCENT_80, PERCENT_30) { }

contract DuringStaking3_WithWithdral__90__0 is DuringStaking3_WithWithdral(PERCENT_90, PERCENT_0) { }

contract DuringStaking3_WithWithdral__90__50 is DuringStaking3_WithWithdral(PERCENT_90, PERCENT_45) { }

contract DuringStaking3_WithWithdral__99__0 is DuringStaking3_WithWithdral(PERCENT_99, PERCENT_0) { }

contract DuringStaking3_WithWithdral__99__33 is DuringStaking3_WithWithdral(PERCENT_99, PERCENT_33) { }

contract DuringStaking3_WithWithdral__100__0 is DuringStaking3_WithWithdral(PERCENT_100, PERCENT_0) { }

contract DuringStaking3_WithWithdral__100__30 is DuringStaking3_WithWithdral(PERCENT_100, PERCENT_30) { }

contract DuringStaking3_WithWithdral__101__0 is DuringStaking3_WithWithdral(PERCENT_101, PERCENT_0) { }

contract DuringStaking3_WithWithdral__101__50 is DuringStaking3_WithWithdral(PERCENT_101, PERCENT_50) { }

contract DuringStaking3_WithWithdral__110__0 is DuringStaking3_WithWithdral(PERCENT_110, PERCENT_0) { }

contract DuringStaking3_WithWithdral__110__60 is DuringStaking3_WithWithdral(PERCENT_110, PERCENT_40) { }

contract DuringStaking3_WithWithdral__150__0 is DuringStaking3_WithWithdral(PERCENT_150, PERCENT_0) { }

contract DuringStaking3_WithWithdral__150__70 is DuringStaking3_WithWithdral(PERCENT_150, PERCENT_70) { }

contract DuringStaking3_WithWithdral__190__0 is DuringStaking3_WithWithdral(PERCENT_190, PERCENT_0) { }

contract DuringStaking3_WithWithdral__190__80 is DuringStaking3_WithWithdral(PERCENT_190, PERCENT_80) { }

contract DuringStaking3_WithWithdral__200__0 is DuringStaking3_WithWithdral(PERCENT_200, PERCENT_0) { }

contract DuringStaking3_WithWithdral__200__90 is DuringStaking3_WithWithdral(PERCENT_200, PERCENT_90) { }

contract DuringStaking3_WithWithdral__201__0 is DuringStaking3_WithWithdral(PERCENT_201, PERCENT_0) { }

contract DuringStaking3_WithWithdral__201__90 is DuringStaking3_WithWithdral(PERCENT_201, PERCENT_90) { }

contract DuringStaking3_WithWithdral__220__0 is DuringStaking3_WithWithdral(PERCENT_220, PERCENT_0) { }

contract DuringStaking3_WithWithdral__220__99 is DuringStaking3_WithWithdral(PERCENT_220, PERCENT_99) { }
// */
// --------------------------------------------------------

// /*

contract CheckStakingPermissions2 is StakingSetup2 {
    function setUp() public virtual override {
        debugLog("CheckStakingPermissions2 setUp() start");
        verboseLog("CheckStakingPermissions2 setUp()");
        StakingSetup2.setUp();
        debugLog("CheckStakingPermissions2 setUp() end");
    }

    function testStakingPause() public {
        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        verboseLog("Only staking reward contract owner can pause");

        stakingRewards2.setPaused(true);
        assertEq(stakingRewards2.paused(), false);
        verboseLog("Staking contract: Alice can't pause");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));

        stakingRewards2.setPaused(true);
        assertEq(stakingRewards2.paused(), false);
        verboseLog("Staking contract: Bob can't pause");

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit Pausable.Paused(userStakingRewardAdmin);
        stakingRewards2.setPaused(true);
        assertEq(stakingRewards2.paused(), true);
        verboseLog("Staking contract: Only owner can pause");
        verboseLog("Staking contract: Event Paused emitted");

        // Pausing again should not throw nor emit event and leave pause unchanged
        stakingRewards2.setPaused(true);
        // Check no event emitted ?
        assertEq(stakingRewards2.paused(), true);
        vm.stopPrank();

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        verboseLog("Only staking reward contract owner can unpause");

        stakingRewards2.setPaused(false);
        assertEq(stakingRewards2.paused(), true);
        verboseLog("Staking contract: Alice can't unpause");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));

        stakingRewards2.setPaused(false);
        assertEq(stakingRewards2.paused(), true);
        verboseLog("Staking contract: Bob can't unpause");

        vm.startPrank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit Pausable.Unpaused(userStakingRewardAdmin);
        stakingRewards2.setPaused(false);
        assertEq(stakingRewards2.paused(), false);

        verboseLog("Staking contract: Only owner can unpause");
        verboseLog("Staking contract: Event Unpaused emitted");

        // Unausing again should not throw nor emit event and leave pause unchanged
        stakingRewards2.setPaused(false);
        // Check no event emitted ?
        assertEq(stakingRewards2.paused(), false);

        vm.stopPrank();
    }

    function testStakingNotifyRewardAmountMin() public {
        verboseLog("Only staking reward contract owner can notifyRewardAmount");

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));

        stakingRewards2.notifyRewardAmount(1);
        verboseLog("Staking contract: Alice can't notifyRewardAmount");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));

        stakingRewards2.notifyRewardAmount(1);
        verboseLog("Staking contract: Bob can't notifyRewardAmount");

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2.RewardAdded(1);
        stakingRewards2.notifyRewardAmount(1);
        verboseLog("Staking contract: Only owner can notifyRewardAmount of ", 1);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingNotifyRewardAmount0() public {
        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2.RewardAdded(0);
        stakingRewards2.notifyRewardAmount(0);
        verboseLog("Staking contract: Only owner can notifyRewardAmount of ", 0);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingNotifyRewardAmountLimit1() public {
        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION; // computed  reward rate must exceed by at
            // least one unit for raising an error
        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2.RewardAdded(rewardAmountToAddForRaisingError - 1);
        stakingRewards2.notifyRewardAmount(rewardAmountToAddForRaisingError - 1);
        verboseLog("Staking contract: Only owner can notifyRewardAmount of ", rewardAmountToAddForRaisingError - 1);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingNotifyRewardAmountLimitMax() public {
        uint256 additionnalRewardAmount = REWARD_INITIAL_DURATION;

        // Mint reward ERC20 a second time
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), additionnalRewardAmount);
        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2.RewardAdded(additionnalRewardAmount);
        stakingRewards2.notifyRewardAmount(additionnalRewardAmount);
        verboseLog("Staking contract: Only owner can notifyRewardAmount of an additionnal ", additionnalRewardAmount);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingRewardAmountTooHigh1() public {
        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION; // computed  reward rate must exceed by at
            // least one unit for raising an error

        vm.prank(userStakingRewardAdmin);
        // Check revert
        vm.expectRevert(
            abi.encodeWithSelector(
                IStakingRewards2Errors.ProvidedRewardTooHigh.selector,
                rewardAmountToAddForRaisingError,
                REWARD_INITIAL_AMOUNT,
                REWARD_INITIAL_DURATION
            )
        );
        stakingRewards2.notifyRewardAmount(rewardAmountToAddForRaisingError);
        verboseLog("Staking contract: Not enough reward balance");
    }

    function testStakingRewardAmountTooHigh2() public {
        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION; // computed  reward rate must exceed by at
            // least one unit for raising an error

        // Mint reward ERC20 a second time
        vm.prank(erc20Minter);
        rewardErc20.mint(address(stakingRewards2), rewardAmountToAddForRaisingError);

        vm.prank(userStakingRewardAdmin);
        // Check revert
        vm.expectRevert(
            abi.encodeWithSelector(
                IStakingRewards2Errors.ProvidedRewardTooHigh.selector,
                rewardAmountToAddForRaisingError * 2,
                REWARD_INITIAL_AMOUNT + rewardAmountToAddForRaisingError,
                REWARD_INITIAL_DURATION
            )
        );
        stakingRewards2.notifyRewardAmount(rewardAmountToAddForRaisingError * 2);

        verboseLog("Staking contract: Only owner can notifyRewardAmount of ", rewardAmountToAddForRaisingError + 1);
        verboseLog("Staking contract: Event RewardAdded emitted");
    }

    function testStakingSetRewardsDuration() public {
        // Previous reward epoch must have ended before setting a new duration
        vm.warp(STAKING_START_TIME + REWARD_INITIAL_DURATION + 1); // epoch ended

        vm.prank(userAlice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userAlice));
        verboseLog("Only staking reward contract owner can setRewardsDuration");

        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Alice can't setRewardsDuration");

        vm.prank(userBob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, userBob));

        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Bob can't setRewardsDuration");

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true, false, false, false, address(stakingRewards2));
        emit StakingRewards2.RewardsDurationUpdated(1);
        stakingRewards2.setRewardsDuration(1);
        verboseLog("Staking contract: Only owner can setRewardsDuration");
        verboseLog("Staking contract: Event RewardsDurationUpdated emitted");
    }

    function testStakingSetRewardsDurationBeforeEpochEnd() public {
        // Previous reward epoch must have ended before setting a new duration
        vm.startPrank(userStakingRewardAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(
                IStakingRewards2Errors.RewardPeriodInProgress.selector,
                block.timestamp,
                STAKING_START_TIME + REWARD_INITIAL_DURATION
            )
        );
        // vm.expectRevert( bytes(_MMPOR000) );
        stakingRewards2.setRewardsDuration(1);

        // Previous reward epoch must have ended before setting a new duration
        vm.warp(STAKING_START_TIME + REWARD_INITIAL_DURATION); // epoch last time reward
        vm.expectRevert(
            abi.encodeWithSelector(
                IStakingRewards2Errors.RewardPeriodInProgress.selector,
                block.timestamp,
                STAKING_START_TIME + REWARD_INITIAL_DURATION
            )
        );
        stakingRewards2.setRewardsDuration(1);

        verboseLog("Staking contract: Owner can't setRewardsDuration before previous epoch end");
        vm.stopPrank();
    }
}

// */
