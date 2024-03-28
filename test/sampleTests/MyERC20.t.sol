// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20 <0.9.0;

import { console } from "forge-std/src/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/src/Test.sol";

import { Utils } from "../utils/Utils.sol";
import { MyERC20 } from "../contracts/sampleContracts/MyERC20.sol";

contract BaseSetup is MyERC20, Test {
    Utils internal utils;
    address payable[] internal users;

    address internal alice;
    address internal bob;

    function setUp() public virtual {
        utils = new Utils();
        users = utils.createUsers(2);

        alice = users[0];
        vm.label(alice, "Alice");
        bob = users[1];
        vm.label(bob, "Bob");
    }
}

contract WhenTransferringTokens is BaseSetup {
    uint256 internal maxTransferAmount = 12e18;

    function setUp() public virtual override {
        BaseSetup.setUp();
        console.log("When transferring tokens");
    }

    function transferToken(address from, address to, uint256 transferAmount) public returns (bool) {
        vm.prank(from);
        return this.transfer(to, transferAmount);
    }
}

contract WhenAliceHasSufficientFunds is WhenTransferringTokens {
    using stdStorage for StdStorage;

    uint256 internal mintAmount = maxTransferAmount;

    function setUp() public override {
        WhenTransferringTokens.setUp();
        console.log("When Alice has sufficient funds");
        _mint(alice, mintAmount);
    }

    function itTransfersAmountCorrectly(address from, address to, uint256 transferAmount) public {
        uint256 fromBalanceBefore = balanceOf(from);
        bool success = transferToken(from, to, transferAmount);

        assertTrue(success);
        assertEqDecimal(balanceOf(from), fromBalanceBefore - transferAmount, decimals());
        assertEqDecimal(balanceOf(to), transferAmount, decimals());
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
            address(this), abi.encodeWithSelector(this.transfer.selector, bob, maxTransferAmount), abi.encode(false)
        );
        bool success = this.transfer(bob, maxTransferAmount);
        assertTrue(!success);
        vm.clearMockedCalls();
    }

    // example how to use https://github.com/foundry-rs/forge-std stdStorage
    function testFindMapping() public {
        uint256 slot = stdstore.target(address(this)).sig(this.balanceOf.selector).with_key(alice).find();
        bytes32 data = vm.load(address(this), bytes32(slot));
        assertEqDecimal(uint256(data), mintAmount, decimals());
    }
}

contract WhenAliceHasInsufficientFunds is WhenTransferringTokens {
    uint256 internal mintAmount = maxTransferAmount - 1e18;

    function setUp() public override {
        WhenTransferringTokens.setUp();
        console.log("When Alice has insufficient funds");
        _mint(alice, mintAmount);
    }

    // function itRevertsTransfer(
    //     address from,
    //     address to,
    //     uint256 transferAmount,
    //     string memory expectedRevertMessage
    // )
    //     public
    // {
    //     vm.expectRevert(abi.encodePacked(expectedRevertMessage));
    //     transferToken(from, to, transferAmount);
    // }
    // function testCannotTransferMoreThanAvailable() public {
    //     itRevertsTransfer({
    //         from: alice,
    //         to: bob,
    //         transferAmount: maxTransferAmount,
    //         expectedRevertMessage: "ERC20: transfer amount exceeds balance"
    //     });
    // }

    // function testCannotTransferToZero() public {
    //     itRevertsTransfer({
    //         from: alice,
    //         to: address(0),
    //         transferAmount: mintAmount,
    //         expectedRevertMessage: "ERC20: transfer to the zero address"
    //     });
    // }

    function testCannotTransferMoreThanAvailable() public {
        address from = alice;
        address to = bob;
        uint256 transferAmount = maxTransferAmount;

        vm.expectRevert(
            abi.encodeWithSelector(ERC20InsufficientBalance.selector, from, balanceOf(from), transferAmount)
        );
        transferToken(from, to, transferAmount);
    }

    function testCannotTransferToZero() public {
        address from = alice;
        address to = address(0);
        uint256 transferAmount = mintAmount;

        vm.expectRevert(abi.encodeWithSelector(ERC20InvalidReceiver.selector, to));
        transferToken(from, to, transferAmount);
    }
}

contract WhenMintingTokens is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
        console.log("WhenMintingTokens tokens");
    }

    function mintTo(address to, uint256 mintAmount) public {
        vm.prank(to);
        this.mint(to, mintAmount);
    }

    function testAnyoneCanMint() public {
        mintTo(alice, 1e18);
        mintTo(bob, 2e18);

        assertEq(balanceOf(alice), 1e18);
        assertEq(balanceOf(bob), 2e18);
    }

    // function testMintWithFuzzing(address to, uint256 mintAmount) public {
    //     vm.assume(mintAmount != 0);
    //     testMint(to, mintAmount % maxTransferAmount);
    // }
}
