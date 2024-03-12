// SPDX-License-Identifier: UNLICENSED
// pragma solidity >= 0.8.20 < 0.9.0;
// pragma solidity ^0.8.23;
// pragma solidity >= 0.8.20;
// pragma solidity ^0.7.6;
// pragma solidity >= 0.7.6 <= 0.8.0;
// pragma solidity >= 0.7.6;
pragma solidity >=0.8.0;

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
    function debugLogTime(string memory _msg) public view {
        if (debug) console.log(_msg, " ts: ", block.timestamp);
    }
    function debugLogTime(string memory _msg, uint _val256) public view {
        if (debug) console.log(_msg, _val256, " ts: ", block.timestamp);
    }
    function verboseLog(string memory _msg) public view {
        if (verbose) console.log(_msg);
    }
    function verboseLog(string memory _msg, uint _val256) public view {
        if (verbose) console.log(_msg, _val256);
    }
    function verboseLogTime(string memory _msg) public view {
        if (verbose) console.log(_msg, " ts: ", block.timestamp);
    }
    function verboseLogTime(string memory _msg, uint _val256) public view {
        if (verbose) console.log(_msg, _val256, " ts: ", block.timestamp);
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
    uint256 constant ALICE_STAKINGERC20_MINTEDAMOUNT = 2e18;


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
    uint256 constant ALICE_STAKINGERC20_MINTEDAMOUNT = 2e18;
    uint256 constant BOB_STAKINGERC20_MINTEDAMOUNT = 1e18;


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
    uint256 constant ALICE_STAKINGERC20_MINTEDAMOUNT = 3e18;
    uint256 constant BOB_STAKINGERC20_MINTEDAMOUNT = 2e18;
    uint256 constant CHERRY_STAKINGERC20_MINTEDAMOUNT = 1e18;


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

contract StakingSetup1 is Erc20Setup1 {

    StakingRewards2 internal stakingRewards;
    uint256 constant internal REWARD_INITIAL_AMOUNT = 100_000; // 10e5
    uint256 constant internal REWARD_INITIAL_DURATION = 10_000; // 10 000 s.

    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;

    uint256 immutable STAKING_START_TIME = block.timestamp;

    function setUp() public virtual override {
        // console.log("StakingSetup1 setUp()");
        debugLog("StakingSetup1 setUp() start");
        Erc20Setup1.setUp();
        vm.prank( userStakingRewardAdmin );
        stakingRewards = new StakingRewards2( address(rewardErc20), address(stakingERC20) );
        assertEq( userStakingRewardAdmin, stakingRewards.owner(), "stakingRewards: Wrong owner" );

        vm.prank( userStakingRewardAdmin );
        stakingRewards.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards), REWARD_INITIAL_AMOUNT );

        vm.prank( userStakingRewardAdmin );
        stakingRewards.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup1 setUp() end");
    }

    function checkRewardPerToken(uint256 _expectedRewardPerToken, uint256 _delta) public {
        uint256 stakingRewardsRewardPerToken = stakingRewards.rewardPerToken();
        verboseLog( "checkRewardPerToken rewardPerToken = ", stakingRewards.rewardPerToken() );
        if ( _delta == 0 ) {
            assertEq( _expectedRewardPerToken, stakingRewardsRewardPerToken, "Unexpected rewardPerToken() value");

        } else {
            assertApproxEqRel( _expectedRewardPerToken, stakingRewardsRewardPerToken, _delta, "Unexpected rewardPerToken() value");
        }
    }

    function checkRewardForDuration() public {
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards.getRewardForDuration( );
        verboseLog( "checkRewardForDuration: getRewardForDuration = ", stakingRewards.getRewardForDuration() );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        rewardForDuration = stakingRewards.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended
        rewardForDuration = stakingRewards.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        verboseLog( "Staking contract: rewardsDuration ok" );
    }
}

// ----------------

