// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./IEventMetadata.sol";

interface IRaffleEvent is IEventMetadata {
    error InsufficientApplicants();

    // getters
    function applied(address _applicant) external view returns (bool);
    function applicantNumber(
        address _applicant
    ) external view returns (uint256);
    function totalApplicants() external view returns (uint256);
    function lockedUntil(uint256 _tokenId) external view returns (uint32);

    // direct interaction
    function enter() external payable;
    function refund() external;
    function draw() external;

    // cross-chain functionality through manager
    function addApplicant(address _applicant) external;
    function removeApplicant(address _applicant) external;
}
