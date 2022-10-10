//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./Ownable";

contract ZombieFactory is Ownable {
    uint256 dnaDigits = 16;
    uint256 dnaModulus = 10**dnaDigits;
    uint256 cooldownTime = 1 days;

    struct Zombie {
        string name;
        uint256 dna;
        uint32 level;
        uint32 readyTime;
    }

    Zombie[] public zombies;
    mapping(uint256 => address) zombieToOwner;
    mapping(address => uint256) ownerZombieCount;

    uint256 id = 0;

    //event
    event NewZombie(uint256 zombieId, string name, uint256 dna);

    function _createZombie(string memory _name, uint256 dna) internal {
        zombies.push(Zombie(_name, dna, 1, uint32(now + cooldownTime)));
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        id++;
    }

    function _generateRandomDna(string memory _str)
        private
        view
        returns (uint256)
    {
        uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    //create random zombie
    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0, "Already added a zombie");
        uint256 randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
        emit NewZombie(id, _name, randDna);
    }
}
