// SPDX-License-Identifier: MIT

// Warning: For educational purposes only. Do not use with real funds.

pragma solidity ^0.8.9;

contract SimpleAuction {
  // Auction parameters
  address public immutable beneficiary;
  uint public endTime; // As UNIX timestamp

  // State of the auction
  uint public highestBid;
  address public highestBidder;
  bool public hasEnded;

  // Allowed withdrawals of previous bids
  mapping(address => uint) public pendingReturns;

  // Events
  event NewBid(address indexed bidder, uint amount);
  event AuctionEnded(address winner, uint amount);

  constructor (address _beneficiary, uint _durationMinutes) {
    beneficiary = _beneficiary;
    endTime = block.timestamp + _durationMinutes * 1 minutes;
  }

  function bid() public payable {
      require(block.timestamp < endTime, 'Auction ended');
      require(msg.value > highestBid, 'Bid too small');
      if (highestBid != 0) {
          pendingReturns[highestBidder] = highestBid;
      }
      highestBid = msg.value;
      highestBidder = msg.sender;
      emit NewBid(msg.sender, msg.value);
  }

  function withdraw() external returns (uint amount) {
    amount = pendingReturns[msg.sender];
    if (amount > 0) {
      pendingReturns[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
    }
  }

  function auctionEnd() external {
    // 1. Check all conditions
    require(!hasEnded, 'Auction already ended');
    require(block.timestamp >= endTime, 'Wait for auction to end');

    // 2. Apply all internal state changes
    hasEnded = true;
    emit AuctionEnded(highestBidder, highestBid);

    // 3. Interact with other addresses
    payable(beneficiary).transfer(highestBid);
  }

}
