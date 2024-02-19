// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {EventMetadata} from "./EventMetadata.sol";

contract Event is EventMetadata {
    error OnlyManager();
    error OnlyHost();

    modifier onlyManager() {
        if (msg.sender != manager) {
            revert OnlyManager();
        }
        _;
    }

    modifier onlyHost() {
        if (msg.sender != host) {
            revert OnlyHost();
        }
        _;
    }

    constructor(
        address _host,
        string memory _name,
        string memory description,
        uint256 _ticketPrice,
        uint256 _maxTickets,
        uint32 _saleStartAt,
        uint32 _saleEndAt,
        uint32 _drawAt,
        uint32 _eventStartAt,
        uint32 _eventEndAt
    ) {
        eventType = uint8(Type.FREE);
        manager = msg.sender;

        host = _host;
        eventName = _name;
        eventDescription = description;
        ticketPrice = _ticketPrice;
        maxTickets = _maxTickets;
        saleStartAt = _saleStartAt;
        saleEndAt = _saleEndAt;
        drawAt = _drawAt;
        eventStartAt = _eventStartAt;
        eventEndAt = _eventEndAt;
    }
}
