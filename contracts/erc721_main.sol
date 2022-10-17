//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// library Counters {
//     struct Counter {
//         // This variable should never be directly accessed by users of the library: interactions must be restricted to
//         // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
//         // this feature: see https://github.com/ethereum/solidity/issues/4637
//         uint256 _value; // default: 0
//     }

//     function current(Counter storage counter) internal view returns (uint256) {
//         return counter._value;
//     }

//     function increment(Counter storage counter) internal {
//         unchecked {
//             counter._value += 1;
//         }
//     }

//     function decrement(Counter storage counter) internal {
//         uint256 value = counter._value;
//         require(value > 0, "Counter: decrement overflow");
//         unchecked {
//             counter._value = value - 1;
//         }
//     }

//     function reset(Counter storage counter) internal {
//         counter._value = 0;
//     }
// }

contract NEWNFT {
    string public name;
    string public symbol;
    string public baseURI;
    address public _owner;

    uint256 public nftCount;
    mapping(uint256 => address) tokenToUser;
    mapping(uint256 => uint256) counterToToken;
    mapping(address => uint256) ownerTokenCount;

    mapping(uint => mapping( address => bool)) approved;

    constructor() {
        name = "MYTOKEN";
        symbol = "MYT";
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender);
        _;
    }

    // changing the base uri of the token
    function _setBaseURI(string memory _baseURI)
        external
        onlyOwner
        returns (string memory)
    {
        baseURI = _baseURI;
        return baseURI;
    }

    function _mint(uint256 _tokenId) external payable onlyOwner {
        ownerTokenCount[msg.sender]++;
        tokenToUser[nftCount] = msg.sender;
        counterToToken[nftCount] = _tokenId;
        nftCount++;
    }

    function tokenCountForAddress(address _address) external view returns(uint256){
        return ownerTokenCount[_address];
    }

    function transfer(address _to, uint _tokenId) external {
        require(tokenToUser[_tokenId] == msg.sender || approved[_tokenId][msg.sender] == true);
         ownerTokenCount[msg.sender]--;
         ownerTokenCount[_to]++;
         tokenToUser[nftCount] = _to;
    }

    function setApproval(address _address, uint _tokenId) external payable {
        require(tokenToUser[_tokenId] == msg.sender);
        approved[_tokenId][_address] = true; 
    }

    function ownerOf(uint _tokenId) external view returns(address){
        return tokenToUser[_tokenId];
    }

}
