// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./IEventExtended.sol";

interface IFCFSEvent is IEventExtended {
    // event
    event TicketSold(address indexed buyer, uint256 indexed tokenId, PaymentMethod method);

    // fcfs event methods
    function paymentToken() external view returns (address);
    function buyTicket(address buyer, PaymentMethod method) external payable;
    function claimSettlement(address to) external;
}
