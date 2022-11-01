// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//ERC TOKEN TO BE USED : 0x56d4F11c189802683fea40F3D9F2cDA3d5A0746c

contract NFTTESTING is ERC721, Ownable {
    using Counters for Counters.Counter;
    address public tokenAddress;
    uint256 public rate = 100 * 10**18;
    Counters.Counter private _tokenIdCounter;
    struct UserLimit {
        uint8 count;
        uint32 timeLimit;
    }
    mapping(address => UserLimit) userLimit;

    mapping(address => bool) whitelisted;

    // batch mint
    constructor(address _tokenAddress) ERC721("NFTTESTING", "NFTT") {
        tokenAddress = _tokenAddress;
    }

    modifier checkUserLimit(address _to) {
        UserLimit memory currentUserStat = userLimit[_to];
        if (currentUserStat.count < 5) {
            currentUserStat.count++;
        } else if (
            currentUserStat.count == 5 &&
            currentUserStat.timeLimit < block.timestamp
        ) {
            // check for timestamp
            currentUserStat.count = 1;
            currentUserStat.timeLimit = uint32(block.timestamp);
        } else {
            revert("Reached maximum limit");
        }
        _;
    }

    function setWhiteList(address _to) public onlyOwner {
        whitelisted[_to] = true;
    }

    function mintNft(address _to, uint256 amount) public {
        require(amount >= rate, "Amount is not sufficint to mindt nft");

        require(whitelisted[msg.sender] == true, "You can't mint this.");

        uint256 amountToTransfer = amount / rate;
        if (amountToTransfer > 1) {
            for (uint256 i = 0; i < amountToTransfer; i++) {
                safeMint(_to);
            }
        } else {
            safeMint(_to);
        }
    }

    function safeMint(address to) internal checkUserLimit(to) {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), rate);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}
