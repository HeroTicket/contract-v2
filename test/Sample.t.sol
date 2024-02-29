// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MockMailbox} from "@hyperlane-v3/contracts/mock/MockMailbox.sol";
import {MockHyperlaneEnvironment} from "@hyperlane-v3/contracts/mock/MockHyperlaneEnvironment.sol";
import {TestRecipient} from "@hyperlane-v3/contracts/test/TestRecipient.sol";
import {TypeCasts} from "@hyperlane-v3/contracts/libs/TypeCasts.sol";
import {TestCrosschainApp} from "../src/test/TestCrosschainApp.sol";

contract BasicTest is Test {
    uint32 public origin = 1;
    uint32 public destination = 2;

    MockMailbox public originMailbox;
    MockMailbox public destinationMailbox;

    TestRecipient public recipient;

    function setUp() public {
        originMailbox = new MockMailbox(origin);
        destinationMailbox = new MockMailbox(destination);
        originMailbox.addRemoteMailbox(destination, destinationMailbox);

        recipient = new TestRecipient();
    }

    function testSendMessage() public {
        string memory message = "Hello, World!";

        originMailbox.dispatch(destination, TypeCasts.addressToBytes32(address(recipient)), bytes(message));

        destinationMailbox.processNextInboundMessage();
        assertEq(string(recipient.lastData()), message);
    }
}

contract RouterTest is Test {
    uint32 public origin = 1;
    uint32 public destination = 2;

    MockHyperlaneEnvironment public environment;

    TestCrosschainApp public originApp;
    TestCrosschainApp public destinationApp;

    function setUp() public {
        environment = new MockHyperlaneEnvironment(origin, destination);

        originApp = new TestCrosschainApp(address(environment.mailboxes(origin)));
        destinationApp = new TestCrosschainApp(address(environment.mailboxes(destination)));

        originApp.enrollRemoteRouter(destination, TypeCasts.addressToBytes32(address(destinationApp)));
        destinationApp.enrollRemoteRouter(origin, TypeCasts.addressToBytes32(address(originApp)));

        originApp.interchainSecurityModule();
    }

    function test_SendMessageFromOrigin() public {
        vm.expectEmit(true, true, true, false);
        emit TestCrosschainApp.MessageSent(destination, address(originApp), "Hello, World!");

        originApp.sendMessage(destination, "Hello, World!");

        vm.expectEmit(true, true, true, false);
        emit TestCrosschainApp.MessageReceived(origin, address(originApp), "Hello, World!");

        environment.processNextPendingMessage();

        assertEq(destinationApp.lastMessages(address(originApp)), "Hello, World!");
    }

    function test_SendMessageFromDestination() public {
        vm.expectEmit(true, true, true, false);
        emit TestCrosschainApp.MessageSent(origin, address(destinationApp), "Hello, World!");

        destinationApp.sendMessage(origin, "Hello, World!");

        vm.expectEmit(true, true, true, false);
        emit TestCrosschainApp.MessageReceived(destination, address(destinationApp), "Hello, World!");

        environment.processNextPendingMessageFromDestination();

        assertEq(originApp.lastMessages(address(destinationApp)), "Hello, World!");
    }
}
