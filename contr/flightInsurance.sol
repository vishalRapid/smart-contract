// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlightInsurance {
    uint256 insurancedAmount = 500;
    uint256 companyInsuranceClaim = 10000;
    address owner;
    IERC20 token;

    struct Insurance {
        uint256 flightNumber;
        address insuredUser;
        address insuranceCompany;
        bool isFlightLate;
    }

    constructor(address _insuranceCurrency) {
        require(_insuranceCurrency != address(0), "INVALID CURRENCY..");
        token = IERC20(_insuranceCurrency);
        owner = msg.sender;
    }

    // fallback function
    fallback() external payable {}

    Insurance[] public insuranceDetails;

    modifier OnlyOwner() {
        require(
            msg.sender == owner,
            "Only owner has the permission to this action."
        );
        _;
    }

    function insureUser(address _userAddress, uint256 _flightNumber) external {
        // need to transfer amount of 500 to contract from user wallet
        IERC20(token).transferFrom(_userAddress, address(this), 500);
        // need to transfer amount of 10000 to contract from company wallet
        IERC20(token).transferFrom(msg.sender, address(this), 10000);

        // store information for the same
        insuranceDetails.push(
            Insurance(_flightNumber, _userAddress, msg.sender, false)
        );
    }

    function updateLateFlight(uint256 _flightNumber) external OnlyOwner {
        // update flight
        for (uint256 i = 0; i < insuranceDetails.length; i++) {
            if (insuranceDetails[i].flightNumber == _flightNumber) {
                // need transfer claim to users
                IERC20(token).transferFrom(
                    address(this),
                    insuranceDetails[i].insuredUser,
                    10500
                );
                insuranceDetails[i].isFlightLate = true;
            }
        }
    }
}
