// SPDX-License-Identifier: MIT

// Warning: For educational purposes only. Do not use with real funds.

pragma solidity ^0.8.9;

// Interface contract to sealedBidAuctionBase.sol

interface ISealedBidAuction{
    // Getter functions for public variables in target contract
    function auctionTitle() external view returns (string memory title);
    function beneficiary() external view returns (address beneficiary); 
    function biddingEnd()  external view returns (uint256 timestamp); 
    function bids(address, uint256) external view returns(bytes32 sealedBid, uint256 deposit);
    function hasEnded() external view returns(bool hasEnded);
    function highestBid() external view returns (uint256 bidAmount); 
    function highestBidder() external view returns (address bidder); 
    function pendingReturns(address bidder) external view returns(uint256 amountPending); 
    function revealEnd() external view returns (uint256 timestamp); 

    // Public and external functions in the target contract
    function auctionEnd() external;
    function bid(bytes32 _sealedBid) external payable;
    function generateSealedBid(uint256 _bidAmount, bool _isLegit, string calldata _secret) external pure returns(bytes32 sealedBid);
    function reveal(uint256[] calldata _bidAmounts, bool[] calldata _areLegit, string[] calldata _secrets) external; 
    function withdraw() external returns(uint256 amountReturned);

}
