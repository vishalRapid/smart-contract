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
    uint32 public timeInterval = 3600;
    Counters.Counter private _tokenIdCounter;
    struct UserLimit {
        uint8 count;
        uint32 timeLimit;
        bool exists;
    }
    mapping(address => UserLimit) userLimit;

    mapping(address => bool) whitelisted;

    constructor(address _tokenAddress) ERC721("NFTTESTING", "NFTT") {
        tokenAddress = _tokenAddress;
        whitelisted[msg.sender] = true;
    }

    modifier checkUserLimit(address _to) {
        UserLimit memory currentUserStat = userLimit[_to];

        if (currentUserStat.exists == false) {
            // checking if user already minted or not
            currentUserStat.count = 1;
            currentUserStat.timeLimit = uint32(block.timestamp + timeInterval);
            currentUserStat.exists = true;
        } else if (currentUserStat.count < 5) {
            // if count is not reached highest point
            currentUserStat.count++;
            if (currentUserStat.timeLimit > block.timestamp) {
                // if previous time is expired
                currentUserStat.timeLimit = uint32(
                    block.timestamp + timeInterval
                );
            }
        } else if (currentUserStat.timeLimit < block.timestamp) {
            // time is expired
            // set new time
            currentUserStat.count = 1;
            currentUserStat.timeLimit = uint32(block.timestamp + timeInterval);
        } else {
            revert("Reached maximum limit");
        }

        _;
    }

    function setWhiteList(address _to, bool _value) public onlyOwner {
        whitelisted[_to] = _value;
    }

    function mintNft(address _to, uint256 amount) public {
        require(amount >= rate, "Amount is insifficient.");

        require(whitelisted[msg.sender] == true, "Invalid access.");
        ERC20 token = ERC20(tokenAddress);
        uint256 amountToTransfer = amount / rate;
        if (amountToTransfer > 1) {
            for (uint256 i = 0; i < amountToTransfer; i++) {
                safeMint(_to, token);
            }
        } else {
            safeMint(_to, token);
        }
    }

    function safeMint(address to, ERC20 _token) internal checkUserLimit(to) {
        _token.transferFrom(msg.sender, address(this), rate);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    // adding functionality to burn nft to get back amount
    function burn(uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: caller is not token owner nor approved"
        );
        _burn(tokenId);
    }
}
