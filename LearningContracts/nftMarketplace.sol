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
        uint256 endTime;
    }

    struct AuctionStruct {
        Auction auctionType;
        uint256 startDate;
        uint256 endDate;
        uint256 startingPrice;
        uint256 reserverPrice; // for dutch auction
    }

    // creating struct for offer
    struct Offer {
        uint256 nftId;
        uint256 tokenId;
        address payable bidder;
        uint256 offerPrice;
    }

    // store nftid along with token details
    mapping(uint256 => Token) Nfts;

    // store offers with mapping to auction
    mapping(uint256 => Offer[]) nftOffers;

    // setting up event for creating an auction
    event newAuction(uint256 auctionId, uint256 tokenId, Auction auctionType);

    // setting up event for creating an offer on an auction
    event newOffer(
        uint256 auctionId,
        uint256 indexed tokenId,
        Auction auctionType,
        uint256 offerPrice
    );

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
            block.timestamp,
            block.timestamp
        );

        // emit event for newly created auction
        emit newAuction(items, _tokenId, Auction.FIXEDPRICE);
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

    //function to create an auction
    function createAuction(
        IERC721 _nft,
        uint256 _tokenId,
        AuctionStruct memory _auctionObject
    ) external {
        // comparing the owner of the nft
        require(_nft.ownerOf(_tokenId) == msg.sender, "Invalid request");

        Token memory auctionPayload;
        if (_auctionObject.auctionType == Auction.FIXEDPRICE) {
            return;
        }

        require(
            _auctionObject.startDate < _auctionObject.endDate,
            "Invalid start and end date"
        );

        require(
            _auctionObject.startDate > block.timestamp,
            "Start time is invalid"
        );
        require(
            _auctionObject.endDate > block.timestamp,
            "End time time is invalid"
        );

        items++;
        if (_auctionObject.auctionType == Auction.ENGLISH) {
            // checking validations for english auction
            auctionPayload = Token(
                _tokenId,
                items,
                _nft,
                payable(msg.sender),
                Auction.ENGLISH,
                true,
                _auctionObject.startingPrice,
                _auctionObject.startDate,
                _auctionObject.endDate
            );
        } else {
            // for dutch auction
        }

        Nfts[items] = auctionPayload;

        // emit event for newly created auction
        emit newAuction(items, _tokenId, _auctionObject.auctionType);
    }

    // create offer to auction
    function createOffer(uint256 _nftId) external payable {
        // creating an offer for the auction
        require(_nftId > 0 && _nftId <= items, "Invalid nft id");
        Token memory auction = Nfts[_nftId];

        if (auction.listingType == Auction.ENGLISH) {
            // check if previous offer exist
            uint256 lastPrice = auction.price;
            Offer[] memory previousOffer = nftOffers[_nftId];
            if (previousOffer.length > 0) {
                //getting latest highest price;
                lastPrice = previousOffer[previousOffer.length - 1].offerPrice;

                // refunding the last bidder
                require(
                    previousOffer[previousOffer.length - 1].bidder.send(
                        previousOffer[previousOffer.length - 1].offerPrice
                    ),
                    "Error refunding previus owner"
                );
            }
            // need to check if previous offer exist and then check
            require(
                msg.value >= lastPrice,
                "Bid needs to be greater than last bid"
            );

            // transfer moeny to contract
            payable(address(this)).transfer(msg.value);

            //create new offer entry
            nftOffers[_nftId].push(
                Offer(_nftId, auction.tokenId, payable(msg.sender), msg.value)
            );

            // we need to refund the previous offer maker
        }
        // creating an event for this auction
        emit newOffer(_nftId, auction.tokenId, Auction.ENGLISH, msg.value);
    }

    // function to accept

    // function to cancel listing of an nft
    function cancelListing(uint256 _nftId) external {
        Token memory currentListing = Nfts[_nftId];

        if (currentListing.listingType == Auction.ENGLISH) {
            // need to delete all offers if any
            delete nftOffers[_nftId];
        }
        delete Nfts[_nftId];
    }

    // function to fetch total price for the nft including platform fee.
    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((Nfts[_itemId].price * (100 + platformFee)) / 100);
    }
}
