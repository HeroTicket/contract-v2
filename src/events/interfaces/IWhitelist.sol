// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IWhitelist {
    event WhitelistSet(address indexed account, bool whitelisted);

    function whitelisted(address account) external view returns (bool);
    function setWhitelisted(address account, bool whitelisted_) external;
}
