// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEventMetadata} from "./interfaces/IEventMetadata.sol";

abstract contract EventMetadata is IEventMetadata {
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
}
