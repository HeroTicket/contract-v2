// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./IEventExtended.sol";

interface IFCFSEvent is IEventExtended {
    // event
    event TicketSold(address indexed buyer, uint256 indexed tokenId, PaymentMethod method);

    // fcfs event methods
    function buyTicket(address buyer, PaymentMethod method) external payable;

    // is refundability required?
}
