// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.20;
pragma solidity ^0.8.23;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// alias openzeppelin/contracts@5.0.2
import { ERC20 } from "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Burnable.sol";
import { AccessControl } from "@openzeppelin/contracts@5.0.2/access/AccessControl.sol";
import { ERC20Permit } from "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Permit.sol";

import { ERC20Recover } from "./eth-token-recover/ERC20Recover.sol";

contract BwsErc20 is ERC20, ERC20Burnable, AccessControl, ERC20Permit, ERC20Recover {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string internal constant NAME = "BeeWise";

    constructor(
        address defaultAdmin,
        address minter
    )
        ERC20(NAME, "BWS")
        ERC20Permit(NAME)
        ERC20Recover(defaultAdmin)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @dev Recovers a `tokenAmount` of the ERC20 `tokenAddress` locked into this contract
     * and sends them to the `tokenReceiver` address.
     *
     * NOTE: restricting access to owner only. See `RecoverERC20::_recoverERC20`.
     *
     * @param tokenAddress The contract address of the token to recover.
     * @param tokenReceiver The address that will receive the recovered tokens.
     * @param tokenAmount Number of tokens to be recovered.
     */
    function recoverERC20(
        address tokenAddress,
        address tokenReceiver,
        uint256 tokenAmount
    )
        public
        override
        onlyOwner
    {
        _recoverERC20(tokenAddress, tokenReceiver, tokenAmount);
    }
}
