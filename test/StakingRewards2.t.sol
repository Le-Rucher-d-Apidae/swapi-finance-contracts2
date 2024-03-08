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

// import { IERC20Errors } from "@openzeppelin/contracts@5.0.2/interfaces/draft-IERC6093.sol";
import { IERC20 } from "../src/contracts/Uniswap/v2-core/interfaces/IERC20.sol";


contract UsersSetup is Test {
    bool verbose = true;
    Utils internal utils;
    address payable[] internal users;

    address internal admin;
    address internal minter;

    address internal alice;
    address internal bob;

    function setUp() public virtual {
        // console.log("UsersSetup setUp()");
        verboseLog("UsersSetup setUp() start");
        utils = new Utils();
        users = utils.createUsers(4);

        admin = users[0];
        vm.label(admin, "Admin");
        minter = users[1];
        vm.label(minter, "Minter");

        alice = users[2];
        vm.label(alice, "Alice");
        bob = users[3];
        vm.label(bob, "Bob");
        verboseLog("UsersSetup setUp() end");
    }

    function verboseLog(string memory _msg) public view {
        if (verbose) console.log(_msg);
    }
}

