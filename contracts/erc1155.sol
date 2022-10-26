// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//ipfs url
// ipfs://bafybeifuv5ee4ko7evn25p6llmjgk64umaakts3qf6kv6auxa6o6cll5ga
//ipfs://bafybeihuw7ku3a5oixm4l6bxijdgfwoamie2thzzcrzmagopmay4oqtseu
//ipfs://bafybeiaubbsxzt2thoprap3hxwee2d5b2wk5sq35id2tglxamckrdgk7zy

// directory ipfs https://ipfs.io/ipfs/bafybeibe2m2hnxqcup34d6tzal75t6zirmyie7duydg5ts6qsxt5tt57lq
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TestingERC1155 is ERC1155 {
    uint256 public constant Art = 1;
    uint256 public constant Art2 = 2;
    uint256 public constant Art3 = 3;

    constructor()
        ERC1155(
            "https://ipfs.io/ipfs/bafybeibe2m2hnxqcup34d6tzal75t6zirmyie7duydg5ts6qsxt5tt57lq/{id}.json"
        )
    {
        _mint(msg.sender, Art, 1, "");
        _mint(msg.sender, Art2, 1, "");
        _mint(msg.sender, Art3, 1, "");
    }
}
