// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEvent} from "./IEvent.sol";

interface IEventFactory {
    function events(uint256 index) external view returns (address);
    function createEvent(IEvent.CreateEventParams calldata _params) external returns (address eventAddress);
    function router() external view returns (address);
    function setRouter(address _router) external;
}
