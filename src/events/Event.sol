// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEvent} from "./interfaces/IEvent.sol";
import {EventManagement} from "./EventManagement.sol";

abstract contract Event is IEvent, EventManagement {
    uint8 public override eventType;
    string public override eventName;
    string public override eventDescription;
    string public override bannerURI;
    uint64 public override eventStartAt;
    uint64 public override eventEndAt;
}
