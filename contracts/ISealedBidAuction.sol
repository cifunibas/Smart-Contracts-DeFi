// SPDX-License-Identifier: MIT

// Warning: For educational purposes only. Do not use with real funds.

pragma solidity ^0.8.9;

interface ISealedBidAuction{
	// Getter functions for public variables in target contract
	function beneficiary() external returns (address); 
    function biddingEnd()  external returns (uint256); 
    function bids(address, uint256) external returns(bytes32 sealedBid, uint256 deposit);
    function hasEnded() external returns(bool);
    function highestBid() external returns (uint256); 
    function highestBidder() external returns (address); 
    function pendingReturns(address) external returns(uint256); 
    function revealEnd() external returns (uint256); 

    // Public and external functions in the target contract
    function auctionEnd() external;
    function bid(bytes32 _sealedBid) external payable;
    function generateSealedBid(uint256 _bidAmount, bool _isLegit, string calldata _secret) external returns(bytes32 sealedBid);
    function reveal(uint256[] calldata _bidAmounts, bool[] calldata _areLegit, string[] calldata _secrets) external; 
    function withdraw() external returns(uint256 amount);

}
