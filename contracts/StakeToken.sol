// //SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Context.sol";

// interface Token {
//     function transfer(address recipient, uint256 amount)
//         external
//         returns (bool);

//     function balanceOf(address account) external view returns (uint256);

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) external returns (uint256);
// }

// contract StakeTST {
//     Token tstToken;
//     // 30 Days (30 * 24 * 60 * 60)
//     uint256 public planDuration = 2592000;
//     // 180 Days (180 * 24 * 60 * 60)
//     uint256 _planExpired = 15552000;

//     uint8 public interestRate = 32;

//     uint256 public planExpired;
//     uint8 public totalStakers;

//     struct StakeInfo {
//         uint256 startTS;
//         uint256 endTS;
//         uint256 amount;
//         uint256 claimed;
//     }

//     mapping(address => StakeInfo) public stakeInfos;
//     mapping(address => bool) public addressStaked;

//     constructor(Token _tokenAddress) {
//         require(
//             address(_tokenAddress) != address(0),
//             "Token Address cannot be address 0"
//         );
//         aplToken = _tokenAddress;
//         planExpired = block.timestamp + _planExpired;
//         totalStakers = 0;
//     }

//     function stakeToken(uint256 _stakeAmount) external payable {
//         require(_stakeAmount > 0, "Invalid stake amount");
//         require(block.timestamp < _planExpired, "Plan expired");
//         require(addressStaked[_msgSender()] == false, "Already staked");
//         require(
//             tstToken.balanceOf(_msgSender()) >= stakeAmount,
//             "Insufficient Balance"
//         );

//         aplToken.transferFrom(_msgSender(), address(this), stakeAmount);
//         totalStakers++;
//         addressStaked[_msgSender()] = true;

//         stakeInfos[_msgSender()] = StakeInfo({
//             startTS: block.timestamp,
//             endTS: block.timestamp + planDuration,
//             amount: stakeAmount,
//             claimed: 0
//         });

//         emit Staked(_msgSender(), stakeAmount);
//     }

//     function claimReward() external {}

//     function pause() external onlyOwner {
//         _pause();
//     }

//     function unpause() external onlyOwner {
//         _unpause();
//     }
// }
