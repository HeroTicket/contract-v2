// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Event} from "./Event.sol";
import {IEventExtended} from "./interfaces/IEventExtended.sol";

abstract contract EventExtended is Event, IEventExtended {
    string public override ticketURI;
    uint256 public override ticketPrice;
    uint256 public override maxTickets;
    mapping(uint256 => uint64) public override ticketLockedUntil;
}
