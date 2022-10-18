//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RealEstate {
    struct Property {
        string name;
        string city;
        uint256 squareFeet;
        uint256 priceInEth;
        address owner;
        bool onSale;
    }

    Property[] public totalProperties;
    mapping(uint256 => address) public propertyToOwner;
    uint256 public propertiesCount;

    constructor() {
        propertiesCount = 0;
    }

    // property to the contract
    function addProperty(
        string memory _name,
        string memory _city,
        uint256 _squareFeet,
        uint256 _priceInEth,
        bool _onSale
    ) external payable {
        Property memory newProperty = Property(
            _name,
            _city,
            _squareFeet,
            _priceInEth,
            msg.sender,
            _onSale
        );
        totalProperties.push(newProperty);
        propertyToOwner[propertiesCount] = msg.sender;
        propertiesCount++;
    }

    // update on sale parameter for a property by owner
    function changeOnSale(bool _onSale, uint256 propertyId) external {
        require(
            totalProperties[propertyId].owner == msg.sender,
            "NOT THE OWNER"
        );

        totalProperties[propertyId].onSale = _onSale;
    }

    // accept payment for property and transfer payment
    function buyProperty(uint256 propertyId) external payable {
        // checking property on sale or not
        require(
            totalProperties[propertyId].onSale == true,
            "Property not on sale"
        );

        // checking if property own by current user or not
        require(
            totalProperties[propertyId].owner != msg.sender,
            "You currently own this property"
        );

        // checking if prive value is give for the property
        require(
            totalProperties[propertyId].priceInEth <= msg.value,
            "Need more money to buy the property"
        );

        // need to send money to prev owner
        address payable prevOwner = payable(totalProperties[propertyId].owner);
        prevOwner.transfer(msg.value);

        // changing the owner ship of the property
        totalProperties[propertyId].owner = msg.sender;

        propertyToOwner[propertyId] = msg.sender;
    }
}
