// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IEvent {
    // event types
    enum Type {
        FREE,
        FCFS,
        RAFFLE,
        AUCTION
    }

    // event creation parameters
    struct CreateEventParams {
        uint8 eventType;
        string eventName;
        string eventDescription;
        string bannerURI;
        uint64 eventStartAt;
        uint64 eventEndAt;
    }

    // event
    event EventCreated(address indexed eventAddress);

    // event metadata
    function eventType() external view returns (uint8);
    function eventName() external view returns (string memory);
    function eventDescription() external view returns (string memory);
    function bannerURI() external view returns (string memory);
    function eventStartAt() external view returns (uint64);
    function eventEndAt() external view returns (uint64);
}
