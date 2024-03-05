// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IEventLock {
    // event
    event TicketLocked(address indexed buyer, uint256 indexed tokenId);

    // lock event methods
    function ticketLockedUntil(uint256 tokenId) external view returns (uint64);
}
