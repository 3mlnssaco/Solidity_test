//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Enum {
    enum Status {
        NotSale,
        Auction,
        Sales,
        bid,
        sold
    }

    Status public auctionStatus;

    function auctionStart() public {
        auctionStatus = Status.Auction;
    }

    function bid() public {
        auctionStatus = Status.bid;
    }
} 