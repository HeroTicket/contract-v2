// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEvent} from "./interfaces/IEvent.sol";

abstract contract Event is IEvent {
    error OnlyManager();
    error OnlyHost();

    uint8 public override eventType;
    address public override manager;
    address public override host;
    string public override eventName;
    string public override eventDescription;
    string public override bannerURI;
    uint64 public override saleStartAt;
    uint64 public override saleEndAt;
    uint64 public override drawAt;
    uint64 public override eventStartAt;
    uint64 public override eventEndAt;

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
}
