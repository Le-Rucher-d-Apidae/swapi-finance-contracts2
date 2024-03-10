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

contract AptErc20 is ERC20, ERC20Burnable, AccessControl, ERC20Permit {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string constant NAME = "APIDAE02";

    constructor(address defaultAdmin, address minter) ERC20(NAME, "APT02") ERC20Permit(NAME) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
