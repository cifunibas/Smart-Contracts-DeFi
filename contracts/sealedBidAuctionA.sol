// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract SealedBidAuction {
  // Auction parameters
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

  function reveal(uint _bidAmount, bool _isLegit, string calldata _secret)
    external
    onlyAfter(biddingEnd)
    onlyBefore(revealEnd)
  {
    uint refund;
    Bid storage bidToCheck = bids[msg.sender][0]; // Load the first bid of the transaction sender
    bytes32 hashedInput = generateSealedBid(_bidAmount, _isLegit, _secret);
    if (bidToCheck.sealedBid == hashedInput) {
      // Bid is successfully revealed
      refund = bidToCheck.deposit;
      if (_isLegit && bidToCheck.deposit >= _bidAmount) {
        // Bid is valid
        bool success = updateBid(msg.sender, _bidAmount);
        if (success) {
          // Bid is new highest bid
          refund -= _bidAmount;
        }
      }
      // Prevent re-claiming the same deposit.
      bidToCheck.sealedBid = bytes32(0);
    }

    if (refund > 0) {
      payable(msg.sender).transfer(refund);
    }
  }

  function withdraw() external returns (uint amount) {
    amount = pendingReturns[msg.sender];
    if (amount > 0) {
      pendingReturns[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
    }
  }

  function auctionEnd() external onlyAfter(revealEnd) {
    require(!hasEnded, 'Auction already ended');
    emit AuctionEnded(highestBidder, highestBid);
    hasEnded = true;
    payable(beneficiary).transfer(highestBid);
  }

  function generateSealedBid(uint _bidAmount, bool _isLegit, string memory _secret) public pure returns (bytes32 sealedBid) {
    sealedBid = keccak256(abi.encodePacked(_bidAmount, _isLegit, _secret));
  }

}
