// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.9.0;

import { console } from "forge-std/src/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";

import { Utils } from "./utils/Utils.sol";

import { MyERC20 } from "./contracts/sampleContracts/MyERC20.sol";

import { BwsErc20 } from "../src/contracts/BwsErc20.sol";
import { IERC20Errors } from "@openzeppelin/contracts@5.0.2/interfaces/draft-IERC6093.sol";
import { IERC20 } from "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";

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

contract TokensSetup is UsersSetup {
    BwsErc20 internal Bws;

    function setUp() public virtual override {
        // console.log("TokensSetup setUp()");
        verboseLog("TokensSetup setUp() start");
        UsersSetup.setUp();
        // Instantiate the contract-under-test.
        Bws = new BwsErc20(admin, minter);
        verboseLog("TokensSetup setUp() end");
    }

    // function transferToken(address from, address to, uint256 transferAmount) public returns (bool) {
    //     vm.prank(from);
    //     return this.transfer(to, transferAmount);
    // }
}

// /// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
// /// https://book.getfoundry.sh/forge/writing-tests
// contract BwsErc20Test is PRBTest, StdCheats {
//     BwsErc20 internal Bws;

//     /// @dev A function invoked before each test case is run.
//     function setUp() public virtual {
//         // Instantiate the contract-under-test.
//         Bws = new BwsErc20( admin, minter );
//     }

// }

contract WhenTransferringTokens is TokensSetup {
    uint256 internal maxTransferAmount = 12e18;

    function setUp() public virtual override {
        verboseLog("WhenTransferringTokens setUp() start");
        TokensSetup.setUp();
        console.log("When transferring tokens");
        verboseLog("WhenTransferringTokens setUp() end");
    }

    function transferToken(address from, address to, uint256 transferAmount) public returns (bool) {
        vm.prank(from);
        return Bws.transfer(to, transferAmount);
    }
}

contract WhenAliceHasSufficientFunds is WhenTransferringTokens {
    using stdStorage for StdStorage;

    uint256 internal mintAmount = maxTransferAmount;

    function setUp() public override {
        verboseLog("WhenAliceHasSufficientFunds setUp() start");
        WhenTransferringTokens.setUp();
        verboseLog("WhenAliceHasSufficientFunds setUp() mint to Alice");
        vm.prank(minter);
        Bws.mint(alice, mintAmount);
        verboseLog("WhenAliceHasSufficientFunds setUp() end");
        console.log("When Alice has sufficient funds");
    }

    function itTransfersAmountCorrectly(address from, address to, uint256 transferAmount) public {
        uint256 fromBalanceBefore = Bws.balanceOf(from);
        bool success = this.transferToken(from, to, transferAmount);

        assertTrue(success);
        assertEqDecimal(Bws.balanceOf(from), fromBalanceBefore - transferAmount, Bws.decimals());
        assertEqDecimal(Bws.balanceOf(to), transferAmount, Bws.decimals());
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
            address(Bws), abi.encodeWithSelector(Bws.transfer.selector, bob, maxTransferAmount), abi.encode(false)
        );
        bool success = Bws.transfer(bob, maxTransferAmount);
        assertTrue(!success);
        vm.clearMockedCalls();
    }

    // example how to use https://github.com/foundry-rs/forge-std stdStorage
    function testFindMapping() public {
        BwsErc20 tokenToTest = Bws;
        address tokenAddressToTest = address(tokenToTest);
        uint256 slot = stdstore.target(address(tokenAddressToTest)).sig(Bws.balanceOf.selector).with_key(alice).find();
        bytes32 data = vm.load(address(tokenAddressToTest), bytes32(slot));
        assertEqDecimal(uint256(data), mintAmount, tokenToTest.decimals());
    }
}

contract WhenAliceHasInsufficientFunds is WhenTransferringTokens {
    uint256 internal mintAmount = maxTransferAmount - 1e18;

    function setUp() public override {
        verboseLog("WhenAliceHasInsufficientFunds setUp() start");
        WhenTransferringTokens.setUp();
        vm.prank(minter);
        Bws.mint(alice, mintAmount);
        console.log("When Alice has insufficient funds");
        verboseLog("WhenAliceHasInsufficientFunds setUp() end");
    }

    function testCannotTransferMoreThanAvailable() public {
        address from = alice;
        address to = bob;
        uint256 transferAmount = maxTransferAmount;

        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector, from, Bws.balanceOf(from), transferAmount
            )
        );
        transferToken(from, to, transferAmount);
    }

    function testCannotTransferToZero() public {
        address from = alice;
        address to = address(0);
        uint256 transferAmount = mintAmount;

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, to));
        transferToken(from, to, transferAmount);
    }
}

contract RecoveringTokens is TokensSetup {
    MyERC20 myErc20;

    function setUp() public virtual override {
        verboseLog("RecoveringTokens setUp() start");
        TokensSetup.setUp();
        myErc20 = new MyERC20();
        // vm.prank();

        myErc20.mint(alice, 1e18);
        vm.prank(alice);
        myErc20.transfer(address(Bws), 1e18);

        myErc20.mint(bob, 1e18);
        vm.prank(bob);
        myErc20.transfer(address(Bws), 1e18);

        console.log("RecoveringTokens tokens");
        verboseLog("RecoveringTokens setUp() end");
    }

    function recoverERC20Token(address to, uint256 transferAmount) public /* returns (bool) */ {
        vm.prank(admin);
        return Bws.recoverERC20(address(myErc20), to, transferAmount);
    }

    function testRecoverERC20Token() public {
        assertEq(myErc20.balanceOf(address(alice)), 0);
        assertEq(myErc20.balanceOf(address(bob)), 0);
        assertEq(myErc20.balanceOf(address(Bws)), 2e18);

        recoverERC20Token(address(alice), 1e18);
        assertEq(myErc20.balanceOf(address(alice)), 1e18);

        recoverERC20Token(address(bob), 1e18);
        assertEq(myErc20.balanceOf(address(bob)), 1e18);

        assertEq(myErc20.balanceOf(address(Bws)), 0);
    }
}
