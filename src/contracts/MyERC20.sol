// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { ERC20 } from "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    constructor() ERC20("Name", "SYM") {
        this;
    }
}
