// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract NftMarketplace {
    // value to be used to keep track of platform fee
    uint256 public platformFee;
    //keeping track if owner of this contract
    address payable public ownerAccount;
    //keeping in track of nfts on the platform
    uint256 public items;

    //auction type
    enum Auction {
        FIXEDPRICE,
        DUTCH,
        ENGLISH
    }

    // listing item on the smart contract
    struct Token {
        uint256 tokenId;
        uint256 nftCount;
        IERC721 nft;
        address payable owner;
        Auction listingType;
        bool activeListing;
        uint256 price;
        uint256 startTime;
    }

    mapping(uint256 => Token) Nfts;

    // setting up fee for transactions and owner account for deducting fee
    constructor(uint256 _platformFee) {
        platformFee = _platformFee;
        ownerAccount = payable(msg.sender);
    }

    //adding item on fixed price listing
    function listFixedPriceItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external payable {
        // paying some value to list the nft
        require(msg.value > 0, "Need to pay some value for registering nft.");
        //checking if you are owner of this nft
        require(
            msg.sender == _nft.ownerOf(_tokenId),
            "You are not the owner of this nft"
        );
        items++;
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        Nfts[items] = Token(
            _tokenId,
            items,
            _nft,
            payable(msg.sender),
            Auction.FIXEDPRICE,
            true,
            _price,
            block.timestamp
        );
    }

    // buy a fixed price item that is currently on listing
    function buyFixedPriceItem(uint256 _nftId) external payable {
        require(_nftId > 0 && _nftId <= items, "item doesn't exist");
        // need to check if this nft is on listing or not
        Token memory currentNft = Nfts[_nftId];
        uint256 totalNftPrice = getTotalPrice(_nftId);
        // checking if current item is on on sale
        require(currentNft.activeListing, "Nft is not on listing");
        // checking for item price
        require(totalNftPrice <= msg.value, "Price is higher");

        // transfer funds
        currentNft.owner.transfer(currentNft.price);

        // transfer fee to owner
        ownerAccount.transfer(totalNftPrice - currentNft.price);

        // transfering the ownership of the nft
        currentNft.nft.transferFrom(
            address(this),
            msg.sender,
            currentNft.tokenId
        );

        // updaitng the current nft
        currentNft.activeListing = false;
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((Nfts[_itemId].price * (100 + platformFee)) / 100);
    }
}
