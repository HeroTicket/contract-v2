// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMessageRecipient} from "@hyperlane-v3/contracts/interfaces/IMessageRecipient.sol";
import {IRouter} from "@hyperlane-v3/contracts/interfaces/IRouter.sol";

interface IHeroTicketRouter is IRouter, IMessageRecipient {
    event RemoteRouterEnroll(uint32 indexed domain, bytes32 indexed router);

    function purchaseTicket(address _event) external payable;
}
