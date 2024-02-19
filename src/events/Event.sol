// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEventMetadata} from "./interfaces/IEventMetadata.sol";

contract Event is IEventMetadata {
    error OnlyManager();
    error OnlyHost();

    uint8 public override eventType;
    address public override manager;

    address public override host;
    string public override eventName;
    string public override eventDescription;
    uint256 public override ticketPrice;
    uint256 public override maxTickets;
    uint32 public override saleStartAt;
    uint32 public override saleEndAt;
    uint32 public override drawAt;
    uint32 public override eventStartAt;
    uint32 public override eventEndAt;

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
        eventType = uint8(IEventMetadata.Type.FREE);
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
