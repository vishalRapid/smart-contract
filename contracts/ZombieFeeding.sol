//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ZombieFactory.sol";

contract ZombieFeeding is ZombieFactory {
    function feedAndMultiply(uint256 _zombieId, uint256 _targetDna) public {
        require(zombieToOwner[_zombieId] == msg.sender);
        Zombie storage myZombie = zombies[_zombieId];
        _targetDna = _targetDna % dnaModulus;
        uint256 newDna = (_targetDna + _targetDna) / 2;
        _createZombie("NONAME", newDna);
    }
}
