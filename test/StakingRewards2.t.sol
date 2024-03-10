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

import { IERC20 } from "../src/contracts/Uniswap/v2-core/interfaces/IERC20.sol";
import { RewardERC20 } from "./contracts/RewardERC20.sol";
import { StakingERC20 } from "./contracts/StakingERC20.sol";

// import { MockERC20 } from "forge-std/src/mocks/MockERC20.sol";

// TODO : move to utils
contract MyTest is Test {

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

contract UsersSetup is MyTest {
    address payable[] internal users;

    address internal erc20Admin;
    address internal erc20Minter;
    address internal userStakingRewardAdmin;

    address internal userAlice;
    address internal userBob;

    function setUp() public virtual {

        console.log("UsersSetup setUp()");
        debugLog("UsersSetup setUp() start");
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
        debugLog("UsersSetup setUp() end");
    }

}

contract Erc20Setup is UsersSetup {

    RewardERC20 internal rewardErc20;
    StakingERC20 internal stakingERC20;
    uint256 constant ALICE_STAKINGERC20_MINTEDAMOUNT = 2e18;
    uint256 constant BOB_STAKINGERC20_MINTEDAMOUNT = 1e18;


    function setUp() public virtual override {
        console.log("Erc20Setup setUp()");
        debugLog("Erc20Setup setUp() start");
        UsersSetup.setUp();
        rewardErc20 = new RewardERC20("TestReward", "TSTRWD");
        stakingERC20 = new StakingERC20(erc20Admin, erc20Minter, "Uniswap V2", "UNI-V2");
        vm.startPrank(erc20Minter);
        stakingERC20.mint(userAlice, ALICE_STAKINGERC20_MINTEDAMOUNT);
        stakingERC20.mint(userBob, BOB_STAKINGERC20_MINTEDAMOUNT);
        vm.stopPrank();
        debugLog("Erc20Setup setUp() end");
    }

}

contract StakingSetup is Erc20Setup {

    StakingRewards2 internal stakingRewards;
    uint256 constant internal REWARD_AMOUNT = 100_000; // 10e5
    uint256 constant internal REWARD_DURATION = 10_000; // 10 000 s.

    uint256 constant ALICE_STAKINGERC20_STAKEDAMOUNT = ALICE_STAKINGERC20_MINTEDAMOUNT;
    uint256 constant BOB_STAKINGERC20_STAKEDAMOUNT = BOB_STAKINGERC20_MINTEDAMOUNT;

    // uint ts = vm.getBlockTimestamp();
    uint256 stakingStartTime;

    function setUp() public virtual override {
        console.log("StakingSetup setUp()");
        debugLog("StakingSetup setUp() start");
        Erc20Setup.setUp();
        vm.prank( userStakingRewardAdmin );
        stakingRewards = new StakingRewards2( address(rewardErc20), address(stakingERC20) );
        assertEq( userStakingRewardAdmin, stakingRewards.owner(), "stakingRewards: Wrong owner" );

        // checkOnlyAddressCanInvoke( userStakingRewardAdmin, address[](users), address(stakingRewards), bytes4(keccak256("setRewardsDuration")) );

        // console.log("time:", vm.getBlockTimestamp());
        
        // console.log( ts );
        // console.log( block.timestamp );
        // console.logUint( ts );
        // console.log( vm.getBlockTimestamp() );
        // console.log( vm.getBlockNumber() );
        
        vm.prank( userStakingRewardAdmin );
        stakingRewards.setRewardsDuration(REWARD_DURATION);

        rewardErc20.mint( address(stakingRewards), REWARD_AMOUNT );
        stakingStartTime = block.timestamp;

        vm.prank( userStakingRewardAdmin );
        stakingRewards.notifyRewardAmount(REWARD_AMOUNT);

        debugLog("Staking start time", stakingStartTime);
        debugLog("StakingSetup setUp() end");
    }


}

contract DepositSetup is StakingSetup {

    uint256 constant internal TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;

    function setUp() public virtual override {
        console.log("DepositSetup setUp()");
        debugLog("DepositSetup setUp() start");
        StakingSetup.setUp();
        vm.startPrank(userAlice);
        stakingERC20.approve( address(stakingRewards), ALICE_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards.stake( ALICE_STAKINGERC20_STAKEDAMOUNT );
        vm.startPrank(userBob);
        stakingERC20.approve( address(stakingRewards), BOB_STAKINGERC20_STAKEDAMOUNT );
        stakingRewards.stake( BOB_STAKINGERC20_STAKEDAMOUNT );
        vm.stopPrank();
        // TOTAL_STAKED_AMOUNT = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;
        debugLog("DepositSetup setUp() end");
    }
}

contract WhenStaking is DepositSetup {

    function setUp() public override {
        debugLog("WhenStaking setUp() start");
        DepositSetup.setUp();
        console.log("WhenStaking");
        debugLog("WhenStaking setUp() end");
    }

    // function itStakesCorrectly(/* address from, uint256 transferAmount */) public {
    //     uint256 aliceStakedBalance = stakingRewards2.balanceOf(address(userAlice));
    //     debugLog("Alice staked balance: ", aliceStakedBalance);
    //     assertEq( ALICE_STAKINGERC20_STAKEDAMOUNT, aliceStakedBalance );

    //     uint256 bobStakedBalance = stakingRewards2.balanceOf(address(userBob));
    //     debugLog("Bob staked balance: ", bobStakedBalance);
    //     assertEq( BOB_STAKINGERC20_STAKEDAMOUNT, bobStakedBalance );

    //     assertTrue(true);
    // }
    function itStakesCorrectly(address _user, uint256 _stakeAmount, string memory _userName) public {
        uint256 userStakedBalance = stakingRewards.balanceOf(address(_user));
        verboseLog(_userName);
        verboseLog("staked balance: ", userStakedBalance);
        assertEq( _stakeAmount, userStakedBalance );
    }

    function checkAliceStakes() public {
        itStakesCorrectly( userAlice, ALICE_STAKINGERC20_STAKEDAMOUNT, "Alice" );
    }
    function checkBobStake() public {
        itStakesCorrectly(userBob, BOB_STAKINGERC20_STAKEDAMOUNT, "Bob" );
    }
    function testUsersStake() public {
        checkAliceStakes();
        checkBobStake();
    }

    function gotoStakingPeriodEnd(uint256 _additionnalTime) private {
        vm.warp( stakingStartTime + REWARD_DURATION + _additionnalTime );
    }

    function checkStakingPeriodEnded() public {
        // gotoStakingPeriodEnd( 1_000 );
        uint256 lastTimeReward = stakingRewards.lastTimeRewardApplicable();
        // assertTrue( block.timestamp >= stakingStartTime+REWARD_DURATION, "Staking period must be ended" );
        assertGe( block.timestamp, stakingStartTime + REWARD_DURATION, "Staking period must be ended" );
        assertEq( lastTimeReward, stakingStartTime + REWARD_DURATION );
        verboseLog( "lastTimeReward", lastTimeReward );
    }

    function testStakingRewardsEnd() public {
        gotoStakingPeriodEnd( 1_000 );
        checkStakingPeriodEnded();
    }

    // function testStakingRewards(uint256 _rewardAmount) public {
    function checkStakingRewards(address _staker, uint256 _expectedRewardAmount, uint256 _delta) public {

        // assertApproxEqRel( aliceRewards, REWARD_AMOUNT * ALICE_STAKINGERC20_STAKEDAMOUNT / (ALICE_STAKINGERC20_STAKEDAMOUNT+BOB_STAKINGERC20_STAKEDAMOUNT) , 0 );
        // assertEq( aliceRewards, REWARD_AMOUNT * ALICE_STAKINGERC20_STAKEDAMOUNT / (ALICE_STAKINGERC20_STAKEDAMOUNT+BOB_STAKINGERC20_STAKEDAMOUNT) );

        // uint256 = REWARD_AMOUNT
        // uint256 totalStakedAmount = ALICE_STAKINGERC20_STAKEDAMOUNT + BOB_STAKINGERC20_STAKEDAMOUNT;

        uint256 stakerRewards = stakingRewards.earned( _staker );
        if (_delta == 0) {
            assertEq( stakerRewards, _expectedRewardAmount );
        } else {
            assertApproxEqRel( stakerRewards, _expectedRewardAmount, _delta );
        }
    }

    function expectedStakingRewards(uint256 _stakedAmount) public pure returns (uint256 expectedRewardsAmount) {
        return REWARD_AMOUNT * _stakedAmount / TOTAL_STAKED_AMOUNT;
    }

    function testUsersStakingRewards() public {
        // uint256 aliceRewards;
        // uint256 bobRewards;

        gotoStakingPeriodEnd( 0 );

        // aliceRewards = stakingRewards.earned( userAlice );
        // verboseLog( "aliceRewards", aliceRewards );

        // // assertApproxEqRel( aliceRewards, REWARD_AMOUNT * ALICE_STAKINGERC20_STAKEDAMOUNT / (ALICE_STAKINGERC20_STAKEDAMOUNT+BOB_STAKINGERC20_STAKEDAMOUNT) , 0 );
        // assertEq( aliceRewards, REWARD_AMOUNT * ALICE_STAKINGERC20_STAKEDAMOUNT / (ALICE_STAKINGERC20_STAKEDAMOUNT+BOB_STAKINGERC20_STAKEDAMOUNT) );

        // bobRewards = stakingRewards.earned( userBob );
        // verboseLog( "bobRewards", bobRewards );

/// , REWARD_AMOUNT * ALICE_STAKINGERC20_STAKEDAMOUNT / TOTAL_STAKED_AMOUNT

        checkStakingRewards( userAlice, expectedStakingRewards( ALICE_STAKINGERC20_STAKEDAMOUNT ) , 0 );
        checkStakingRewards( userBob, expectedStakingRewards( BOB_STAKINGERC20_STAKEDAMOUNT ) , 0 );

    }

}