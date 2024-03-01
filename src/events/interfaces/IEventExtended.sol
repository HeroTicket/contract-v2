// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./IEvent.sol";

interface IEventExtended is IEvent {
    // payment methods for buying tickets
    enum PaymentMethod {
        ETHER,
        ERC20
    }

    // event creation parameters
    struct CreateEventExtendedParams {
        uint8 eventType;
        address host;
        string eventName;
        string eventDescription;
        string bannerURI;
        string ticketURI;
        uint256 ticketPrice;
        uint256 drawPrice;
        uint256 maxTickets;
        uint64 saleStartAt;
        uint64 saleEndAt;
        uint64 drawAt;
        uint64 eventStartAt;
        uint64 eventEndAt;
    }

    // event metadata extended
    function ticketURI() external view returns (string memory);
    function ticketPrice() external view returns (uint256);
    function maxTickets() external view returns (uint256);

    // ticket locking mechanism
    function ticketLockedUntil(uint256 _tokenId) external view returns (uint64);
}
