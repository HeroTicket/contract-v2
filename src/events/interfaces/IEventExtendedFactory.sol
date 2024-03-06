// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEventExtended} from "./IEventExtended.sol";

interface IEventExtendedFactory {
    function events(uint256 index) external view returns (address);
    function createEvent(IEventExtended.CreateEventExtendedParams calldata _params)
        external
        returns (address eventAddress);
    function router() external view returns (address);
    function setRouter(address _router) external;
    function paymentToken() external view returns (address);
    function setPaymentToken(address _paymentToken) external;
}
