// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMessageRecipient} from "@hyperlane-v3/contracts/interfaces/IMessageRecipient.sol";
import {IRouter} from "@hyperlane-v3/contracts/interfaces/IRouter.sol";

interface IHeroTicketRouter is IRouter, IMessageRecipient {
    event RemoteRouterEnroll(uint32 indexed domain, bytes32 indexed router);
    event Whitelist(address indexed _addr, bool _whitelisted);
    event CreateEvent(address indexed _addr);

    function whitelisted(address _addr) external view returns (bool);
    function eventCreated(address _addr) external view returns (bool);
    function setWhitelisted(address _addr, bool _whitelisted) external;
    function createEvent(
        uint8 _eventType,
        string memory _eventName,
        string memory _eventSymbol,
        string memory _eventDescription,
        string memory _ticketURI,
        uint256 _ticketPrice,
        uint256 _maxTickets,
        uint32 _saleStartAt,
        uint32 _saleEndAt,
        uint32 _drawAt,
        uint32 _eventStartAt,
        uint32 _eventEndAt
    ) external;
    function purchaseTicket(address _event) external payable;
}
