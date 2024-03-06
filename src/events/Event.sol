// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEvent} from "./interfaces/IEvent.sol";
import {EventManagement} from "./EventManagement.sol";

contract Event is IEvent, EventManagement {
    uint8 public override eventType;
    string public override eventName;
    string public override eventDescription;
    string public override bannerURI;
    uint64 public override eventStartAt;
    uint64 public override eventEndAt;

    constructor(address _host, CreateEventParams memory params) EventManagement(msg.sender, _host) {
        // TODO: params validation
        eventType = params.eventType;
        eventName = params.eventName;
        eventDescription = params.eventDescription;
        bannerURI = params.bannerURI;
        eventStartAt = params.eventStartAt;
        eventEndAt = params.eventEndAt;
    }
}
