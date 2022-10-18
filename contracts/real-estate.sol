pragma solidity ^0.8.7;

contract RealEstate {
    struct Property {
        string name;
        string city;
        uint256 squareFeet;
        uint256 priceInEth;
        address owner;
    }

    Property[] totalProperties;
    mapping(uint256 => address) propertyToOwner;
    uint256 propertiesCount;

    constructor() {
        propertiesCount = 0;
    }

    function addProperty(
        string memory _name,
        string memory _city,
        uint256 _squareFeet,
        uint256 _priceInEth
    ) external payable {
        Property memory newProperty = Property(
            _name,
            _city,
            _squareFeet,
            _priceInEth,
            msg.sender
        );
        propertiesCount++;
        totalProperties.push(newProperty);
        propertyToOwner[propertiesCount] = msg.sender;
    }
}
