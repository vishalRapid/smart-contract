//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ZombieAttack.sol";
import "./erc721.sol";

contract ZombieOwnership is ZombieAttack, ERC721 {
    constructor() {}

    function balanceOf(address _owner)
        external
        view
        override
        returns (uint256)
    {
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        return zombieToOwner[_tokenId];
    }
}
