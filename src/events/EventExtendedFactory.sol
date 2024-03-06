// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {EventExtended} from "./EventExtended.sol";
import {IEvent} from "./interfaces/IEvent.sol";
import {IEventExtended, IEventExtendedFactory} from "./interfaces/IEventExtendedFactory.sol";
import {IWhitelist} from "./interfaces/IWhitelist.sol";

contract EventExtendedFactory is IEventExtendedFactory, IWhitelist {
    address public override router;
    address public override paymentToken;
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

    function createEvent(IEventExtended.CreateEventExtendedParams calldata _params)
        external
        override
        onlyWhitelisted
        returns (address eventAddress)
    {
        if (paymentToken == address(0)) {
            revert("EventFactory: Payment token not set");
        }

        eventAddress = address(new EventExtended(msg.sender, paymentToken, _params));
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

    function setPaymentToken(address _paymentToken) external override onlyRouter {
        require(_paymentToken != address(0), "EventFactory: Invalid payment token address");
        paymentToken = _paymentToken;
    }
}
