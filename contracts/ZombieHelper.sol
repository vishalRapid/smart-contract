//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {
    // Start here

    modifier aboveLevel(uint256 _level, uint256 _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function changeName(uint256 _zombieId, string calldata _newName)
        external
        aboveLevel(2, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        require(zombieToOwner[_zombieId] == msg.sender);
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint256 _zombieId, uint256 _newDna)
        external
        aboveLevel(20, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        zombies[_zombieId].dna = _newDna;
    }

    function getZombiesByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](ownerZombieCount[_owner]);
        uint256 counter = 0;
        for (uint256 i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function levelUp(uint256 _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }

    function setLevelUpFee(uint256 _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function withdraw() external onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }
}
