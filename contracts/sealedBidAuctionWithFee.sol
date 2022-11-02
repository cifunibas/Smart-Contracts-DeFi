// SPDX-License-Identifier: MIT

// Warning: For educational purposes only. Do not use with real funds.

pragma solidity ^0.8.9;

import "./sealedBidAuctionBase.sol";

contract AuctionWithFee is SealedBidAuction {
    address payable public feeRecipient;

    constructor (
        address payable _feeRecipient,
        uint _durationBiddingMinutes,
        uint _durationRevealMinutes
    ) SealedBidAuction(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, _durationBiddingMinutes, _durationRevealMinutes) {
        auctionTitle = "Auction with a fee";
        feeRecipient = _feeRecipient;
    }

    function auctionEnd() public override onlyAfter(revealEnd) {
        require(!hasEnded, 'Auction already ended');
        emit AuctionEnded(highestBidder, highestBid);
        hasEnded = true;
        uint fee = highestBid / 100 * 5;
        feeRecipient.transfer(fee);
        payable(beneficiary).transfer(highestBid - fee);
    }
}
