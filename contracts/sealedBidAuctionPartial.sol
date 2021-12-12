//SPDX-License-Identifier: MIT

// Warning: Do not use for actual funds.

pragma solidity ^0.8.9;

contract SealedBidAuction {
    //Auction parameters
    address public immutable beneficiary;
    uint public biddingEnd;
    uint public revealEnd;

    // State of the Auction
    uint public highestBid;
    address public highestBidder;
    bool public hasEnded;

    // Amount withdrawable of previous bids
    mapping(address => uint) pendingReturns;

    // Events
    event AuctionEnded(address winner, uint amount);

    constructor (address _beneficiary, uint _durationBiddingMinutes, uint _durationRevealMinutes) {
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _durationBiddingMinutes * 1 minutes;
        revealEnd = biddingEnd + _durationRevealMinutes * 1 minutes;
    }

    function withdraw() external returns (uint amount) {
        amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
        // optional: return amount;
    }

    function generateSealedBid(uint _bidAmount, bool _isLegit, string memory _secret) public pure returns (bytes32 sealedBid) {
        sealedBid = keccak256(abi.encodePacked(
            _bidAmount, _isLegit, _secret));
    }

}
