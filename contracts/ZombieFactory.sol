//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract ZombieFactory {
    uint256 dnaDigits = 16;
    uint256 dnaModulus = 10**dnaDigits;

    struct Zombie {
        string name;
        uint256 dna;
    }
    Zombie[] public zombies;
    mapping(uint256 => address) zombieToOwner;
    mapping(address => uint256) ownerZombieCount;

    uint256 id = 0;

    //event
    event NewZombie(uint256 zombieId, string name, uint256 dna);

    function _createZombie(string memory _name, uint256 dna) private {
        zombies.push(Zombie(_name, dna));
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
