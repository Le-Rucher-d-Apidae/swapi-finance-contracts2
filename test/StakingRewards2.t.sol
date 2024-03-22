// SPDX-License-Identifier: UNLICENSED
// pragma solidity >= 0.8.20 < 0.9.0;
// pragma solidity ^0.8.23;
// pragma solidity >= 0.8.20;
// pragma solidity ^0.7.6;
// pragma solidity >= 0.7.6 <= 0.8.0;
// pragma solidity >= 0.7.6;
pragma solidity >=0.8.0;
// pragma solidity <=0.8.0;

import { console } from "forge-std/src/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";

import { Utils } from "./utils/Utils.sol";


import { StakingRewards2 } from "../src/contracts/StakingRewards2.sol";
import { IStakingRewards2Errors } from "../src/contracts/IStakingRewards2Errors.sol";

import { Math } from "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import { Ownable } from "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts@5.0.2/utils/Pausable.sol";

import { IERC20 } from "../src/contracts/Uniswap/v2-core/interfaces/IERC20.sol";

import { RewardERC20 } from "./contracts/RewardERC20.sol";
import { StakingERC20 } from "./contracts/StakingERC20.sol";

import "./TestsConstants.sol";

// TODO : move to utils
contract TestLog is Test {

    bool debug = false;
    bool verbose = true;
    Utils internal utils;

    function debugLog(string memory _msg) public view {
        if (debug) console.log(_msg);
    }
    function debugLog(string memory _msg, uint _val256) public view {
        if (debug) console.log(_msg, _val256);
    }
    function debugLog(string memory _msg, address _address) public view {
        if (debug) console.log(_msg, _address);
    }
    function debugLogTime(string memory _msg) public view {
        if (debug) console.log(_msg, " ts: ", block.timestamp);
    }
    function debugLogTime(string memory _msg, uint _val256) public view {
        if (debug) console.log(_msg, _val256, " ts: ", block.timestamp);
    }
    function debugLogTime(string memory _msg, address _address) public view {
        if (debug) console.log(_msg, _address, " ts: ", block.timestamp);
    }
    function verboseLog(string memory _msg) public view {
        if (verbose) console.log(_msg);
    }
    function verboseLog(string memory _msg, uint _val256) public view {
        if (verbose) console.log(_msg, _val256);
    }
    function verboseLog(string memory _msg, address _address) public view {
        if (verbose) console.log(_msg, _address);
    }
    function verboseLogTime(string memory _msg) public view {
        if (verbose) console.log(_msg, " ts: ", block.timestamp);
    }
    function verboseLogTime(string memory _msg, uint _val256) public view {
        if (verbose) console.log(_msg, _val256, " ts: ", block.timestamp);
    }
    function verboseLogTime(string memory _msg, address _address) public view {
        if (verbose) console.log(_msg, _address, " ts: ", block.timestamp);
    }

    // function checkOnlyAddressCanInvoke(address _allowedAddress, address[] memory _users, address _contract, bytes4 _selector) public {
    function checkOnlyAddressCanInvoke(address _allowedAddress, address[] calldata _users, address _contract, bytes4 _selector) public {
        uint256 usersCount = _users.length;
        for (uint256 currentUserIdx = 0; currentUserIdx < usersCount; currentUserIdx++ ) {
            address adr = _users[currentUserIdx];
            if ( adr ==  _allowedAddress) continue;
            vm.prank( adr );
            // _contract.call(_selector)
            (bool staticcallSuccess, ) = _contract.staticcall( abi.encodeWithSelector(_selector) );
            // assert
            assertTrue(staticcallSuccess, "checkOnlyAddressCanInvoke: staticcall failed");
        }
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

        // console.log("UsersSetup1 setUp()");
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

        // console.log("UsersSetup2 setUp()");
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

        // console.log("UsersSetup3 setUp()");
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
        // console.log("Erc20Setup1 setUp()");
        debugLog("Erc20Setup1 setUp() start");
        UsersSetup1.setUp();
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
        // console.log("Erc20Setup2 setUp()");
        debugLog("Erc20Setup2 setUp() start");
        UsersSetup2.setUp();
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
        // console.log("Erc20Setup3 setUp()");
        debugLog("Erc20Setup3 setUp() start");
        UsersSetup3.setUp();
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

// ----------------

contract StakingSetup is TestLog {

    uint256 constant internal REWARD_INITIAL_AMOUNT = 100_000; // 10e5
    uint256 constant internal REWARD_INITIAL_DURATION = 10_000; // 10e4 ; 10 000 s. = 2h 46m 40s
    uint256 immutable STAKING_START_TIME = block.timestamp;

    uint256 /* constant */ internal TOTAL_STAKED_AMOUNT;
    uint256 /* immutable */ STAKING_PERCENTAGE_DURATION;
    uint256 /* immutable */ CLAIM_PERCENTAGE_DURATION;

    StakingRewards2 internal stakingRewards2;

    function checkRewardPerToken(uint256 _expectedRewardPerToken, uint256 _delta) public {
        uint256 stakingRewardsRewardPerToken = stakingRewards2.rewardPerToken();
        verboseLog( "checkRewardPerToken rewardPerToken = ", stakingRewards2.rewardPerToken() );
        if ( _delta == 0 ) {
            assertEq( stakingRewardsRewardPerToken, _expectedRewardPerToken, "Unexpected rewardPerToken() value");

        } else {
            assertApproxEqRel( stakingRewardsRewardPerToken, _expectedRewardPerToken, _delta, "Unexpected rewardPerToken() value");
        }
    }

    function getClaimDelta() public view returns (uint256) {
        uint256 claimDelta = CLAIM_PERCENTAGE_DURATION <= PERCENT_10 ? (CLAIM_PERCENTAGE_DURATION <= PERCENT_1 ? DELTA_5 : DELTA_0_4) : DELTA_0_015;
        verboseLog( "claimDelta : ", claimDelta );
        return claimDelta;
    }

    function getRewardDelta() public view returns (uint256) {
        uint256 rewardsDelta =
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
        verboseLog( "getRewardDelta : ", rewardsDelta );
        return rewardsDelta;
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
        stakingRewards2.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup1 setUp() end");
    }

    function checkRewardForDuration() public {
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards2.getRewardForDuration( );
        verboseLog( "checkRewardForDuration: getRewardForDuration = ", stakingRewards2.getRewardForDuration() );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        verboseLog( "Staking contract: rewardsDuration ok" );
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
        rewardErc20.mint( address(stakingRewards2), REWARD_INITIAL_AMOUNT );

        vm.prank( userStakingRewardAdmin );
        stakingRewards2.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup2 setUp() end");
    }

    function checkRewardForDuration() public {
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards2.getRewardForDuration( );
        verboseLog( "checkRewardForDuration: getRewardForDuration = ", stakingRewards2.getRewardForDuration() );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        verboseLog( "Staking contract: rewardsDuration ok" );
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
        stakingRewards2.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        // debugLog("Staking start time", stakingStartTime);
        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup3 setUp() end");
    }

    function checkRewardForDuration() public {
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards2.getRewardForDuration( );
        verboseLog( "checkRewardForDuration: getRewardForDuration = ", stakingRewards2.getRewardForDuration() );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended
        rewardForDuration = stakingRewards2.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        verboseLog( "Staking contract: rewardsDuration ok" );
    }
}


// ------------------------------------

contract DepositSetup1 is StakingSetup1 {

    function setUp() public virtual override {
        // console.log("DepositSetup1 setUp()");
        debugLog("DepositSetup1 setUp() start");
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

    function checkStakingTotalSupplyStaked() public {
        uint256 stakingRewardsTotalSupply = stakingRewards2.totalSupply();
        assertEq( TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply );
        verboseLog( "checkStakingTotalSupplyStaked", stakingRewardsTotalSupply );
    }
}

// ----------------

contract DepositSetup2 is StakingSetup2 {

    function setUp() public virtual override {
        // console.log("DepositSetup2 setUp()");
        debugLog("DepositSetup2 setUp() start");
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

    function checkStakingTotalSupplyStaked() public {
        uint256 stakingRewardsTotalSupply = stakingRewards2.totalSupply();
        assertEq( TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply );
        verboseLog( "checkStakingTotalSupplyStaked", stakingRewardsTotalSupply );
    }
}

// ----------------

contract DepositSetup3 is StakingSetup3 {

    function setUp() public virtual override {
        // console.log("DepositSetup3 setUp()");
        debugLog("DepositSetup3 setUp() start");
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

    function checkStakingTotalSupplyStaked() public {
        uint256 stakingRewardsTotalSupply = stakingRewards2.totalSupply();
        assertEq( TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply );
        verboseLog( "checkStakingTotalSupplyStaked", stakingRewardsTotalSupply );
    }
}

// ----------------------------------------------------------------------------

contract DuringStaking1_WithoutWithdral is DepositSetup1 {

    /**
     * @param _stakingPercentageDuration : 0 - infinite
     * @param _claimPercentageDuration : 0 - 100
     */
    constructor (uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral: _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithoutWithdral setUp() start");
        DepositSetup1.setUp();
        // console.log("DuringStaking1_WithoutWithdral");
        debugLog("DuringStaking1_WithoutWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
    }

    function checkAliceStake() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkUsersStake() public {
        checkAliceStake();
    }

    function getRewardDurationReached() internal view returns (uint256) {
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) public {
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 stakingTimeReached = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
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

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration) public view returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
        return (rewardsDuration == _rewardTotalDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function checkUserClaim(address _user, uint256 _stakeAmount, string memory _userName, uint256 _delta) public returns(uint256 claimedRewards_) {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog( "CLAIM:" );
            verboseLog(_userName);
            // gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
            verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
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

    function testUsersStakingRewards() public {

        verboseLog( "STAKING_START_TIME = ", STAKING_START_TIME );
        checkUsersStake();
        checkRewardPerToken(0 , 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );
            userAliceClaimedRewards = checkUserClaim( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015 );
        }

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION );
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
        verboseLog( "reward duration (%%) of total staking reward duration : ", getRewardDurationReached() );
        verboseLog( "Staking duration (%%) total staking reward duration: ", STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100 );

        userAliceExpectedRewards = expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
        userAliceExpectedRewards-= userAliceClaimedRewards;
        checkStakingRewards( userAlice, "Alice", userAliceExpectedRewards , DELTA_0 );

        uint256 expectedRewardPerToken = (getRewardDurationReached() == REWARD_INITIAL_DURATION ?
            REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION);
        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
}

// ------------------------------------

contract DuringStaking2_WithoutWithdral is DepositSetup2 {

    constructor (uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral: _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithoutWithdral setUp() start");
        DepositSetup2.setUp();
        // console.log("DuringStaking2_WithoutWithdral");
        debugLog("DuringStaking2_WithoutWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
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

    function getRewardDurationReached() internal view returns (uint256) {
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) public {
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        // uint256 stakingTimeReached = getStakingTimeReached();
        uint256 stakingTimeReached = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
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

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration) public view returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);

        return (rewardsDuration == _rewardTotalDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function checkUserClaim(address _user, uint256 _stakeAmount, string memory _userName, uint256 _delta) public returns(uint256 claimedRewards_) {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog( "CLAIM:" );
            verboseLog(_userName);
            // gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
            verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
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

    function testUsersStakingRewards() public {

        verboseLog( "STAKING_START_TIME = ", STAKING_START_TIME );
        checkUsersStake();
        checkRewardPerToken(0 , 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );
            userAliceClaimedRewards = checkUserClaim( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015 );
            userBobClaimedRewards = checkUserClaim( userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015 );
        }

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION );
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
        verboseLog( "reward duration (%%) of total staking reward duration : ", getRewardDurationReached() );
        verboseLog( "Staking duration (%%) total staking reward duration: ", STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100 );

        userAliceExpectedRewards = expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
        userAliceExpectedRewards-= userAliceClaimedRewards;
        checkStakingRewards( userAlice, "Alice", userAliceExpectedRewards , DELTA_0_31 );

        userBobExpectedRewards = expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
        userBobExpectedRewards-= userBobClaimedRewards;
        checkStakingRewards( userBob, "Bob", userBobExpectedRewards , DELTA_0_31 );

        uint256 expectedRewardPerToken = (getRewardDurationReached() == REWARD_INITIAL_DURATION ?
            REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION);
        checkRewardPerToken( expectedRewardPerToken, DELTA_0_015 );
    }

}

// ------------------------------------

contract DuringStaking3_WithoutWithdral is DepositSetup3 {

    constructor (uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral: _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithoutWithdral setUp() start");
        DepositSetup3.setUp();
        // console.log("DuringStaking3_WithoutWithdral");
        debugLog("DuringStaking3_WithoutWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
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

    function getRewardDurationReached() internal view returns (uint256) {
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) public {
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        // uint256 stakingTimeReached = getStakingTimeReached();
        uint256 stakingTimeReached = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
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

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration) public view returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
        return (rewardsDuration == _rewardTotalDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function checkUserClaim(address _user, uint256 _stakeAmount, string memory _userName, uint256 _delta) public returns(uint256 claimedRewards_) {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog( "CLAIM:" );
            verboseLog(_userName);
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
            verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
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

    function testUsersStakingRewards() public {

        verboseLog( "STAKING_START_TIME = ", STAKING_START_TIME );
        checkUsersStake();
        checkRewardPerToken(0 , 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userCherryExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;
        uint256 userCherryClaimedRewards;

        // Longer staking period = better accuracy : less delta
        uint256 claimDelta = getClaimDelta();
        uint256 rewardsDelta = getRewardDelta();

        // verboseLog( "STAKING_PERCENTAGE_DURATION : ", STAKING_PERCENTAGE_DURATION );
        // verboseLog( "CLAIM_PERCENTAGE_DURATION > PERCENT_90 : ", (CLAIM_PERCENTAGE_DURATION > PERCENT_90? 1 : 0) );
        // verboseLog( "STAKING_PERCENTAGE_DURATION <= PERCENT_1 : ", (STAKING_PERCENTAGE_DURATION <= PERCENT_1? 1 : 0) );
        // verboseLog( "STAKING_PERCENTAGE_DURATION <= PERCENT_5 : ", (STAKING_PERCENTAGE_DURATION <= PERCENT_5? 1 : 0) );
        // verboseLog( "rewardsDelta : ", rewardsDelta );

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );
            verboseLog( "claimDelta : ", claimDelta );
            userAliceClaimedRewards = checkUserClaim( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", claimDelta );
            userBobClaimedRewards = checkUserClaim( userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", claimDelta );
            userCherryClaimedRewards = checkUserClaim( userCherry, CHERRY_STAKINGERC20_STAKEDAMOUNT, "Cherry", claimDelta );
        }

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION );
        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
        verboseLog( "reward duration (%%) of total staking reward duration : ", getRewardDurationReached() );
        verboseLog( "Staking duration (%%) total staking reward duration: ", STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100 );


        userAliceExpectedRewards = expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
        userAliceExpectedRewards-= userAliceClaimedRewards;
        checkStakingRewards( userAlice, "Alice", userAliceExpectedRewards , rewardsDelta );

        userBobExpectedRewards = expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
        userBobExpectedRewards-= userBobClaimedRewards;
        checkStakingRewards( userBob, "Bob", userBobExpectedRewards , rewardsDelta );

        userCherryExpectedRewards = expectedStakingRewards( CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
        userCherryExpectedRewards-= userCherryClaimedRewards;
        checkStakingRewards( userCherry, "Cherry", userCherryExpectedRewards , rewardsDelta );


        uint256 expectedRewardPerToken = (getRewardDurationReached() == REWARD_INITIAL_DURATION ?
            REWARD_INITIAL_AMOUNT * ONE_TOKEN / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * getRewardDurationReached() * ONE_TOKEN / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION);
        // verboseLog( "expectedRewardPerToken = ", expectedRewardPerToken );
        checkRewardPerToken( expectedRewardPerToken, DELTA_0_015 );
    }
}

// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking1_WithWithdral is DepositSetup1 {

    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor (uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        // Claim must be BEFORE (or equal to) half of the staking duration, else reward computaton will underflow
        if ( CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE ) {
            fail("DuringStaking1_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
        }
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithWithdral setUp() start");
        DepositSetup1.setUp();
        // console.log("DuringStaking1_WithWithdral");
        debugLog("DuringStaking1_WithWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
    }

    function checkAliceStake() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkUsersStake() public {
        checkAliceStake();
    }

    function getRewardDurationReached() internal view returns (uint256) {
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getRewardDurationReached(uint _durationReached) internal pure returns (uint256) {
        uint256 rewardDurationReached = (_durationReached >= REWARD_INITIAL_DURATION ? REWARD_INITIAL_DURATION : _durationReached);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }


    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    function getStakingDuration() internal view returns (uint256) {
        uint256 stakingDuration = REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100;
        verboseLog( "getStakingDuration: stakingDuration = ",  stakingDuration);
        return stakingDuration;
    }

    function getRewardedStakingDuration(uint8 _divide) internal view returns (uint256) {
        uint256 stakingDuration = getStakingDuration() / _divide;
        verboseLog( "getRewardedStakingDuration: stakingDuration = ",  stakingDuration);
        uint256 rewardedStakingDuration = getRewardDurationReached( stakingDuration );
        verboseLog( "getRewardedStakingDuration: rewardedStakingDuration = ",  rewardedStakingDuration);
        return rewardedStakingDuration;
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) public {
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        // uint256 stakingTimeReached = getStakingTimeReached();
        uint256 stakingTimeReached = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
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

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration) public view returns (uint256 expectedRewardsAmount_) {
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);
        expectedRewardsAmount_ = (rewardsDuration == _rewardTotalDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function withdrawStake(address _user, uint256 _amount) public {
        uint256 balanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_user);
        // Check emitted event
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Withdrawn( _user, _amount );
        vm.prank(_user);
        stakingRewards2.withdraw( _amount );
        uint256 balanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_user);
        assertEq( balanceOfUserBeforeWithdrawal - _amount, balanceOfUserAfterWithdrawal );
    }

    function checkUserClaim(address _user, uint256 _stakeAmount, string memory _userName, uint256 _delta) public returns(uint256 claimedRewards_) {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog( "CLAIM:" );
            verboseLog(_userName);
            // gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
            verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
            uint256 rewardErc20UserBalance = rewardErc20.balanceOf( _user );
            verboseLog( "CLAIM: before: user reward balance = ", rewardErc20UserBalance );
            uint256 expectedRewards = expectedStakingRewards( _stakeAmount, stakingElapsedTime, REWARD_INITIAL_DURATION );
            vm.startPrank(_user);
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

            // Claim a second time: should not change the balance
            // vm.expectEmit(true,true,false,false, address(stakingRewards2));
            // emit StakingRewards2.RewardPaid( _user, 0 );
            uint256 logsCount = vm.getRecordedLogs().length;
    console.log("logsCount = ", logsCount);
            stakingRewards2.getReward();
            logsCount = vm.getRecordedLogs().length;
    console.log("logsCount = ", logsCount);
            uint256 rewardErc20UserBalanceAfterClaim2 = rewardErc20.balanceOf( _user );
            assertEq( rewardErc20UserBalanceAfterClaim, rewardErc20UserBalanceAfterClaim2 );

            // if (_delta == 0) {
            //     assertEq( rewardErc20UserBalanceAfterClaim, rewardErc20UserBalanceAfterClaim2 );
            // } else {
            //     assertApproxEqRel( rewardErc20UserBalanceAfterClaim, rewardErc20UserBalanceAfterClaim2, _delta );
            // }


            vm.stopPrank();
        }
    }

    function testUsersStakingRewards() public {

        if ( CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE ) {
            fail("DuringStaking1_WithWithdral: CLAIM_PERCENTAGE_DURATION > STAKING_PERCENTAGE_DURATION / DIVIDE");
            return;
        }

        verboseLog( "STAKING_START_TIME = ", STAKING_START_TIME );
        checkUsersStake();
        checkRewardPerToken( 0 , 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userAliceClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );

            // uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
            // checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed

            userAliceClaimedRewards = checkUserClaim( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015 );
        }

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
        verboseLog( "reward duration (%%) of total staking reward duration : ", getRewardDurationReached() );
        verboseLog( "Staking duration (%%) total staking reward duration: ", STAKING_PERCENTAGE_DURATION * REWARD_INITIAL_DURATION / PERCENT_100 );

    // verboseLog( "Before userAliceExpectedRewards");
        userAliceExpectedRewards = expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
    // verboseLog( "After userAliceExpectedRewards");
    // verboseLog( "userAliceExpectedRewards : ", userAliceExpectedRewards );
    // verboseLog( "userAliceClaimedRewards : ", userAliceClaimedRewards );
    // verboseLog( "userAliceExpectedRewards-= userAliceClaimedRewards < 0 : ", userAliceClaimedRewards > userAliceExpectedRewards ? 1 : 0);
        userAliceExpectedRewards-= userAliceClaimedRewards;

        verboseLog( "stakingElapsedTime : ", stakingElapsedTime );

        verboseLog( "After userAliceExpectedRewards-= userAliceClaimedRewards");
        checkStakingRewards( userAlice, "Alice", userAliceExpectedRewards , DELTA_0 );

        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;
        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
}

// ------------------------------------
// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking2_WithWithdral is DepositSetup2 {

    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    constructor (uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        require(_claimPercentageDuration <= (_stakingPercentageDuration / DIVIDE), "DuringStaking1_WithoutWithdral: _claimPercentageDuration > _stakingPercentageDuration / DIVIDE");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithWithdral setUp() start");
        DepositSetup2.setUp();
        // console.log("DuringStaking2_WithWithdral");
        debugLog("DuringStaking2_WithWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
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

    function getRewardDurationReached() internal view returns (uint256) {
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getRewardDurationReached(uint _durationReached) internal pure returns (uint256) {
        uint256 rewardDurationReached = (_durationReached >= REWARD_INITIAL_DURATION ? REWARD_INITIAL_DURATION : _durationReached);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }


    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    function getStakingDuration() internal view returns (uint256) {
        uint256 stakingDuration = REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100;
        verboseLog( "getStakingDuration: stakingDuration = ",  stakingDuration);
        return stakingDuration;
    }

    function getRewardedStakingDuration(uint8 _divide) internal view returns (uint256) {
        uint256 stakingDuration = getStakingDuration() / _divide;
        verboseLog( "getRewardedStakingDuration: stakingDuration = ",  stakingDuration);
        uint256 rewardedStakingDuration = getRewardDurationReached( stakingDuration );
        verboseLog( "getRewardedStakingDuration: rewardedStakingDuration = ",  rewardedStakingDuration);
        return rewardedStakingDuration;
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) public {
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        // uint256 stakingTimeReached = getStakingTimeReached();
        uint256 stakingTimeReached = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
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

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration) public view returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);

        return (rewardsDuration == _rewardTotalDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function checkUserClaim(address _user, uint256 _stakeAmount, string memory _userName, uint256 _delta) public returns(uint256 claimedRewards_) {
        if (CLAIM_PERCENTAGE_DURATION > 0) {
            verboseLog( "CLAIM:" );
            verboseLog(_userName);
            // gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );
            uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
            verboseLog( "stakingElapsedTime : ", stakingElapsedTime );
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

    function withdrawStake(address _user, uint256 _amount) public {
        uint256 balanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_user);
        // Check emitted event
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Withdrawn( _user, _amount );
        vm.prank(_user);
        stakingRewards2.withdraw( _amount );
        uint256 balanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_user);
        assertEq( balanceOfUserBeforeWithdrawal - _amount, balanceOfUserAfterWithdrawal );
    }

    function testUsersStakingRewards() public {

        checkRewardPerToken( 0 , 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        checkUsersStake();

        uint256 stakingElapsedTime;
        uint256 userAliceExpectedRewards;
        uint256 userBobExpectedRewards;
        uint256 userAliceClaimedRewards;
        uint256 userBobClaimedRewards;

        if (CLAIM_PERCENTAGE_DURATION > 0) {
            gotoStakingPeriod( CLAIM_PERCENTAGE_DURATION );
            // checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
            userAliceClaimedRewards = checkUserClaim( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice", DELTA_0_015 );
            userBobClaimedRewards = checkUserClaim( userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob", DELTA_0_015 );
        }

        verboseLog( "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );

        verboseLog( "Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        // Alice withdraws all
        withdrawStake( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT );
        // Bob withdraws all
        withdrawStake( userBob, BOB_STAKINGERC20_STAKEDAMOUNT );

        stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        verboseLog( "Staking duration (%%) : ", STAKING_PERCENTAGE_DURATION );

        // uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period = better accuracy : less delta

        userAliceExpectedRewards = expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
        userAliceExpectedRewards-= userAliceClaimedRewards;
        checkStakingRewards( userAlice, "Alice", userAliceExpectedRewards , DELTA_0_31 );

        userBobExpectedRewards = expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION );
        userBobExpectedRewards-= userBobClaimedRewards;
        checkStakingRewards( userBob, "Bob", userBobExpectedRewards , DELTA_0_31 );

        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
/*
    function testUsersStakingRewards() public {
        checkRewardPerToken( 0 , 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        checkUsersStake();
        verboseLog( "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );
        checkStakingPeriod( STAKING_PERCENTAGE_DURATION / DIVIDE );

        verboseLog( "Staking duration reached (%%) before withdrawal(s) = : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
        // Alice withdraws all
        withdrawStake( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT );
        // Bob withdraws all
        withdrawStake( userBob, BOB_STAKINGERC20_STAKEDAMOUNT );

        uint256 usersStakingElapsedTime = block.timestamp - STAKING_START_TIME;
        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        verboseLog( "Staking duration (%%) : ", STAKING_PERCENTAGE_DURATION );

        uint256 delta = STAKING_PERCENTAGE_DURATION < PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period = better accuracy : less delta
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );
        checkStakingRewards( userBob, "Bob", expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );

        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
 */
}

// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage duration

contract DuringStaking3_WithWithdral is DepositSetup3 {

    // TODO: change to a constructor parameter and improve accuracy (e.g. 1e18)
    uint8 immutable DIVIDE = 2; // Liquidity is withdrawn at 50% of the staking duration

    // constructor (uint256 _stakingPercentageDuration) {
    //     STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    // }
    constructor (uint256 _stakingPercentageDuration, uint256 _claimPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
        // require(_claimPercentageDuration <= _stakingPercentageDuration, "DuringStaking1_WithoutWithdral: _claimPercentageDuration > _stakingPercentageDuration");
        CLAIM_PERCENTAGE_DURATION = _claimPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithWithdral setUp() start");
        DepositSetup3.setUp();
        // console.log("DuringStaking3_WithWithdral");
        debugLog("DuringStaking3_WithWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards2.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog(" staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
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

    function getRewardDurationReached() internal view returns (uint256) {
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getRewardDurationReached(uint _durationReached) internal pure returns (uint256) {
        uint256 rewardDurationReached = (_durationReached >= REWARD_INITIAL_DURATION ? REWARD_INITIAL_DURATION : _durationReached);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }


    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    function getStakingDuration() internal view returns (uint256) {
        uint256 stakingDuration = REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / PERCENT_100;
        verboseLog( "getStakingDuration: stakingDuration = ",  stakingDuration);
        return stakingDuration;
    }

    function getRewardedStakingDuration(uint8 _divide) internal view returns (uint256) {
        uint256 stakingDuration = getStakingDuration() / _divide;
        verboseLog( "getRewardedStakingDuration: stakingDuration = ",  stakingDuration);
        uint256 rewardedStakingDuration = getRewardDurationReached( stakingDuration );
        verboseLog( "getRewardedStakingDuration: rewardedStakingDuration = ",  rewardedStakingDuration);
        return rewardedStakingDuration;
    }

    // Goto some staking time within period
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    function checkStakingPeriod(uint256 _stakingPercentageDurationReached) public {
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "checkStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        // uint256 stakingTimeReached = getStakingTimeReached();
        uint256 stakingTimeReached = STAKING_START_TIME + (_stakingPercentageDurationReached >= PERCENT_100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / PERCENT_100);
        uint256 lastTimeReward = stakingRewards2.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
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

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _rewardDurationReached, uint256 _rewardTotalDuration) public view returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_rewardDurationReached, _rewardTotalDuration);

        return (rewardsDuration == _rewardTotalDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardTotalDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function withdrawStake(address _user, uint256 _amount) public {
        uint256 balanceOfUserBeforeWithdrawal = stakingRewards2.balanceOf(_user);
        // Check emitted event
        vm.expectEmit(true,true,false,false, address(stakingRewards2));
        emit StakingRewards2.Withdrawn( _user, _amount );
        vm.prank(_user);
        stakingRewards2.withdraw( _amount );
        uint256 balanceOfUserAfterWithdrawal = stakingRewards2.balanceOf(_user);
        assertEq( balanceOfUserBeforeWithdrawal - _amount, balanceOfUserAfterWithdrawal );
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken( 0 , 0 );
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        checkUsersStake();
        verboseLog( "Staking duration (%%) = STAKING_PERCENTAGE_DURATION / 2  : ", STAKING_PERCENTAGE_DURATION / DIVIDE );
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
        uint256 expectedRewardPerToken = REWARD_INITIAL_AMOUNT * getRewardedStakingDuration(DIVIDE) * ONE_TOKEN / REWARD_INITIAL_DURATION / TOTAL_STAKED_AMOUNT;

        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        verboseLog( "Staking duration (%%) : ", STAKING_PERCENTAGE_DURATION );

        uint256 delta = STAKING_PERCENTAGE_DURATION <= PERCENT_10 ? DELTA_0_4 : DELTA_0_04; // Longer staking period = better accuracy : less delta
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );
        checkStakingRewards( userBob, "Bob", expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );
        checkStakingRewards( userCherry, "Cherry", expectedStakingRewards( CHERRY_STAKINGERC20_STAKEDAMOUNT, usersStakingElapsedTime, REWARD_INITIAL_DURATION ) , delta );

        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
}


// ----------------------------------------------------------------------------


// 1 staker deposits right after staking starts and keeps staked amount until the end of staking period
/*
contract DuringStaking1_WithoutWithdral_0 is DuringStaking1_WithoutWithdral(PERCENT_0, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_1_0_1 is DuringStaking1_WithoutWithdral(PERCENT_1, PERCENT_0_1) {
}
contract DuringStaking1_WithoutWithdral_10__0 is DuringStaking1_WithoutWithdral(PERCENT_10, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_10__5 is DuringStaking1_WithoutWithdral(PERCENT_10, PERCENT_5) {
}
contract DuringStaking1_WithoutWithdral_20__0 is DuringStaking1_WithoutWithdral(PERCENT_20, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_20__10 is DuringStaking1_WithoutWithdral(PERCENT_20, PERCENT_10) {
}
contract DuringStaking1_WithoutWithdral_30__0 is DuringStaking1_WithoutWithdral(PERCENT_30, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_30__20 is DuringStaking1_WithoutWithdral(PERCENT_30, PERCENT_20) {
}
contract DuringStaking1_WithoutWithdral_33__0 is DuringStaking1_WithoutWithdral(PERCENT_33, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_33__10 is DuringStaking1_WithoutWithdral(PERCENT_33, PERCENT_10) {
}
contract DuringStaking1_WithoutWithdral_40__0 is DuringStaking1_WithoutWithdral(PERCENT_40, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_40__5 is DuringStaking1_WithoutWithdral(PERCENT_40, PERCENT_5) {
}
contract DuringStaking1_WithoutWithdral_50__0 is DuringStaking1_WithoutWithdral(PERCENT_50, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_50__5 is DuringStaking1_WithoutWithdral(PERCENT_50, PERCENT_5) {
}
contract DuringStaking1_WithoutWithdral_60__0 is DuringStaking1_WithoutWithdral(PERCENT_60, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_60__20 is DuringStaking1_WithoutWithdral(PERCENT_60, PERCENT_20) {
}
contract DuringStaking1_WithoutWithdral_66__0 is DuringStaking1_WithoutWithdral(PERCENT_66, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_66__30 is DuringStaking1_WithoutWithdral(PERCENT_66, PERCENT_30) {
}
contract DuringStaking1_WithoutWithdral_70__0 is DuringStaking1_WithoutWithdral(PERCENT_70, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_70__10 is DuringStaking1_WithoutWithdral(PERCENT_70, PERCENT_10) {
}
contract DuringStaking1_WithoutWithdral_80__0 is DuringStaking1_WithoutWithdral(PERCENT_80, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_80__70 is DuringStaking1_WithoutWithdral(PERCENT_80, PERCENT_70) {
}
contract DuringStaking1_WithoutWithdral_90__0 is DuringStaking1_WithoutWithdral(PERCENT_90, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_90__50 is DuringStaking1_WithoutWithdral(PERCENT_90, PERCENT_50) {
}
contract DuringStaking1_WithoutWithdral_99__0 is DuringStaking1_WithoutWithdral(PERCENT_99, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_99__33 is DuringStaking1_WithoutWithdral(PERCENT_99, PERCENT_33) {
}
contract DuringStaking1_WithoutWithdral_100__0 is DuringStaking1_WithoutWithdral(PERCENT_100, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_100__30 is DuringStaking1_WithoutWithdral(PERCENT_100, PERCENT_30) {
}
contract DuringStaking1_WithoutWithdral_101__0 is DuringStaking1_WithoutWithdral(PERCENT_101, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_101__50 is DuringStaking1_WithoutWithdral(PERCENT_101, PERCENT_50) {
}
contract DuringStaking1_WithoutWithdral_110__0 is DuringStaking1_WithoutWithdral(PERCENT_110, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_110__60 is DuringStaking1_WithoutWithdral(PERCENT_110, PERCENT_60) {
}
contract DuringStaking1_WithoutWithdral_150__0 is DuringStaking1_WithoutWithdral(PERCENT_150, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_150__70 is DuringStaking1_WithoutWithdral(PERCENT_150, PERCENT_70) {
}
contract DuringStaking1_WithoutWithdral_190__0 is DuringStaking1_WithoutWithdral(PERCENT_190, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_190__80 is DuringStaking1_WithoutWithdral(PERCENT_190, PERCENT_80) {
}
contract DuringStaking1_WithoutWithdral_200__0 is DuringStaking1_WithoutWithdral(PERCENT_200, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_200__90 is DuringStaking1_WithoutWithdral(PERCENT_200, PERCENT_90) {
}
contract DuringStaking1_WithoutWithdral_201__0 is DuringStaking1_WithoutWithdral(PERCENT_201, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_201__90 is DuringStaking1_WithoutWithdral(PERCENT_201, PERCENT_90) {
}
contract DuringStaking1_WithoutWithdral_220__0 is DuringStaking1_WithoutWithdral(PERCENT_220, PERCENT_0) {
}
contract DuringStaking1_WithoutWithdral_220__99 is DuringStaking1_WithoutWithdral(PERCENT_220, PERCENT_99) {
}
*/
// ------------------------------------

// 2 stakers deposit right after staking starts and keep staked amount until the end of staking period
/*
contract DuringStaking2_WithoutWithdral_0__0 is DuringStaking2_WithoutWithdral(PERCENT_0, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_1__0 is DuringStaking2_WithoutWithdral(PERCENT_1, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_1__0_1 is DuringStaking2_WithoutWithdral(PERCENT_1, PERCENT_0_1) {
}
contract DuringStaking2_WithoutWithdral_10__0 is DuringStaking2_WithoutWithdral(PERCENT_10, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_10__5 is DuringStaking2_WithoutWithdral(PERCENT_10, PERCENT_5) {
}
contract DuringStaking2_WithoutWithdral_20__0 is DuringStaking2_WithoutWithdral(PERCENT_20, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_20__10 is DuringStaking2_WithoutWithdral(PERCENT_20, PERCENT_10) {
}
contract DuringStaking2_WithoutWithdral_30__ is DuringStaking2_WithoutWithdral(PERCENT_30, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_30__20 is DuringStaking2_WithoutWithdral(PERCENT_30, PERCENT_20) {
}
contract DuringStaking2_WithoutWithdral_33__0 is DuringStaking2_WithoutWithdral(PERCENT_33, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_33__10 is DuringStaking2_WithoutWithdral(PERCENT_33, PERCENT_10) {
}
contract DuringStaking2_WithoutWithdral_40__ is DuringStaking2_WithoutWithdral(PERCENT_40, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_40__5 is DuringStaking2_WithoutWithdral(PERCENT_40, PERCENT_5) {
}
contract DuringStaking2_WithoutWithdral_50__0 is DuringStaking2_WithoutWithdral(PERCENT_50, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_50__5 is DuringStaking2_WithoutWithdral(PERCENT_50, PERCENT_5) {
}
contract DuringStaking2_WithoutWithdral_60__0 is DuringStaking2_WithoutWithdral(PERCENT_60, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_60__20 is DuringStaking2_WithoutWithdral(PERCENT_60, PERCENT_20) {
}
contract DuringStaking2_WithoutWithdral_66__0 is DuringStaking2_WithoutWithdral(PERCENT_66, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_66__30 is DuringStaking2_WithoutWithdral(PERCENT_66, PERCENT_30) {
}
contract DuringStaking2_WithoutWithdral_70__0 is DuringStaking2_WithoutWithdral(PERCENT_70, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_70__10 is DuringStaking2_WithoutWithdral(PERCENT_70, PERCENT_10) {
}
contract DuringStaking2_WithoutWithdral_80__0 is DuringStaking2_WithoutWithdral(PERCENT_80, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_80__70 is DuringStaking2_WithoutWithdral(PERCENT_80, PERCENT_70) {
}
contract DuringStaking2_WithoutWithdral_90__0 is DuringStaking2_WithoutWithdral(PERCENT_90, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_90__50 is DuringStaking2_WithoutWithdral(PERCENT_90, PERCENT_50) {
}
contract DuringStaking2_WithoutWithdral_99__0 is DuringStaking2_WithoutWithdral(PERCENT_99, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_99__33 is DuringStaking2_WithoutWithdral(PERCENT_99, PERCENT_33) {
}
contract DuringStaking2_WithoutWithdral_100__0 is DuringStaking2_WithoutWithdral(PERCENT_100, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_100__30 is DuringStaking2_WithoutWithdral(PERCENT_100, PERCENT_30) {
}
contract DuringStaking2_WithoutWithdral_101__0 is DuringStaking2_WithoutWithdral(PERCENT_101, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_101__50 is DuringStaking2_WithoutWithdral(PERCENT_101, PERCENT_50) {
}
contract DuringStaking2_WithoutWithdral_110__0 is DuringStaking2_WithoutWithdral(PERCENT_110, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_110__60 is DuringStaking2_WithoutWithdral(PERCENT_110, PERCENT_60) {
}
contract DuringStaking2_WithoutWithdral_150__0 is DuringStaking2_WithoutWithdral(PERCENT_150, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_150__70 is DuringStaking2_WithoutWithdral(PERCENT_150, PERCENT_70) {
}
contract DuringStaking2_WithoutWithdral_190__0 is DuringStaking2_WithoutWithdral(PERCENT_190, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_190__80 is DuringStaking2_WithoutWithdral(PERCENT_190, PERCENT_80) {
}
contract DuringStaking2_WithoutWithdral_200__0 is DuringStaking2_WithoutWithdral(PERCENT_200, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_200__90 is DuringStaking2_WithoutWithdral(PERCENT_200, PERCENT_90) {
}
contract DuringStaking2_WithoutWithdral_201__0 is DuringStaking2_WithoutWithdral(PERCENT_201, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_201__90 is DuringStaking2_WithoutWithdral(PERCENT_201, PERCENT_90) {
}
contract DuringStaking2_WithoutWithdral_220__0 is DuringStaking2_WithoutWithdral(PERCENT_220, PERCENT_0) {
}
contract DuringStaking2_WithoutWithdral_220__99 is DuringStaking2_WithoutWithdral(PERCENT_220, PERCENT_99) {
}
*/
// ------------------------------------

// 3 stakers deposit right after staking starts and keep staked amount until the end of staking period
/*
contract DuringStaking3_WithoutWithdral_0 is DuringStaking3_WithoutWithdral(PERCENT_0, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_1_0_1 is DuringStaking3_WithoutWithdral(PERCENT_1, PERCENT_0_1) {
}
contract DuringStaking3_WithoutWithdral_10__0 is DuringStaking3_WithoutWithdral(PERCENT_10, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_10__5 is DuringStaking3_WithoutWithdral(PERCENT_10, PERCENT_5) {
}
contract DuringStaking3_WithoutWithdral_20__0 is DuringStaking3_WithoutWithdral(PERCENT_20, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_20__10 is DuringStaking3_WithoutWithdral(PERCENT_20, PERCENT_10) {
}
contract DuringStaking3_WithoutWithdral_30__0 is DuringStaking3_WithoutWithdral(PERCENT_30, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_30__20 is DuringStaking3_WithoutWithdral(PERCENT_30, PERCENT_20) {
}
contract DuringStaking3_WithoutWithdral_33__0 is DuringStaking3_WithoutWithdral(PERCENT_33, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_33__10 is DuringStaking3_WithoutWithdral(PERCENT_33, PERCENT_10) {
}
contract DuringStaking3_WithoutWithdral_40__0 is DuringStaking3_WithoutWithdral(PERCENT_40, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_40__5 is DuringStaking3_WithoutWithdral(PERCENT_40, PERCENT_5) {
}
contract DuringStaking3_WithoutWithdral_50__0 is DuringStaking3_WithoutWithdral(PERCENT_50, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_50__5 is DuringStaking3_WithoutWithdral(PERCENT_50, PERCENT_5) {
}
contract DuringStaking3_WithoutWithdral_60__0 is DuringStaking3_WithoutWithdral(PERCENT_60, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_60__20 is DuringStaking3_WithoutWithdral(PERCENT_60, PERCENT_20) {
}
contract DuringStaking3_WithoutWithdral_66__0 is DuringStaking3_WithoutWithdral(PERCENT_66, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_66__30 is DuringStaking3_WithoutWithdral(PERCENT_66, PERCENT_30) {
}
contract DuringStaking3_WithoutWithdral_70__0 is DuringStaking3_WithoutWithdral(PERCENT_70, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_70__10 is DuringStaking3_WithoutWithdral(PERCENT_70, PERCENT_10) {
}
contract DuringStaking3_WithoutWithdral_80__0 is DuringStaking3_WithoutWithdral(PERCENT_80, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_80__70 is DuringStaking3_WithoutWithdral(PERCENT_80, PERCENT_70) {
}
contract DuringStaking3_WithoutWithdral_90__0 is DuringStaking3_WithoutWithdral(PERCENT_90, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_90__50 is DuringStaking3_WithoutWithdral(PERCENT_90, PERCENT_50) {
}
contract DuringStaking3_WithoutWithdral_99__0 is DuringStaking3_WithoutWithdral(PERCENT_99, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_99__33 is DuringStaking3_WithoutWithdral(PERCENT_99, PERCENT_33) {
}
contract DuringStaking3_WithoutWithdral_100__0 is DuringStaking3_WithoutWithdral(PERCENT_100, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_100__30 is DuringStaking3_WithoutWithdral(PERCENT_100, PERCENT_30) {
}
contract DuringStaking3_WithoutWithdral_101__0 is DuringStaking3_WithoutWithdral(PERCENT_101, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_101__50 is DuringStaking3_WithoutWithdral(PERCENT_101, PERCENT_50) {
}
contract DuringStaking3_WithoutWithdral_110__0 is DuringStaking3_WithoutWithdral(PERCENT_110, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_110__60 is DuringStaking3_WithoutWithdral(PERCENT_110, PERCENT_60) {
}
contract DuringStaking3_WithoutWithdral_150__0 is DuringStaking3_WithoutWithdral(PERCENT_150, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_150__70 is DuringStaking3_WithoutWithdral(PERCENT_150, PERCENT_70) {
}
contract DuringStaking3_WithoutWithdral_190__0 is DuringStaking3_WithoutWithdral(PERCENT_190, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_190__80 is DuringStaking3_WithoutWithdral(PERCENT_190, PERCENT_80) {
}
contract DuringStaking3_WithoutWithdral_200__0 is DuringStaking3_WithoutWithdral(PERCENT_200, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_200__90 is DuringStaking3_WithoutWithdral(PERCENT_200, PERCENT_90) {
}
contract DuringStaking3_WithoutWithdral_201__0 is DuringStaking3_WithoutWithdral(PERCENT_201, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_201__90 is DuringStaking3_WithoutWithdral(PERCENT_201, PERCENT_90) {
}
contract DuringStaking3_WithoutWithdral_220__0 is DuringStaking3_WithoutWithdral(PERCENT_220, PERCENT_0) {
}
contract DuringStaking3_WithoutWithdral_220__99 is DuringStaking3_WithoutWithdral(PERCENT_220, PERCENT_99) {
}
*/
// ------------------------------------

// 1 staker deposit right after staking starts and removes all staked amount after half of staking percentage duration
// 42 tests
// /*
contract DuringStaking1_WithWithdral__0 is DuringStaking1_WithWithdral(PERCENT_0, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__1_0_1 is DuringStaking1_WithWithdral(PERCENT_1, PERCENT_0_1) {
}
contract DuringStaking1_WithWithdral__10__0 is DuringStaking1_WithWithdral(PERCENT_10, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__10__5 is DuringStaking1_WithWithdral(PERCENT_10, PERCENT_5) {
}
contract DuringStaking1_WithWithdral__20__0 is DuringStaking1_WithWithdral(PERCENT_20, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__20__10 is DuringStaking1_WithWithdral(PERCENT_20, PERCENT_10) {
}
contract DuringStaking1_WithWithdral__30__0 is DuringStaking1_WithWithdral(PERCENT_30, PERCENT_0) {
}

contract DuringStaking1_WithWithdral__30__20 is DuringStaking1_WithWithdral(PERCENT_30, PERCENT_15) {
}

contract DuringStaking1_WithWithdral__33__0 is DuringStaking1_WithWithdral(PERCENT_33, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__33__10 is DuringStaking1_WithWithdral(PERCENT_33, PERCENT_10) {
}
contract DuringStaking1_WithWithdral__40__0 is DuringStaking1_WithWithdral(PERCENT_40, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__40__5 is DuringStaking1_WithWithdral(PERCENT_40, PERCENT_5) {
}
contract DuringStaking1_WithWithdral__50__0 is DuringStaking1_WithWithdral(PERCENT_50, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__50__5 is DuringStaking1_WithWithdral(PERCENT_50, PERCENT_5) {
}
contract DuringStaking1_WithWithdral__60__0 is DuringStaking1_WithWithdral(PERCENT_60, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__60__20 is DuringStaking1_WithWithdral(PERCENT_60, PERCENT_20) {
}
contract DuringStaking1_WithWithdral__66__0 is DuringStaking1_WithWithdral(PERCENT_66, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__66__30 is DuringStaking1_WithWithdral(PERCENT_66, PERCENT_30) {
}
contract DuringStaking1_WithWithdral__70__0 is DuringStaking1_WithWithdral(PERCENT_70, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__70__10 is DuringStaking1_WithWithdral(PERCENT_70, PERCENT_10) {
}
contract DuringStaking1_WithWithdral__80__0 is DuringStaking1_WithWithdral(PERCENT_80, PERCENT_0) {
}

contract DuringStaking1_WithWithdral__80__70 is DuringStaking1_WithWithdral(PERCENT_80, PERCENT_30) {
}

contract DuringStaking1_WithWithdral__90__0 is DuringStaking1_WithWithdral(PERCENT_90, PERCENT_0) {
}

contract DuringStaking1_WithWithdral__90__50 is DuringStaking1_WithWithdral(PERCENT_90, PERCENT_45) {
}

contract DuringStaking1_WithWithdral__99__0 is DuringStaking1_WithWithdral(PERCENT_99, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__99__33 is DuringStaking1_WithWithdral(PERCENT_99, PERCENT_33) {
}
contract DuringStaking1_WithWithdral__100__0 is DuringStaking1_WithWithdral(PERCENT_100, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__100__30 is DuringStaking1_WithWithdral(PERCENT_100, PERCENT_30) {
}
contract DuringStaking1_WithWithdral__101__0 is DuringStaking1_WithWithdral(PERCENT_101, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__101__50 is DuringStaking1_WithWithdral(PERCENT_101, PERCENT_50) {
}
contract DuringStaking1_WithWithdral__110__0 is DuringStaking1_WithWithdral(PERCENT_110, PERCENT_0) {
}

contract DuringStaking1_WithWithdral__110__60 is DuringStaking1_WithWithdral(PERCENT_110, PERCENT_40) {
}

contract DuringStaking1_WithWithdral__150__0 is DuringStaking1_WithWithdral(PERCENT_150, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__150__70 is DuringStaking1_WithWithdral(PERCENT_150, PERCENT_70) {
}
contract DuringStaking1_WithWithdral__190__0 is DuringStaking1_WithWithdral(PERCENT_190, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__190__80 is DuringStaking1_WithWithdral(PERCENT_190, PERCENT_80) {
}
contract DuringStaking1_WithWithdral__200__0 is DuringStaking1_WithWithdral(PERCENT_200, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__200__90 is DuringStaking1_WithWithdral(PERCENT_200, PERCENT_90) {
}
contract DuringStaking1_WithWithdral__201__0 is DuringStaking1_WithWithdral(PERCENT_201, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__201__90 is DuringStaking1_WithWithdral(PERCENT_201, PERCENT_90) {
}
contract DuringStaking1_WithWithdral__220__0 is DuringStaking1_WithWithdral(PERCENT_220, PERCENT_0) {
}
contract DuringStaking1_WithWithdral__220__99 is DuringStaking1_WithWithdral(PERCENT_220, PERCENT_99) {
}
// */
// ------------------------------------

// 2 stakers deposit right after staking starts and removes all staked amount after half of staking percentage duration
/*
contract DuringStaking2_WithWithdral_0__ is DuringStaking2_WithWithdral(0) {
}
contract DuringStaking2_WithWithdral_1__ is DuringStaking2_WithWithdral(PERCENT_1) {
}
contract DuringStaking2_WithWithdral_10__ is DuringStaking2_WithWithdral(PERCENT_10) {
}
contract DuringStaking2_WithWithdral_20__ is DuringStaking2_WithWithdral(PERCENT_20) {
}
contract DuringStaking2_WithWithdral_30__ is DuringStaking2_WithWithdral(PERCENT_30) {
}
contract DuringStaking2_WithWithdral_33__ is DuringStaking2_WithWithdral(PERCENT_33) {
}
contract DuringStaking2_WithWithdral_40__ is DuringStaking2_WithWithdral(PERCENT_40) {
}
contract DuringStaking2_WithWithdral_50__ is DuringStaking2_WithWithdral(PERCENT_50) {
}
contract DuringStaking2_WithWithdral_60__ is DuringStaking2_WithWithdral(PERCENT_60) {
}
contract DuringStaking2_WithWithdral_66__ is DuringStaking2_WithWithdral(PERCENT_66) {
}
contract DuringStaking2_WithWithdral_70__ is DuringStaking2_WithWithdral(PERCENT_70) {
}
contract DuringStaking2_WithWithdral_80__ is DuringStaking2_WithWithdral(PERCENT_80) {
}
contract DuringStaking2_WithWithdral_90__ is DuringStaking2_WithWithdral(PERCENT_90) {
}
contract DuringStaking2_WithWithdral_99__ is DuringStaking2_WithWithdral(PERCENT_99) {
}
contract DuringStaking2_WithWithdral_100__ is DuringStaking2_WithWithdral(PERCENT_100) {
}
contract DuringStaking2_WithWithdral_101__ is DuringStaking2_WithWithdral(PERCENT_101) {
}
contract DuringStaking2_WithWithdral_110__ is DuringStaking2_WithWithdral(PERCENT_110) {
}
contract DuringStaking2_WithWithdral_150__ is DuringStaking2_WithWithdral(PERCENT_150) {
}
contract DuringStaking2_WithWithdral_190__ is DuringStaking2_WithWithdral(PERCENT_190) {
}
contract DuringStaking2_WithWithdral_200__ is DuringStaking2_WithWithdral(PERCENT_200) {
}
contract DuringStaking2_WithWithdral_201__ is DuringStaking2_WithWithdral(PERCENT_201) {
}
contract DuringStaking2_WithWithdral_220__ is DuringStaking2_WithWithdral(PERCENT_220) {
}
*/
// ------------------------------------

// 3 stakers deposit right after staking starts and removes all staked amount after half of staking percentage duration
/*
contract DuringStaking3_WithWithdral_0__ is DuringStaking3_WithWithdral(0) {
}
contract DuringStaking3_WithWithdral_1__ is DuringStaking3_WithWithdral(PERCENT_1) {
}
contract DuringStaking3_WithWithdral_10__ is DuringStaking3_WithWithdral(PERCENT_10) {
}
contract DuringStaking3_WithWithdral_20__ is DuringStaking3_WithWithdral(PERCENT_20) {
}
contract DuringStaking3_WithWithdral_30__ is DuringStaking3_WithWithdral(PERCENT_30) {
}
contract DuringStaking3_WithWithdral_33__ is DuringStaking3_WithWithdral(PERCENT_33) {
}
contract DuringStaking3_WithWithdral_40__ is DuringStaking3_WithWithdral(PERCENT_40) {
}
contract DuringStaking3_WithWithdral_50__ is DuringStaking3_WithWithdral(PERCENT_50) {
}
contract DuringStaking3_WithWithdral_60__ is DuringStaking3_WithWithdral(PERCENT_60) {
}
contract DuringStaking3_WithWithdral_66__ is DuringStaking3_WithWithdral(PERCENT_66) {
}
contract DuringStaking3_WithWithdral_70__ is DuringStaking3_WithWithdral(PERCENT_70) {
}
contract DuringStaking3_WithWithdral_80__ is DuringStaking3_WithWithdral(PERCENT_80) {
}
contract DuringStaking3_WithWithdral_90__ is DuringStaking3_WithWithdral(PERCENT_90) {
}
contract DuringStaking3_WithWithdral_99__ is DuringStaking3_WithWithdral(PERCENT_99) {
}
contract DuringStaking3_WithWithdral_100__ is DuringStaking3_WithWithdral(PERCENT_100) {
}
contract DuringStaking3_WithWithdral_101__ is DuringStaking3_WithWithdral(PERCENT_101) {
}
contract DuringStaking3_WithWithdral_110__ is DuringStaking3_WithWithdral(PERCENT_110) {
}
contract DuringStaking3_WithWithdral_150__ is DuringStaking3_WithWithdral(PERCENT_150) {
}
contract DuringStaking3_WithWithdral_190__ is DuringStaking3_WithWithdral(PERCENT_190) {
}
contract DuringStaking3_WithWithdral_200__ is DuringStaking3_WithWithdral(PERCENT_200) {
}
contract DuringStaking3_WithWithdral_201__ is DuringStaking3_WithWithdral(PERCENT_201) {
}
contract DuringStaking3_WithWithdral_220__ is DuringStaking3_WithWithdral(PERCENT_220) {
}
*/
// --------------------------------------------------------

/*
contract CheckStakingPermissions2 is StakingSetup2 {

    function setUp() public virtual override {
        // console.log("CheckStakingPermissions2 setUp()");
        debugLog("CheckStakingPermissions2 setUp() start");
        StakingSetup2.setUp();
        debugLog("CheckStakingPermissions2 setUp() end");
    }

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

    function testStakingNotifyRewardAmountMin() public {

        verboseLog( "Only staking reward contract owner can notifyRewardAmount" );

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );

        stakingRewards2.notifyRewardAmount( 1 );
        verboseLog( "Staking contract: Alice can't notifyRewardAmount" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );

        stakingRewards2.notifyRewardAmount( 1 );
        verboseLog( "Staking contract: Bob can't notifyRewardAmount" );

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardAdded( 1 );
        stakingRewards2.notifyRewardAmount( 1 );
        verboseLog( "Staking contract: Only owner can notifyRewardAmount of ", 1 );
        verboseLog( "Staking contract: Event RewardAdded emitted" );
    }

    function testStakingNotifyRewardAmount0() public {

        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardAdded( 0 );
        stakingRewards2.notifyRewardAmount( 0 );
        verboseLog( "Staking contract: Only owner can notifyRewardAmount of ", 0 );
        verboseLog( "Staking contract: Event RewardAdded emitted" );
    }

    function testStakingNotifyRewardAmountLimit1() public {

        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION; // computed  reward rate must exceed by at least one unit for raising an error
        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardAdded( rewardAmountToAddForRaisingError -1 );
        stakingRewards2.notifyRewardAmount( rewardAmountToAddForRaisingError -1 );
        verboseLog( "Staking contract: Only owner can notifyRewardAmount of ", rewardAmountToAddForRaisingError - 1 );
        verboseLog( "Staking contract: Event RewardAdded emitted" );
    }

    function testStakingNotifyRewardAmountLimitMax() public {

        uint256 additionnalRewardAmount = REWARD_INITIAL_DURATION;

        // Mint reward ERC20 a second time
        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), additionnalRewardAmount );
        vm.prank(userStakingRewardAdmin);
        // Check emitted event
        vm.expectEmit(true,false,false,false, address(stakingRewards2));
        emit StakingRewards2.RewardAdded( additionnalRewardAmount );
        stakingRewards2.notifyRewardAmount( additionnalRewardAmount );
        verboseLog( "Staking contract: Only owner can notifyRewardAmount of an additionnal ", additionnalRewardAmount );
        verboseLog( "Staking contract: Event RewardAdded emitted" );
    }


    function testStakingRewardAmountTooHigh1() public {

        // vm.warp( STAKING_START_TIME ); // start of staking period
        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION;  // computed  reward rate must exceed by at least one unit for raising an error

       vm.prank(userStakingRewardAdmin);
        // Check revert
        vm.expectRevert(
            abi.encodeWithSelector( IStakingRewards2Errors.ProvidedRewardTooHigh.selector, rewardAmountToAddForRaisingError, REWARD_INITIAL_AMOUNT, REWARD_INITIAL_DURATION )
        );
        stakingRewards2.notifyRewardAmount( rewardAmountToAddForRaisingError );
        verboseLog( "Staking contract: Not enough reward balance" );
    }

    function testStakingRewardAmountTooHigh2() public {

        uint256 rewardAmountToAddForRaisingError = REWARD_INITIAL_DURATION;  // computed  reward rate must exceed by at least one unit for raising an error

        // Mint reward ERC20 a second time
        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards2), rewardAmountToAddForRaisingError );

        // vm.warp( STAKING_START_TIME ); // start of staking period

        vm.prank(userStakingRewardAdmin);
        // Check revert
        vm.expectRevert(
            abi.encodeWithSelector( IStakingRewards2Errors.ProvidedRewardTooHigh.selector, rewardAmountToAddForRaisingError * 2, REWARD_INITIAL_AMOUNT + rewardAmountToAddForRaisingError, REWARD_INITIAL_DURATION )
        );
        stakingRewards2.notifyRewardAmount( rewardAmountToAddForRaisingError * 2 );

        verboseLog( "Staking contract: Only owner can notifyRewardAmount of ", rewardAmountToAddForRaisingError + 1 );
        verboseLog( "Staking contract: Event RewardAdded emitted" );

    }

    function testStakingSetRewardsDuration() public {

        // Previous reward epoch must have ended before setting a new duration
        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );
        verboseLog( "Only staking reward contract owner can setRewardsDuration" );

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
*/
