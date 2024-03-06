// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IEventManagement {
    function factory() external view returns (address);
    function host() external view returns (address);
}
