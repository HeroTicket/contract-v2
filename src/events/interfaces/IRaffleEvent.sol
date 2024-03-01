// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./IEventExtended.sol";

interface IRaffleEvent is IEventExtended {
    // raffle event getters
    function applied(address _applicant) external view returns (bool);
    function applicantNumber(address _applicant) external view returns (uint256);
    function totalApplicants() external view returns (uint256);

    // raffle event methods
    function enter(address _applicant, PaymentMethod _method) external payable;
    // TODO: add random raffle draw
    // function draw() external;
}