contract StakingSetup2 is Erc20Setup2 {

    StakingRewards2 internal stakingRewards;
    uint256 constant internal REWARD_INITIAL_AMOUNT = 100_000; // 10e5
    uint256 constant internal REWARD_INITIAL_DURATION = 10_000; // 10 000 s.

    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;

    uint256 immutable STAKING_START_TIME = block.timestamp;

    function setUp() public virtual override {
        // console.log("StakingSetup2 setUp()");
        debugLog("StakingSetup2 setUp() start");
        Erc20Setup2.setUp();
        vm.prank( userStakingRewardAdmin );
        stakingRewards = new StakingRewards2( address(rewardErc20), address(stakingERC20) );
        assertEq( userStakingRewardAdmin, stakingRewards.owner(), "stakingRewards: Wrong owner" );

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards), bytes4(keccak256("setRewardsDuration")) );

        vm.prank( userStakingRewardAdmin );
        stakingRewards.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards), REWARD_INITIAL_AMOUNT );

        vm.prank( userStakingRewardAdmin );
        stakingRewards.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        // debugLog("Staking start time", stakingStartTime);
        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup2 setUp() end");
    }

    function checkRewardPerToken(uint256 _expectedRewardPerToken, uint256 _delta) public {
        uint256 stakingRewardsRewardPerToken = stakingRewards.rewardPerToken();
        verboseLog( "checkRewardPerToken rewardPerToken = ", stakingRewards.rewardPerToken() );
        if ( _delta == 0 ) {
            assertEq( _expectedRewardPerToken, stakingRewardsRewardPerToken, "Unexpected rewardPerToken() value");

        } else {
            assertApproxEqRel( _expectedRewardPerToken, stakingRewardsRewardPerToken, _delta, "Unexpected rewardPerToken() value");
        }
    }

    function checkRewardForDuration() public {
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards.getRewardForDuration( );
        verboseLog( "checkRewardForDuration: getRewardForDuration = ", stakingRewards.getRewardForDuration() );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        rewardForDuration = stakingRewards.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended
        rewardForDuration = stakingRewards.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        verboseLog( "Staking contract: rewardsDuration ok" );
    }
}

// ----------------

contract StakingSetup3 is Erc20Setup3 {

    StakingRewards2 internal stakingRewards;
    uint256 constant internal REWARD_INITIAL_AMOUNT = 100_000; // 10e5
    uint256 constant internal REWARD_INITIAL_DURATION = 10_000; // 10 000 s.

    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant CHERRY_STAKINGERC20_STAKEDAMOUNT = CHERRY_STAKINGERC20_MINTEDAMOUNT;

    uint256 immutable STAKING_START_TIME = block.timestamp;

    function setUp() public virtual override {
        // console.log("StakingSetup3 setUp()");
        debugLog("StakingSetup3 setUp() start");
        Erc20Setup3.setUp();
        vm.prank( userStakingRewardAdmin );
        stakingRewards = new StakingRewards2( address(rewardErc20), address(stakingERC20) );
        assertEq( userStakingRewardAdmin, stakingRewards.owner(), "stakingRewards: Wrong owner" );

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards), bytes4(keccak256("setRewardsDuration")) );

        vm.prank( userStakingRewardAdmin );
        stakingRewards.setRewardsDuration(REWARD_INITIAL_DURATION);

        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards), REWARD_INITIAL_AMOUNT );

        vm.prank( userStakingRewardAdmin );
        stakingRewards.notifyRewardAmount(REWARD_INITIAL_AMOUNT);

        // debugLog("Staking start time", stakingStartTime);
        debugLog("Staking start time", STAKING_START_TIME);
        debugLog("StakingSetup3 setUp() end");
    }

    function checkRewardPerToken(uint256 _expectedRewardPerToken, uint256 _delta) public {
        uint256 stakingRewardsRewardPerToken = stakingRewards.rewardPerToken();
        verboseLog( "checkRewardPerToken rewardPerToken = ", stakingRewards.rewardPerToken() );
        if ( _delta == 0 ) {
            assertEq( _expectedRewardPerToken, stakingRewardsRewardPerToken, "Unexpected rewardPerToken() value");

        } else {
            assertApproxEqRel( _expectedRewardPerToken, stakingRewardsRewardPerToken, _delta, "Unexpected rewardPerToken() value");
        }
    }

    function checkRewardForDuration() public {
        uint256 rewardForDuration;

        rewardForDuration = stakingRewards.getRewardForDuration( );
        verboseLog( "checkRewardForDuration: getRewardForDuration = ", stakingRewards.getRewardForDuration() );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        rewardForDuration = stakingRewards.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended
        rewardForDuration = stakingRewards.getRewardForDuration( );
        assertEq( rewardForDuration, REWARD_INITIAL_AMOUNT );

        verboseLog( "Staking contract: rewardsDuration ok" );
    }
}


// ------------------------------------

