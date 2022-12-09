// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;


import "./extensions/ERC20Epochs.sol";


contract POC is ERC20Epochs {
    constructor() ERC20Epochs("POC", "POC") {
    }
}