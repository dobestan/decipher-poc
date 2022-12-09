// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract POCAuction {
    using Counters for Counters.Counter;

    event AuctionCreated(
        uint indexed id,
        address indexed maker
    );
    event AuctionEnded(
        uint indexed id,
        address indexed maker,
        address indexed taker,
        uint price
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

    address public poc;

    constructor(address poc_) {
        poc = poc_;
    }

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

    function closeAuction(uint id) public payable {
        Auction storage auction = _auctions[id];

        // 1. Check conditions.
        require(auction.status != Status.Ended);
        require(msg.sender == auction.taker);
        require(msg.value >= auction.price);

        // 2. Maker gets {price} amount of Ethers from Taker.(Ethers: Taker → Maker)
        payable(auction.maker).transfer(auction.price);

        // 3. Taker gets 1 POC Token from Maker.(POC: Maker → Taker)
        IERC20(poc).transferFrom(
            auction.maker,
            auction.taker,
            1
        );

        // 4. Update Auction Information
        auction.status = Status.Ended;

        // 5. Events
        emit AuctionEnded(id, auction.maker, auction.taker, auction.price);
    }
}