contract DepositSetup1 is StakingSetup1 {

    uint256 constant internal TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT;

    function setUp() public virtual override {
        // console.log("DepositSetup1 setUp()");
        debugLog("DepositSetup1 setUp() start");
        StakingSetup1.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve( address(stakingRewards), ALICE_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards.stake( ALICE_STAKINGERC20_STAKEDAMOUNT );
        // vm.startPrank(userBob);
        // stakingERC20.approve( address(stakingRewards), BOB_STAKINGERC20_STAKEDAMOUNT );
        // stakingRewards.stake( BOB_STAKINGERC20_STAKEDAMOUNT );
        vm.stopPrank();
        debugLog("DepositSetup1 setUp() end");
    }

    function checkStakingTotalSupplyStaked() public {
        // uint256 expectedTotalSupplyStaked = ALICE_STAKINGERC20_STAKEDAMOUNT;
        uint256 stakingRewardsTotalSupply = stakingRewards.totalSupply();
        // assertEq( expectedTotalSupplyStaked, stakingRewardsTotalSupply );
        assertEq( TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply );
        verboseLog( "checkStakingTotalSupplyStaked", stakingRewardsTotalSupply );
    }
}

// ----------------

contract DepositSetup2 is StakingSetup2 {

    uint256 constant internal TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;

    function setUp() public virtual override {
        // console.log("DepositSetup2 setUp()");
        debugLog("DepositSetup2 setUp() start");
        StakingSetup2.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve( address(stakingRewards), ALICE_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards.stake( ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.startPrank(userBob);
        stakingERC20.approve( address(stakingRewards), BOB_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards.stake( BOB_STAKINGERC20_STAKEDAMOUNT );
        vm.stopPrank();
        debugLog("DepositSetup2 setUp() end");
    }

    function checkStakingTotalSupplyStaked() public {
        // uint256 expectedTotalSupplyStaked = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;
        uint256 stakingRewardsTotalSupply = stakingRewards.totalSupply();
        // assertEq( expectedTotalSupplyStaked, stakingRewardsTotalSupply );
        assertEq( TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply );
        verboseLog( "checkStakingTotalSupplyStaked", stakingRewardsTotalSupply );
    }
}

// ----------------

contract DepositSetup3 is StakingSetup3 {

    uint256 constant internal TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT
        + BOB_STAKINGERC20_STAKEDAMOUNT + CHERRY_STAKINGERC20_STAKEDAMOUNT;

    function setUp() public virtual override {
        // console.log("DepositSetup3 setUp()");
        debugLog("DepositSetup3 setUp() start");
        StakingSetup3.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve( address(stakingRewards), ALICE_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards.stake( ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.startPrank(userBob);
        stakingERC20.approve( address(stakingRewards), BOB_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards.stake( BOB_STAKINGERC20_STAKEDAMOUNT );
        vm.startPrank(userCherry);
        stakingERC20.approve( address(stakingRewards), CHERRY_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards.stake( CHERRY_STAKINGERC20_STAKEDAMOUNT );
        vm.stopPrank();
        debugLog("DepositSetup3 setUp() end");
    }

    function checkStakingTotalSupplyStaked() public {
        // uint256 expectedTotalSupplyStaked = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;
        uint256 stakingRewardsTotalSupply = stakingRewards.totalSupply();
        // assertEq( expectedTotalSupplyStaked, stakingRewardsTotalSupply );
        assertEq( TOTAL_STAKED_AMOUNT, stakingRewardsTotalSupply );
        verboseLog( "checkStakingTotalSupplyStaked", stakingRewardsTotalSupply );
    }
}

// ----------------------------------------------------------------------------

contract DuringStaking1_WithoutWithdral is DepositSetup1 {

    uint256 immutable STAKING_PERCENTAGE_DURATION;

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithoutWithdral setUp() start");
        DepositSetup1.setUp();
        // console.log("DuringStaking1_WithoutWithdral");
        debugLog("DuringStaking1_WithoutWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards.balanceOf(address(_user));
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
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= 100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / 100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    /**
     * Goto some staking time within period
     */
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= 100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / 100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    // function gotoStakingPeriod() private {
    //     vm.warp( getStakingTimeReached() );
    // }

    function checkStakingPeriod() public {
        uint256 stakingTimeReached = getStakingTimeReached();
        uint256 lastTimeReward = stakingRewards.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {

        uint256 stakerRewards = stakingRewards.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _durationReached, uint256 _rewardDuration) public pure returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_durationReached, _rewardDuration);

        // verboseLog( "expectedStakingRewards _stakedAmount: ", _stakedAmount);
        // verboseLog( "expectedStakingRewards _durationReached: ", _durationReached );
        // verboseLog( "expectedStakingRewards _rewardDuration: ", _rewardDuration);
        // verboseLog( "expectedStakingRewards rewardsDuration: ", rewardsDuration);
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT: ", REWARD_INITIAL_AMOUNT);
        // verboseLog( "expectedStakingRewards TOTAL_STAKED_AMOUNT: ", TOTAL_STAKED_AMOUNT);
        // verboseLog( "expectedStakingRewards rewardsDuration == _rewardDuration: ", (rewardsDuration == _rewardDuration ? 1 : 0) );
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration: ", REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration );
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT: ", REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT );

        // return REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT * rewardsDuration / _rewardDuration;
        return (rewardsDuration == _rewardDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken(0 , 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        // gotoStakingPeriod();
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod();
        uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "Staking duration %% : ", STAKING_PERCENTAGE_DURATION );
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , 0 );
        uint256 expectedRewardPerToken = (getRewardDurationReached() == REWARD_INITIAL_DURATION ?
            REWARD_INITIAL_AMOUNT * 1e18 / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * getRewardDurationReached() * 1e18 / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION);
        // verboseLog( "expectedRewardPerToken = ", expectedRewardPerToken );
        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
}

// ------------------------------------

contract DuringStaking2_WithoutWithdral is DepositSetup2 {

    uint256 immutable STAKING_PERCENTAGE_DURATION;

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking2_WithoutWithdral setUp() start");
        DepositSetup2.setUp();
        // console.log("DuringStaking2_WithoutWithdral");
        debugLog("DuringStaking2_WithoutWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards.balanceOf(address(_user));
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
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= 100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / 100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    /**
     * Goto some staking time within period
     */
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= 100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / 100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    // function gotoStakingPeriod() private {
    //     vm.warp( getStakingTimeReached() );
    // }

    function checkStakingPeriod() public {
        uint256 stakingTimeReached = getStakingTimeReached();
        uint256 lastTimeReward = stakingRewards.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {

        uint256 stakerRewards = stakingRewards.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _durationReached, uint256 _rewardDuration) public pure returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_durationReached, _rewardDuration);

        // verboseLog( "expectedStakingRewards _stakedAmount: ", _stakedAmount);
        // verboseLog( "expectedStakingRewards _durationReached: ", _durationReached );
        // verboseLog( "expectedStakingRewards _rewardDuration: ", _rewardDuration);
        // verboseLog( "expectedStakingRewards rewardsDuration: ", rewardsDuration);
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT: ", REWARD_INITIAL_AMOUNT);
        // verboseLog( "expectedStakingRewards TOTAL_STAKED_AMOUNT: ", TOTAL_STAKED_AMOUNT);
        // verboseLog( "expectedStakingRewards rewardsDuration == _rewardDuration: ", (rewardsDuration == _rewardDuration ? 1 : 0) );
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration: ", REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration );
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT: ", REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT );

        // return REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT * rewardsDuration / _rewardDuration;
        return (rewardsDuration == _rewardDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken(0 , 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        // gotoStakingPeriod();
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod();
        uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "Staking duration %% : ", STAKING_PERCENTAGE_DURATION );
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , 31e14 );
        checkStakingRewards( userBob, "Bob", expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , 31e14 );
        uint256 expectedRewardPerToken = (getRewardDurationReached() == REWARD_INITIAL_DURATION ?
            REWARD_INITIAL_AMOUNT * 1e18 / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * getRewardDurationReached() * 1e18 / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION);
        // verboseLog( "expectedRewardPerToken = ", expectedRewardPerToken );
        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
}

// ------------------------------------

contract DuringStaking3_WithoutWithdral is DepositSetup3 {

    uint256 immutable STAKING_PERCENTAGE_DURATION;

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking3_WithoutWithdral setUp() start");
        DepositSetup3.setUp();
        // console.log("DuringStaking3_WithoutWithdral");
        debugLog("DuringStaking3_WithoutWithdral setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards.balanceOf(address(_user));
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
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= 100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / 100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    /**
     * Goto some staking time within period
     */
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= 100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / 100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    // function gotoStakingPeriod() private {
    //     vm.warp( getStakingTimeReached() );
    // }

    function checkStakingPeriod() public {
        uint256 stakingTimeReached = getStakingTimeReached();
        uint256 lastTimeReward = stakingRewards.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {

        uint256 stakerRewards = stakingRewards.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _durationReached, uint256 _rewardDuration) public pure returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_durationReached, _rewardDuration);

        // verboseLog( "expectedStakingRewards _stakedAmount: ", _stakedAmount);
        // verboseLog( "expectedStakingRewards _durationReached: ", _durationReached );
        // verboseLog( "expectedStakingRewards _rewardDuration: ", _rewardDuration);
        // verboseLog( "expectedStakingRewards rewardsDuration: ", rewardsDuration);
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT: ", REWARD_INITIAL_AMOUNT);
        // verboseLog( "expectedStakingRewards TOTAL_STAKED_AMOUNT: ", TOTAL_STAKED_AMOUNT);
        // verboseLog( "expectedStakingRewards rewardsDuration == _rewardDuration: ", (rewardsDuration == _rewardDuration ? 1 : 0) );
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration: ", REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration );
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT: ", REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT );

        // return REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT * rewardsDuration / _rewardDuration;
        return (rewardsDuration == _rewardDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken(0 , 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        // gotoStakingPeriod();
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod();
        uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "Staking duration %% : ", STAKING_PERCENTAGE_DURATION );
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , 31e14 );
        checkStakingRewards( userBob, "Bob", expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , 31e14 );
        checkStakingRewards( userCherry, "Cherry", expectedStakingRewards( CHERRY_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , 31e14 );
        uint256 expectedRewardPerToken = (getRewardDurationReached() == REWARD_INITIAL_DURATION ?
            REWARD_INITIAL_AMOUNT * 1e18 / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * getRewardDurationReached() * 1e18 / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION);
        // verboseLog( "expectedRewardPerToken = ", expectedRewardPerToken );
        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
}

// ------------------------------------

// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_
// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_
// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_
// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_
// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_

// contract DuringStaking1_WithWithdral is DepositSetup1 {
contract DuringStaking1_WithoutWithdral_ is DepositSetup1 {

    uint256 immutable STAKING_PERCENTAGE_DURATION;

    constructor (uint256 _stakingPercentageDuration) {
        STAKING_PERCENTAGE_DURATION = _stakingPercentageDuration;
    }

    function setUp() public override {
        debugLog("DuringStaking1_WithoutWithdral_ setUp() start");
        DepositSetup1.setUp();
        // console.log("DuringStaking1_WithoutWithdral_");
        debugLog("DuringStaking1_WithoutWithdral_ setUp() end");
    }

    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards.balanceOf(address(_user));
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
        uint256 rewardDurationReached = (STAKING_PERCENTAGE_DURATION >= 100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * STAKING_PERCENTAGE_DURATION / 100);
        // verboseLog( "getRewardDurationReached: ",  rewardDurationReached);
        return rewardDurationReached;
    }

    function getStakingTimeReached() internal view returns (uint256) {
        uint256 rewardDurationReached = getRewardDurationReached();
        verboseLog( "getStakingTimeReached: rewardDurationReached = ",  rewardDurationReached);
        return STAKING_START_TIME + rewardDurationReached;
    }

    /**
     * Goto some staking time within period
     */
    function gotoStakingPeriod(uint256 _stakingPercentageDurationReached) private returns (uint256) {
        // vm.warp( getStakingTimeReached() );
        assertTrue(_stakingPercentageDurationReached <= STAKING_PERCENTAGE_DURATION, "gotoStakingPeriod: _stakingPercentageDurationReached > STAKING_PERCENTAGE_DURATION"  );
        uint256 gotoStakingPeriodResult = STAKING_START_TIME + (_stakingPercentageDurationReached >= 100 ? REWARD_INITIAL_DURATION : REWARD_INITIAL_DURATION * _stakingPercentageDurationReached / 100);
        verboseLog( "gotoStakingPeriod: gotoStakingPeriodResult = ",  gotoStakingPeriodResult);
        vm.warp(gotoStakingPeriodResult);
        return gotoStakingPeriodResult;
    }

    // function gotoStakingPeriod() private {
    //     vm.warp( getStakingTimeReached() );
    // }

    function checkStakingPeriod() public {
        uint256 stakingTimeReached = getStakingTimeReached();
        uint256 lastTimeReward = stakingRewards.lastTimeRewardApplicable();
        // verboseLog( "stakingTimeReached", stakingTimeReached );
        // verboseLog( "lastTimeReward", lastTimeReward );
        assertEq( block.timestamp, stakingTimeReached , "Wrong block.timestamp" );
        assertEq( lastTimeReward, stakingTimeReached, "Wrong lastTimeReward" );
    }

    function checkStakingRewards(address _staker, string memory _stakerName, uint256 _expectedRewardAmount, uint256 _delta) public {

        uint256 stakerRewards = stakingRewards.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
        verboseLog( _stakerName );
        verboseLog( " rewards: ",  stakerRewards);
    }

    function expectedStakingRewards(uint256 _stakedAmount, uint256 _durationReached, uint256 _rewardDuration) public pure returns (uint256 expectedRewardsAmount) {
        uint256 rewardsDuration = Math.min(_durationReached, _rewardDuration);

        // verboseLog( "expectedStakingRewards _stakedAmount: ", _stakedAmount);
        // verboseLog( "expectedStakingRewards _durationReached: ", _durationReached );
        // verboseLog( "expectedStakingRewards _rewardDuration: ", _rewardDuration);
        // verboseLog( "expectedStakingRewards rewardsDuration: ", rewardsDuration);
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT: ", REWARD_INITIAL_AMOUNT);
        // verboseLog( "expectedStakingRewards TOTAL_STAKED_AMOUNT: ", TOTAL_STAKED_AMOUNT);
        // verboseLog( "expectedStakingRewards rewardsDuration == _rewardDuration: ", (rewardsDuration == _rewardDuration ? 1 : 0) );
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration: ", REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration );
        // verboseLog( "expectedStakingRewards REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT: ", REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT );

        // return REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT * rewardsDuration / _rewardDuration;
        return (rewardsDuration == _rewardDuration ?
            REWARD_INITIAL_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * _stakedAmount * rewardsDuration / _rewardDuration / TOTAL_STAKED_AMOUNT
        );
    }

    function testUsersStakingRewards() public {
        checkRewardPerToken(0 , 0);
        checkRewardForDuration();
        checkStakingTotalSupplyStaked();
        // gotoStakingPeriod();
        gotoStakingPeriod( STAKING_PERCENTAGE_DURATION );
        checkUsersStake();
        checkStakingPeriod();
        uint256 stakingElapsedTime = block.timestamp - STAKING_START_TIME;
        verboseLog( "Staking duration %% : ", STAKING_PERCENTAGE_DURATION );
        checkStakingRewards( userAlice, "Alice", expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT, stakingElapsedTime, REWARD_INITIAL_DURATION ) , 0 );
        uint256 expectedRewardPerToken = (getRewardDurationReached() == REWARD_INITIAL_DURATION ?
            REWARD_INITIAL_AMOUNT * 1e18 / TOTAL_STAKED_AMOUNT :
            REWARD_INITIAL_AMOUNT * getRewardDurationReached() * 1e18 / TOTAL_STAKED_AMOUNT / REWARD_INITIAL_DURATION);
        // verboseLog( "expectedRewardPerToken = ", expectedRewardPerToken );
        checkRewardPerToken( expectedRewardPerToken, 0 ); // no delta needed
    }
}

// ------------------------------------


// ----------------------------------------------------------------------------

contract DuringStaking1_WithoutWithdral_0 is DuringStaking1_WithoutWithdral(0) {
}
contract DuringStaking1_WithoutWithdral_10 is DuringStaking1_WithoutWithdral(10) {
}
// contract DuringStaking1_WithoutWithdral_20 is DuringStaking1_WithoutWithdral(20) {
// }
// contract DuringStaking1_WithoutWithdral_30 is DuringStaking1_WithoutWithdral(30) {
// }
// contract DuringStaking1_WithoutWithdral_33 is DuringStaking1_WithoutWithdral(33) {
// }
// contract DuringStaking1_WithoutWithdral_40 is DuringStaking1_WithoutWithdral(40) {
// }
// contract DuringStaking1_WithoutWithdral_50 is DuringStaking1_WithoutWithdral(50) {
// }
// contract DuringStaking1_WithoutWithdral_60 is DuringStaking1_WithoutWithdral(60) {
// }
// contract DuringStaking1_WithoutWithdral_66 is DuringStaking1_WithoutWithdral(66) {
// }
// contract DuringStaking1_WithoutWithdral_70 is DuringStaking1_WithoutWithdral(70) {
// }
// contract DuringStaking1_WithoutWithdral_80 is DuringStaking1_WithoutWithdral(80) {
// }
// contract DuringStaking1_WithoutWithdral_90 is DuringStaking1_WithoutWithdral(90) {
// }
// contract DuringStaking1_WithoutWithdral_99 is DuringStaking1_WithoutWithdral(99) {
// }
contract DuringStaking1_WithoutWithdral_100 is DuringStaking1_WithoutWithdral(100) {
}
contract DuringStaking1_WithoutWithdral_110 is DuringStaking1_WithoutWithdral(110) {
}
// contract DuringStaking1_WithoutWithdral_150 is DuringStaking1_WithoutWithdral(150) {
// }
// contract DuringStaking1_WithoutWithdral_220 is DuringStaking1_WithoutWithdral(220) {
// }

// ------------------------------------

contract DuringStaking2_WithoutWithdral_0 is DuringStaking2_WithoutWithdral(0) {
}
contract DuringStaking2_WithoutWithdral_10 is DuringStaking2_WithoutWithdral(10) {
}
// contract DuringStaking2_WithoutWithdral_20 is DuringStaking2_WithoutWithdral(20) {
// }
// contract DuringStaking2_WithoutWithdral_30 is DuringStaking2_WithoutWithdral(30) {
// }
// contract DuringStaking2_WithoutWithdral_33 is DuringStaking2_WithoutWithdral(33) {
// }
// contract DuringStaking2_WithoutWithdral_40 is DuringStaking2_WithoutWithdral(40) {
// }
// contract DuringStaking2_WithoutWithdral_50 is DuringStaking2_WithoutWithdral(50) {
// }
// contract DuringStaking2_WithoutWithdral_60 is DuringStaking2_WithoutWithdral(60) {
// }
// contract DuringStaking2_WithoutWithdral_66 is DuringStaking2_WithoutWithdral(66) {
// }
// contract DuringStaking2_WithoutWithdral_70 is DuringStaking2_WithoutWithdral(70) {
// }
// contract DuringStaking2_WithoutWithdral_80 is DuringStaking2_WithoutWithdral(80) {
// }
// contract DuringStaking2_WithoutWithdral_90 is DuringStaking2_WithoutWithdral(90) {
// }
// contract DuringStaking2_WithoutWithdral_99 is DuringStaking2_WithoutWithdral(99) {
// }
contract DuringStaking2_WithoutWithdral_100 is DuringStaking2_WithoutWithdral(100) {
}
contract DuringStaking2_WithoutWithdral_110 is DuringStaking2_WithoutWithdral(110) {
}
// contract DuringStaking2_WithoutWithdral_150 is DuringStaking2_WithoutWithdral(150) {
// }
// contract DuringStaking2_WithoutWithdral_220 is DuringStaking2_WithoutWithdral(220) {
// }

// ------------------------------------

contract DuringStaking3_WithoutWithdral_0 is DuringStaking3_WithoutWithdral(0) {
}
contract DuringStaking3_WithoutWithdral_10 is DuringStaking3_WithoutWithdral(10) {
}
// contract DuringStaking3_WithoutWithdral_20 is DuringStaking3_WithoutWithdral(20) {
// }
// contract DuringStaking3_WithoutWithdral_30 is DuringStaking3_WithoutWithdral(30) {
// }
// contract DuringStaking3_WithoutWithdral_33 is DuringStaking3_WithoutWithdral(33) {
// }
// contract DuringStaking3_WithoutWithdral_40 is DuringStaking3_WithoutWithdral(40) {
// }
// contract DuringStaking3_WithoutWithdral_50 is DuringStaking3_WithoutWithdral(50) {
// }
// contract DuringStaking3_WithoutWithdral_60 is DuringStaking3_WithoutWithdral(60) {
// }
// contract DuringStaking3_WithoutWithdral_66 is DuringStaking3_WithoutWithdral(66) {
// }
// contract DuringStaking3_WithoutWithdral_70 is DuringStaking3_WithoutWithdral(70) {
// }
// contract DuringStaking3_WithoutWithdral_80 is DuringStaking3_WithoutWithdral(80) {
// }
// contract DuringStaking3_WithoutWithdral_90 is DuringStaking3_WithoutWithdral(90) {
// }
// contract DuringStaking3_WithoutWithdral_99 is DuringStaking3_WithoutWithdral(99) {
// }
contract DuringStaking3_WithoutWithdral_100 is DuringStaking3_WithoutWithdral(100) {
}
// contract DuringStaking3_WithoutWithdral_110 is DuringStaking3_WithoutWithdral(110) {
// }
// contract DuringStaking3_WithoutWithdral_150 is DuringStaking3_WithoutWithdral(150) {
// }
// contract DuringStaking3_WithoutWithdral_220 is DuringStaking3_WithoutWithdral(220) {
// }

// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_
// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_
// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_
// TODO : DuringStaking1_WithoutWithdral_ ==> DuringStaking1_WithWithdral_
contract DuringStaking1_WithoutWithdral_0_ is DuringStaking1_WithoutWithdral_(0) {
}
contract DuringStaking1_WithoutWithdral_10_ is DuringStaking1_WithoutWithdral_(10) {
}
// contract DuringStaking1_WithoutWithdral_20_ is DuringStaking1_WithoutWithdral_(20) {
// }
// contract DuringStaking1_WithoutWithdral_30_ is DuringStaking1_WithoutWithdral_(30) {
// }
// contract DuringStaking1_WithoutWithdral_33_ is DuringStaking1_WithoutWithdral_(33) {
// }
// contract DuringStaking1_WithoutWithdral_40 is DuringStaking1_WithoutWithdral_(40) {
// }
// contract DuringStaking1_WithoutWithdral_50_ is DuringStaking1_WithoutWithdral_(50) {
// }
// contract DuringStaking1_WithoutWithdral_60_ is DuringStaking1_WithoutWithdral_(60) {
// }
// contract DuringStaking1_WithoutWithdral_66_ is DuringStaking1_WithoutWithdral_(66) {
// }
// contract DuringStaking1_WithoutWithdral_70_ is DuringStaking1_WithoutWithdral_(70) {
// }
// contract DuringStaking1_WithoutWithdral_80_ is DuringStaking1_WithoutWithdral_(80) {
// }
// contract DuringStaking1_WithoutWithdral_90_ is DuringStaking1_WithoutWithdral_(90) {
// }
// contract DuringStaking1_WithoutWithdral_99_ is DuringStaking1_WithoutWithdral_(99) {
// }
contract DuringStaking1_WithoutWithdral_100_ is DuringStaking1_WithoutWithdral_(100) {
}
contract DuringStaking1_WithoutWithdral_110_ is DuringStaking1_WithoutWithdral_(110) {
}
// contract DuringStaking1_WithoutWithdral_150_ is DuringStaking1_WithoutWithdral_(150) {
// }
// contract DuringStaking1_WithoutWithdral_220_ is DuringStaking1_WithoutWithdral_(220) {
// }

// --------------------------------------------------------

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

        stakingRewards.setPaused(true);
        assertEq( stakingRewards.paused(), false );
        verboseLog( "Staking contract: Alice can't pause" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );

        stakingRewards.setPaused(true);
        assertEq( stakingRewards.paused(), false );
        verboseLog( "Staking contract: Bob can't pause" );

        vm.startPrank(userStakingRewardAdmin);
        // Check event emitted
        vm.expectEmit(true,false,false,false, address(stakingRewards));
        emit Pausable.Paused(userStakingRewardAdmin);
        stakingRewards.setPaused(true);
        assertEq( stakingRewards.paused(), true );
        verboseLog( "Staking contract: Only owner can pause" );
        verboseLog( "Staking contract: Event Paused emitted" );

        // Pausing again should not throw nor emit event and leave pause unchanged
        stakingRewards.setPaused(true);
        // Check no event emitted ?
        assertEq( stakingRewards.paused(), true );
        vm.stopPrank();

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );
        verboseLog( "Only staking reward contract owner can unpause" );

        stakingRewards.setPaused(false);
        assertEq( stakingRewards.paused(), true );
        verboseLog( "Staking contract: Alice can't unpause" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );

        stakingRewards.setPaused(false);
        assertEq( stakingRewards.paused(), true );
        verboseLog( "Staking contract: Bob can't unpause" );

        vm.startPrank(userStakingRewardAdmin);
        // Check event emitted
        vm.expectEmit(true,false,false,false, address(stakingRewards));
        emit Pausable.Unpaused(userStakingRewardAdmin);
        stakingRewards.setPaused(false);
        assertEq( stakingRewards.paused(), false );

        verboseLog( "Staking contract: Only owner can unpause" );
        verboseLog( "Staking contract: Event Unpaused emitted" );

        // Unausing again should not throw nor emit event and leave pause unchanged
        stakingRewards.setPaused(false);
        // Check no event emitted ?
        assertEq( stakingRewards.paused(), false );

        vm.stopPrank();
    }

    function testStakingNotifyRewardAmount() public {

        vm.prank(erc20Minter);
        rewardErc20.mint( address(stakingRewards), REWARD_INITIAL_AMOUNT );

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );
        verboseLog( "Only staking reward contract owner can notifyRewardAmount" );

        stakingRewards.notifyRewardAmount( 1 );
        verboseLog( "Staking contract: Alice can't notifyRewardAmount" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );

        stakingRewards.notifyRewardAmount( 1 );
        verboseLog( "Staking contract: Bob can't notifyRewardAmount" );

        vm.prank(userStakingRewardAdmin);
        // Check event emitted
        vm.expectEmit(true,false,false,false, address(stakingRewards));
        emit StakingRewards2.RewardAdded( 1 );
        stakingRewards.notifyRewardAmount( 1 );
        verboseLog( "Staking contract: Only owner can notifyRewardAmount" );
        verboseLog( "Staking contract: Event RewardAdded emitted" );
    }

    function testStakingSetRewardsDuration() public {

        // Previous reward epoch must have ended before setting a new duration
        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION + 1 ); // epoch ended

        vm.prank(userAlice);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userAlice )
        );
        verboseLog( "Only staking reward contract owner can notifyRewardAmount" );

        stakingRewards.setRewardsDuration( 1 );
        verboseLog( "Staking contract: Alice can't setRewardsDuration" );

        vm.prank(userBob);
        vm.expectRevert(
            abi.encodeWithSelector( Ownable.OwnableUnauthorizedAccount.selector, userBob )
        );

        stakingRewards.setRewardsDuration( 1 );
        verboseLog( "Staking contract: Bob can't setRewardsDuration" );

        vm.prank(userStakingRewardAdmin);
        // Check event emitted
        vm.expectEmit(true,false,false,false, address(stakingRewards));
        emit StakingRewards2.RewardsDurationUpdated( 1 );
        stakingRewards.setRewardsDuration( 1 );
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
        stakingRewards.setRewardsDuration( 1 );

        // Previous reward epoch must have ended before setting a new duration
        vm.warp( STAKING_START_TIME + REWARD_INITIAL_DURATION ); // epoch last time reward
        vm.expectRevert(
            abi.encodeWithSelector(
                IStakingRewards2Errors.RewardPeriodInProgress.selector, block.timestamp, STAKING_START_TIME + REWARD_INITIAL_DURATION )
        );
        stakingRewards.setRewardsDuration( 1 );

        verboseLog( "Staking contract: Owner can't setRewardsDuration before previous epoch end" );
        vm.stopPrank();
    }
}
