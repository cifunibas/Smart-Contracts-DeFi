// SPDX-License-Identifier: MIT

// Warning: For educational purposes only. Do not use with real funds.

pragma solidity ^0.8.9;

contract SealedBidAuction {
  // Auction parameters
  string public auctionTitle = "Sealed Bid Auction";
  address public immutable beneficiary;
  uint public biddingEnd;
  uint public revealEnd;

  // State of the auction
  uint public highestBid;
  address public highestBidder;
  bool public hasEnded;

  // Allowed withdrawals of previous bids
  mapping(address => uint) public pendingReturns;

  struct Bid {
    bytes32 sealedBid;
    uint deposit;
  }

  mapping(address => Bid[]) public bids;

  event AuctionEnded(address winner, uint amount);

  modifier onlyBefore(uint time) {
    require(block.timestamp < time, 'too late');
    _;
  }

  modifier onlyAfter(uint time) {
    require(block.timestamp > time, 'too early');
    _;
  }

  constructor (address _beneficiary, uint _durationBiddingMinutes, uint _durationRevealMinutes) {
    beneficiary = _beneficiary;
    biddingEnd = block.timestamp + _durationBiddingMinutes * 1 minutes;
    revealEnd = biddingEnd + _durationRevealMinutes * 1 minutes;
  }

  function bid(bytes32 _sealedBid) external payable onlyBefore(biddingEnd) {
    Bid memory newBid = Bid({
      sealedBid: _sealedBid,
      deposit: msg.value
    });

    bids[msg.sender].push(newBid);
  }

  function updateBid(address _bidder, uint _bidAmount) internal returns (bool success) {
    if (_bidAmount <= highestBid) {
      return false;
    }
    if (highestBidder != address(0)) {
      // Refund the previously highest bidder.
      pendingReturns[highestBidder] += highestBid;
    }
    highestBid = _bidAmount;
    highestBidder = _bidder;
    return true;
  }

  function reveal(uint[] calldata _bidAmounts, bool[] calldata _areLegit, string[] calldata _secrets)
    external
    onlyAfter(biddingEnd)
    onlyBefore(revealEnd)
  {
    uint nBids = bids[msg.sender].length;
    require(_bidAmounts.length == nBids, 'invalid number of bid amounts');
    require(_areLegit.length == nBids, 'invalid number of bid legitimacy indicators');
    require(_secrets.length == nBids, 'invalid number of bid secrets');

    uint totalRefund;
    for (uint i = 0; i < nBids; i++) {
      Bid storage bidToCheck = bids[msg.sender][i];
      (uint bidAmount, bool isLegit, string memory secret) = (_bidAmounts[i], _areLegit[i], _secrets[i]);
      bytes32 hashedInput = generateSealedBid(bidAmount, isLegit, secret);
      if (bidToCheck.sealedBid != hashedInput) {
        // Failed to reveal bid.
        // Do not refund deposit and continue with next bid.
        continue;
      }
      totalRefund += bidToCheck.deposit;
      if (isLegit && bidToCheck.deposit >= bidAmount) {
        bool success = updateBid(msg.sender, bidAmount);
        if (success) {
          totalRefund -= bidAmount;
        }
      }

      // Prevent re-claiming the same deposit.
      bidToCheck.sealedBid = bytes32(0);
    }
    if (totalRefund > 0) {
      payable(msg.sender).transfer(totalRefund);
    }
  }

  function withdraw() external returns (uint amount) {
    amount = pendingReturns[msg.sender];
    if (amount > 0) {
      pendingReturns[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
    }
  }

  function auctionEnd() external virtual onlyAfter(revealEnd) {
    require(!hasEnded, 'Auction already ended');
    emit AuctionEnded(highestBidder, highestBid);
    hasEnded = true;
    payable(beneficiary).transfer(highestBid);
  }

  function generateSealedBid(uint _bidAmount, bool _isLegit, string memory _secret) public pure returns (bytes32 sealedBid) {
    sealedBid = keccak256(abi.encodePacked(_bidAmount, _isLegit, _secret));
  }

}
