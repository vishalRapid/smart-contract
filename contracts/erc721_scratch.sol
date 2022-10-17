//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "./addressUtils.sol";

interface newNFT {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    // checking how many nfts the current address own
    function balanceOf(address _owner) external view returns (uint256);

    // checking the owner of this token id
    function ownerOf(uint256 _tokenId) external view returns (address);

    // safe transfer token from one owner to another with tokenid
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external payable;

    // safe transfer token from one owner to another with tokenid
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    // send a token from one owner to another
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    // approve means delegate transfers, tranfering a nft on behalf of someone
    function approve(address _approved, uint256 _tokenId) external payable;

    // setting an address approved for all the tokens
    function setApprovalForAll(address _operator, bool _approved) external;

    // fetch get approval address for a token
    function getApproved(uint256 _tokenId) external view returns (address);
}

interface ERC721Metadata {
    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface ERC721Enumerable {
    // give you the value of total supply count
    function totalSupply() external view returns (uint256);

    // from each supply count you can fetch token id, token id is not incremental
    function tokenByIndex(uint256 _index) external view returns (uint256);

    // fetch token  from owner and counter
    function tokenOfOwnerByIndex(address _owner, uint256 _index)
        external
        view
        returns (uint256);
}

interface ERC721TokenReceiver {
    function onERC721Received(
        address _owner,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4);
}

contract MYNFT {
    using AddressUtils for address;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
    // keeping track of tokens count for particular address
    mapping(address => uint256) private ownerToTokenCount;

    // mapping the token index owned by which address
    mapping(uint256 => address) private idToOwner;

    // approved address for particular token
    mapping(uint256 => address) private idToApproved;

    // need to check use of this
    mapping(address => mapping(address => bool)) private ownerToOperators;

    uint256 public totalSupply;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    address _currentOwner;

    string public name;
    string public symbol;
    string public tokenURI;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI
    ) {
        _currentOwner = msg.sender;
        name = _name;
        symbol = _symbol;
        tokenURI = _tokenURI;
    }

    // modifier to check if current user has permission to transfer or not
    modifier canTransfer(uint256 _tokenId) {
        address owner = idToOwner[_tokenId];
        require(
            owner == msg.sender ||
                idToApproved[_tokenId] == msg.sender ||
                ownerToOperators[owner][msg.sender] == true,
            "Transfer not authorized"
        );
        _;
    }

    function _setBaseUrl(string memory _baseURI) external {
        require(msg.sender == _currentOwner);
        tokenURI = _baseURI;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return ownerToTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return idToOwner[_tokenId];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        address owner = idToOwner[_tokenId];
        require(msg.sender == owner, "Not authorized");
        idToApproved[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return idToApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return ownerToOperators[_owner][_operator];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal canTransfer(_tokenId) {
        ownerToTokenCount[_from] -= 1;
        ownerToTokenCount[_to] += 1;
        idToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) internal {
        _transfer(_from, _to, _tokenId);

        if (_to.isContract()) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(
                msg.sender,
                _from,
                _tokenId,
                data
            );
            require(
                retval == MAGIC_ON_ERC721_RECEIVED,
                "recipient SC cannot handle ERC721 tokens"
            );
        }
    }
}
