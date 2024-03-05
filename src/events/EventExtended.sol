// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEvent, IEventExtended} from "./interfaces/IEventExtended.sol";
import {EventManagement} from "./EventManagement.sol";

abstract contract EventExtended is IEventExtended, EventManagement {
    uint8 public override eventType;
    string public override eventName;
    string public override eventDescription;
    string public override bannerURI;
    uint64 public override saleStartAt;
    uint64 public override saleEndAt;
    uint64 public override eventStartAt;
    uint64 public override eventEndAt;
    string public override ticketURI;
    uint256 public override ticketPrice;
    uint256 public override maxTickets;
}
