// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.9.0;

import { console } from "forge-std/src/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";

import { Utils } from "./utils/Utils.sol";

import { AptErc20 } from "../src/contracts/AptErc20.sol";
// import { ERC20InsufficientBalance, ERC20InvalidReceiver } from "@openzeppelin/contracts@5.0.2/interfaces/draft-IERC6093.sol";
import { IERC20Errors } from "@openzeppelin/contracts@5.0.2/interfaces/draft-IERC6093.sol";


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
    AptErc20 internal Apt;

    function setUp() public virtual override {
        // console.log("TokensSetup setUp()");
        verboseLog("TokensSetup setUp() start");
        UsersSetup.setUp();
        // Instantiate the contract-under-test.
        Apt = new AptErc20( admin, minter );
        verboseLog("TokensSetup setUp() end");
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
        return Apt.transfer(to, transferAmount);
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
        Apt.mint(alice, mintAmount);
        verboseLog("WhenAliceHasSufficientFunds setUp() end");
        console.log("When Alice has sufficient funds");
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
            address(Apt), abi.encodeWithSelector(Apt.transfer.selector, bob, maxTransferAmount), abi.encode(false)
        );
        bool success = Apt.transfer(bob, maxTransferAmount);
        assertTrue(!success);
        vm.clearMockedCalls();
    }

    // example how to use https://github.com/foundry-rs/forge-std stdStorage
    function testFindMapping() public {
        AptErc20 tokenToTest = Apt;
        address tokenAddressToTest = address(tokenToTest);
        uint256 slot = stdstore.target(address(tokenAddressToTest)).sig(Apt.balanceOf.selector).with_key(alice).find();
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
        Apt.mint(alice, mintAmount);
        console.log("When Alice has insufficient funds");
        verboseLog("WhenAliceHasInsufficientFunds setUp() end");
    }

    function testCannotTransferMoreThanAvailable() public {
        address from = alice;
        address to = bob;
        uint256 transferAmount = maxTransferAmount;

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, from, Apt.balanceOf(from), transferAmount)
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
