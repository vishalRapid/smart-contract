// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// This contract implements the basic functionality of the Compound protocol

// The contract maintains a mapping of users to their deposited and borrowed assets,
// as well as the current interest rates for each asset
contract Compund {
    struct User {
        mapping(string => uint256) depositedAssets;
        mapping(string => uint256) borrowedAssets;
        mapping(string => uint256) interestRates;
    }

    mapping(address => User) users;

    // The contract also maintains a mapping of assets to their total supply and
    // total borrowed amounts, which are used to calculate interest rates

    mapping(string => Asset) assets;
    struct Asset {
        uint256 totalSupply;
        uint256 totalBorrowed;
    }

    // The deposit function allows users to deposit assets into the protocol

    function deposit(string memory asset, uint256 amount) public {
        // Add the deposited assets to the user's balance
        users[msg.sender].depositedAssets[asset] += amount;

        // Update the total supply and total borrowed amounts for the asset
        assets[asset].totalSupply += amount;
        assets[asset].totalBorrowed -= amount;

        // Calculate and update the interest rate for the asset
        // Interest rate = (total borrowed / total supply) * 100%
        // This formula is just an example and could be modified as needed
        users[msg.sender].interestRates[asset] =
            (assets[asset].totalBorrowed / assets[asset].totalSupply) *
            100;
    }

    // The borrow function allows users to borrow assets from the protocol
    function borrow(string memory asset, uint256 amount) public {
        // Check if there is enough liquidity in the system to fulfill the request
        require(
            amount <= assets[asset].totalSupply - assets[asset].totalBorrowed,
            "Insufficient liquidity"
        );
        // Transfer the borrowed assets to the user's balance
        users[msg.sender].borrowedAssets[asset] += amount;
        // Update the total borrowed amount for the asset
        assets[asset].totalBorrowed += amount;
    }

    // The repay function allows users to repay borrowed assets to the protocol
    function repay(string memory asset, uint256 amount) public {
        // Check if the user has sufficient borrowed assets to repay
        require(
            amount <= users[msg.sender].borrowedAssets[asset],
            "Insufficient borrowed assets"
        );
        // Transfer the repaid assets back to the user's deposited balance
        users[msg.sender].depositedAssets[asset] += amount;
        // Update the total borrowed amount for the asset
        assets[asset].totalBorrowed -= amount;
        // Calculate and update the interest rate for the asset
        users[msg.sender].interestRates[asset] =
            (assets[asset].totalBorrowed / assets[asset].totalSupply) *
            100;
        // Calculate and pay interest to the user for the repaid assets
        // Interest earned = (amount repaid * interest rate * time) / 365
        // This formula is just an example and could be modified as needed
        uint256 interestEarned = (amount *
            users[msg.sender].interestRates[asset] *
            1 days) / 365 days;
        users[msg.sender].depositedAssets[asset] += interestEarned;
    }

    // The withdraw function allows users to withdraw their deposited assets from the protocol

    function withdraw(string memory asset, uint256 amount) public {
        // Check if the user has sufficient deposited assets to withdraw
        require(
            amount <= users[msg.sender].depositedAssets[asset],
            "Insufficient deposited assets"
        );
        // Transfer the withdrawn assets to the user's wallet
        users[msg.sender].depositedAssets[asset] -= amount;
        // Update the total supply and total borrowed amounts for the asset
        assets[asset].totalSupply -= amount;
        assets[asset].totalBorrowed += amount;
        // Calculate and update the interest rate for the asset
        users[msg.sender].interestRates[asset] =
            (assets[asset].totalBorrowed / assets[asset].totalSupply) *
            100;
    }

    // The getInterestRate function allows users to query the current interest rate for a given asset
    function getInterestRate(string memory asset)
        public
        view
        returns (uint256)
    {
        return users[msg.sender].interestRates[asset];
    }

    // The getBalance function allows users to query their deposited and borrowed balances for a given asset
    function getBalance(string memory asset)
        public
        view
        returns (uint256, uint256)
    {
        return (
            users[msg.sender].depositedAssets[asset],
            users[msg.sender].borrowedAssets[asset]
        );
    }

    // The getTotalSupply function allows users to query the total supply of a given asset
    function getTotalSupply(string memory asset) public view returns (uint256) {
        return assets[asset].totalSupply;
    }

    // The getTotalBorrowed function allows users to query the total borrowed amount of a given asset
    function getTotalBorrowed(string memory asset)
        public
        view
        returns (uint256)
    {
        return assets[asset].totalBorrowed;
    }
}
