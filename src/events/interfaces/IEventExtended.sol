// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEvent} from "./IEvent.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IEventExtended is IEvent, IERC721 {
    // payment methods for buying tickets
    enum PaymentMethod {
        ETHER,
        ERC20
    }

    // event creation parameters
    struct CreateEventExtendedParams {
        uint8 eventType;
        string eventName;
        string eventSymbol;
        string eventDescription;
        string bannerURI;
        string ticketURI;
        uint256 ticketPrice;
        uint256 maxTickets;
        uint64 saleStartAt;
        uint64 saleEndAt;
        uint64 eventStartAt;
        uint64 eventEndAt;
    }

    // event metadata extended
    function ticketURI() external view returns (string memory);
    function ticketPrice() external view returns (uint256);
    function maxTickets() external view returns (uint256);
    function saleStartAt() external view returns (uint64);
    function saleEndAt() external view returns (uint64);
}
