// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TESTTOKEN is ERC20, Ownable {
    constructor() ERC20("TESTTOKEN", "TST") {
        _mint(msg.sender, 10000000 * 10**decimals());
    }
}
