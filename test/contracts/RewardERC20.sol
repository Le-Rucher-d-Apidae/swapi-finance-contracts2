// SPDX-License-Identifier: MIT
// pragma solidity 0.8.13;
pragma solidity >=0.8.20 <0.9.0;

import { ERC20 } from "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";

contract RewardERC20 is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        this;
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
