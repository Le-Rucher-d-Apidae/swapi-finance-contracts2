// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.0;
pragma solidity >= 0.8.0 < 0.9.0;

import { console } from "forge-std/src/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";

import { Utils } from "./utils/Utils.sol";

import { IERC20 } from "../src/contracts/Uniswap/v2-core/interfaces/IERC20.sol";

import { RewardERC20 } from "./contracts/RewardERC20.sol";
import { StakingERC20 } from "./contracts/StakingERC20.sol";

import "./TestsConstants.sol";

// TODO : move to utils
contract TestLog is Test {

    bool debug = true;
    bool verbose = true;
    Utils internal utils;

    function debugLog(string memory _msg) public view {
        if (debug) console.log(_msg);
    }
    function debugLog(string memory _msg1, string memory _msg2) public view {
        if (debug) console.log(_msg1, _msg2);
    }
    function debugLog(string memory _msg, uint _val256) public view {
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
    function debugLogTime(string memory _msg, uint _val256) public view {
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
    function verboseLog(string memory _msg, uint _val256) public view {
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
    function verboseLogTime(string memory _msg, uint _val256) public view {
        if (verbose) console.log(_msg, _val256, " ts: ", block.timestamp);
    }
    function verboseLogTime(string memory _msg, address _address) public view {
        if (verbose) console.log(_msg, _address, " ts: ", block.timestamp);
    }

    // function checkOnlyAddressCanInvoke(address _allowedAddress, address[] calldata _users, address _contract, bytes4 _selector) public {
    //     uint256 usersCount = _users.length;
    //     for (uint256 currentUserIdx = 0; currentUserIdx < usersCount; currentUserIdx++ ) {
    //         address adr = _users[currentUserIdx];
    //         if ( adr ==  _allowedAddress) continue;
    //         vm.prank( adr );
    //         // _contract.call(_selector)
    //         (bool staticcallSuccess, ) = _contract.staticcall( abi.encodeWithSelector(_selector) );
    //         // assert
    //         assertTrue(staticcallSuccess, "checkOnlyAddressCanInvoke: staticcall failed");
    //     }
    // }
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
