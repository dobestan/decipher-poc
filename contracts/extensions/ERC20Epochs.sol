// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/**
 * @dev Implementation of the ERC20 Epochs extension.
 *
 * Adds the Epoch related features, which provides fully ERC20 supported interfaces
 * with current epoch, and history data via changing ERC20 default {_balances} structure.
 */
contract ERC20Epochs is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
    }
}