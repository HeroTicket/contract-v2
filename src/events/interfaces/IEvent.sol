// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IEvent {
    // event types
    enum Type {
        FREE,
        FCFS,
        RAFFLE
    }

    // event creation parameters
    struct CreateEventParams {
        uint8 eventType;
        address host;
        string eventName;
        string eventDescription;
        string bannerURI;
        uint64 saleStartAt;
        uint64 saleEndAt;
        uint64 drawAt;
        uint64 eventStartAt;
        uint64 eventEndAt;
    }

    // event
    event EventCreated(address indexed eventAddress);

    // event metadata
    function eventType() external view returns (uint8);
    function manager() external view returns (address);
    function host() external view returns (address);
    function eventName() external view returns (string memory);
    function eventDescription() external view returns (string memory);
    function bannerURI() external view returns (string memory);
    function saleStartAt() external view returns (uint64);
    function saleEndAt() external view returns (uint64);
    function drawAt() external view returns (uint64);
    function eventStartAt() external view returns (uint64);
    function eventEndAt() external view returns (uint64);
}
