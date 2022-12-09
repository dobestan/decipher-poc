// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/utils/Counters.sol";


contract POCAuction {
    using Counters for Counters.Counter;

    event AuctionCreated(
        uint indexed id,
        address indexed maker
    );

    enum Status {
        Created,
        Ended
    }
    struct Auction {
        // Auction Basic Information
        // should updated at Created.
        uint id;
        Status status;
        address maker;

        // Auction Result Information
        // should updated at Ended.
        address taker;
        uint price;
    }
    
    Counters.Counter private _id;
    Auction[] private _auctions;

    function totalAuctionsCount() public view returns (uint) {
        return _id.current();
    }

    function getAuction() public view returns (Auction memory) {
        return _auctions[_id.current() - 1];
    }

    function getAuction(uint id) public view returns (Auction memory) {
        return _auctions[id];
    }

    function createAuction() public returns (uint ) {
        uint currentId = _id.current();

        Auction memory newAuction = Auction(
            currentId,
            Status.Created,
            msg.sender,
            address(0),
            0
        );
        _auctions.push(newAuction);

        emit AuctionCreated(currentId, msg.sender);

        _id.increment();
        return currentId;
    }
}