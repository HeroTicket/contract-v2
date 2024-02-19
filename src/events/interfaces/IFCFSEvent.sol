// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./IEventMetadata.sol";

interface IFCFSEvent is IEventMetadata {
    // getters
    function lockedUntil(uint256 _tokenId) external view returns (uint32);

    // direct interaction
    function buyTicket() external payable;

    // cross-chain functionality through manager
    function issueTicket(address _to) external;
}
