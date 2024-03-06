// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

// import { PRBTest } from "@prb/test/src/PRBTest.sol";

// import { console2 } from "forge-std/src/console2.sol";
// import { StdCheats } from "forge-std/src/StdCheats.sol";

import { console } from "forge-std/src/console.sol";
// import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";
import { Test } from "forge-std/src/Test.sol";

import { Utils } from "./utils/Utils.sol";

import { AptErc20 } from "../src/contracts/AptErc20.sol";

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract BaseSetup is Test {
    Utils internal utils;
    address payable[] internal users;

    address internal admin;
    address internal minter;

    address internal alice;
    address internal bob;

    function setUp() public virtual {
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
    }
}

contract Mint is BaseSetup {
    /* solhint-disable var-name-mixedcase */
    AptErc20 internal Apt;
    /* solhint-enable var-name-mixedcase */

    function setUp() public virtual override {
        BaseSetup.setUp();
        // Instantiate the contract-under-test.
        Apt = new AptErc20( admin, minter );
        console.log("Mint");
    }

    // function transferToken(address from, address to, uint256 transferAmount) public returns (bool) {
    //     vm.prank(from);
    //     return this.transfer(to, transferAmount);
    // }
}

// /// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
// /// https://book.getfoundry.sh/forge/writing-tests
// contract AptErc20Test is PRBTest, StdCheats {
//     AptErc20 internal Apt;

//     /// @dev A function invoked before each test case is run.
//     function setUp() public virtual {
//         // Instantiate the contract-under-test.
//         Apt = new AptErc20( admin, minter );
//     }

// }
