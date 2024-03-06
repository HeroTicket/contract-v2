// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Event} from "./Event.sol";
import {IEvent, IEventFactory} from "./interfaces/IEventFactory.sol";
import {IWhitelist} from "./interfaces/IWhitelist.sol";

contract EventFactory is IEventFactory, IWhitelist {
    address public override router;
    address[] public override events;
    mapping(address => bool) public override whitelisted;

    modifier onlyRouter() {
        require(msg.sender == router, "EventFactory: Not router");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "EventFactory: Not whitelisted");
        _;
    }

    constructor(address _router) {
        router = _router;
    }

    function createEvent(IEvent.CreateEventParams calldata _params)
        external
        override
        onlyWhitelisted
        returns (address eventAddress)
    {
        eventAddress = address(new Event(msg.sender, _params));
        events.push(eventAddress);

        emit IEvent.EventCreation(eventAddress, msg.sender);
    }

    function setWhitelisted(address account, bool whitelisted_) external override onlyRouter {
        if (account == address(0)) return;
        if (whitelisted[account] == whitelisted_) return;

        whitelisted[account] = whitelisted_;

        emit WhitelistSet(account, whitelisted_);
    }

    function setRouter(address _router) external override onlyRouter {
        require(_router != address(0), "EventFactory: Invalid router address");
        router = _router;
    }
}
