// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IEventMetadata {
    error NotOnSale();
    error SoldOut();
    error OnlyOneTicketPerAddress();
    error RefundNotAllowed();
    error TicketLocked();
    error AlreadyApplied();
    error NotApplicable();
    error InsufficientPayment();
    error NotApplied();
    error NotRefundable();

    enum Type {
        FREE,
        FCFS,
        RAFFLE
    }

    // event metadata
    function eventType() external view returns (uint8);
    function manager() external view returns (address);
    function host() external view returns (address);
    function eventName() external view returns (string memory);
    function eventDescription() external view returns (string memory);
    function ticketPrice() external view returns (uint256);
    function maxTickets() external view returns (uint256);
    function saleStartAt() external view returns (uint32);
    function saleEndAt() external view returns (uint32);
    function drawAt() external view returns (uint32);
    function eventStartAt() external view returns (uint32);
    function eventEndAt() external view returns (uint32);
}
