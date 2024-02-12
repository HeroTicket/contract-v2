// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

library Errors {
    error InvalidOrigin(uint32 _origin);
    error ZeroAddress();
    error NotFromMailbox(address _sender);
    error FromUnknownRouter(uint32 _origin, bytes32 _sender);
}
