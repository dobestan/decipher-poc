// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/utils/Counters.sol";


contract POCAuction {
    using Counters for Counters.Counter;

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
}