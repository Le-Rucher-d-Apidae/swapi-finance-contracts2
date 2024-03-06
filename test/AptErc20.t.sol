// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.9.0;

import { console } from "forge-std/src/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";

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

contract Setup is BaseSetup {
    AptErc20 internal Apt;

    function setUp() public virtual override {
        BaseSetup.setUp();
        // Instantiate the contract-under-test.
        Apt = new AptErc20( admin, minter );
        console.log("Setup");
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

contract WhenTransferringTokens is Setup {
    uint256 internal maxTransferAmount = 12e18;

    function setUp() public virtual override {
        BaseSetup.setUp();
        console.log("When transferring tokens");
    }

    function transferToken(address from, address to, uint256 transferAmount) public returns (bool) {
        vm.prank(from);
        return Apt.transfer(to, transferAmount);
    }
}

contract WhenAliceHasSufficientFunds is WhenTransferringTokens {
    using stdStorage for StdStorage;

    uint256 internal mintAmount = maxTransferAmount;

    function setUp() public override {
        WhenTransferringTokens.setUp();
        console.log("When Alice has sufficient funds");
        Apt.mint(alice, mintAmount);
    }

    function itTransfersAmountCorrectly(address from, address to, uint256 transferAmount) public {
        uint256 fromBalanceBefore = Apt.balanceOf(from);
        bool success = this.transferToken(from, to, transferAmount);

        assertTrue(success);
        assertEqDecimal(Apt.balanceOf(from), fromBalanceBefore - transferAmount, Apt.decimals());
        assertEqDecimal(Apt.balanceOf(to), transferAmount, Apt.decimals());
    }

    function testTransferAllTokens() public {
        itTransfersAmountCorrectly(alice, bob, maxTransferAmount);
    }

    function testTransferHalfTokens() public {
        itTransfersAmountCorrectly(alice, bob, maxTransferAmount / 2);
    }

    function testTransferOneToken() public {
        itTransfersAmountCorrectly(alice, bob, 1);
    }

    function testTransferWithFuzzing(uint64 transferAmount) public {
        vm.assume(transferAmount != 0);
        itTransfersAmountCorrectly(alice, bob, transferAmount % maxTransferAmount);
    }

    function testTransferWithMockedCall() public {
        vm.prank(alice);
        vm.mockCall(
            address(this), abi.encodeWithSelector(Apt.transfer.selector, bob, maxTransferAmount), abi.encode(false)
        );
        bool success = Apt.transfer(bob, maxTransferAmount);
        assertTrue(!success);
        vm.clearMockedCalls();
    }

    // example how to use https://github.com/foundry-rs/forge-std stdStorage
    function testFindMapping() public {
        uint256 slot = stdstore.target(address(this)).sig(Apt.balanceOf.selector).with_key(alice).find();
        bytes32 data = vm.load(address(this), bytes32(slot));
        assertEqDecimal(uint256(data), mintAmount, Apt.decimals());
    }
}
