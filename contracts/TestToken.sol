//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    uint8 constant _decimals = 18;
    uint256 constant _totalSupply = 100 * (10**6) * 10**_decimals; // 100m tokens for distribution

    constructor() ERC20("Test", "TST") {
        _mint(msg.sender, _totalSupply);
    }
}
