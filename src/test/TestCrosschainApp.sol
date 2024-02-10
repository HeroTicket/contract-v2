// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Router} from "@hyperlane-v3/contracts/client/Router.sol";

contract TestCrosschainApp is Router {
    event MessageSent(uint32 domain, address sender, string message);
    event MessageReceived(uint32 domain, address sender, string message);

    mapping(address => string) public lastMessages;

    constructor(address _mailbox) Router(_mailbox) {}

    function sendMessage(
        uint32 _domain,
        string calldata _message
    ) public payable {
        if (msg.value > 0) {
            _dispatch(_domain, msg.value, abi.encode(_message));
        } else {
            _dispatch(_domain, abi.encode(_message));
        }

        emit MessageSent(_domain, address(this), _message);
    }

    function estimateFee(
        uint32 _domain,
        string calldata _message
    ) public view returns (uint256) {
        return _quoteDispatch(_domain, abi.encode(_message));
    }

    function _handle(
        uint32 _domain,
        bytes32 _sender,
        bytes calldata _message
    ) internal override {
        string memory message = abi.decode(_message, (string));

        address sender = address(uint160(uint256(_sender)));

        lastMessages[sender] = message;

        emit MessageReceived(_domain, sender, message);
    }
}
