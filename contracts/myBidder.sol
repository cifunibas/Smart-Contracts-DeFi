// SPDX-License-Identifier: MIT

// Warning: For educational purposes only. Do not use with real funds.

pragma solidity ^0.8.9;

import "./ISealedBidAuction.sol";

contract myBidder {
    
    // This bidding contract is tied to an EOA, so let's make it ownable.
    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, 'This aint your Bidder');
        _;
    }

    event Received(address indexed sender, uint amount);

    constructor() {
        owner = msg.sender;
    }


    // Let's ensure the contract can receive refunds from the auction contracts
    receive () external payable{
        emit Received(msg.sender, msg.value);
    }


    // Now, the bidding and and revealing functions, callable only by the owner
    function placeBid(address _target, bytes32 _sealedBid) external payable onlyOwner {
        ISealedBidAuction auction = ISealedBidAuction(_target);
        uint deposit = msg.value;
        auction.bid{value: deposit}(_sealedBid);
    }

    function revealBids(address _target, uint[] calldata _bidAmounts, bool[] calldata _areLegit, string[] calldata _secrets) external onlyOwner {
        ISealedBidAuction auction = ISealedBidAuction(_target);
        auction.reveal(_bidAmounts, _areLegit, _secrets);
    }


    // Getting funds back first from the auctions, then from the bidding contract.
    function retrieveFunds(address _target) external {
        ISealedBidAuction auction = ISealedBidAuction(_target);
        auction.withdraw();
    }

    function cashOut(uint _amount) external onlyOwner{
        payable(owner).transfer(_amount);
    }
    
}