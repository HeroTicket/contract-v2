// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IHeroTicketRouter} from "./interfaces/IHeroTicketRouter.sol";
import {Errors} from "./libs/Errors.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HeroTicketRouter is IHeroTicketRouter, Ownable {
    address public immutable MAILBOX;

    uint32[] private _domains;
    mapping(uint32 => bytes32) public override routers;

    /**
     * @dev Modifier to check if the caller is the mailbox
     */
    modifier onlyMailbox() {
        if (msg.sender != MAILBOX) {
            revert Errors.NotFromMailbox(msg.sender);
        }
        _;
    }

    /**
     * @dev Constructor
     * @notice The deployer of this contract is whitelisted by default
     */
    constructor(address _mailbox) Ownable() {
        MAILBOX = _mailbox;
    }

    // ============ Cross-Chain Router ============

    /**
     * @dev Get the list of enrolled domains
     * @return array of enrolled domains
     */
    function domains() external view override returns (uint32[] memory) {
        return _domains;
    }

    /**
     * @dev Enroll a remote router
     * @param _domain domain of the remote router
     * @param _router address of the remote router
     * @notice Only the owner can call this function
     */
    function enrollRemoteRouter(uint32 _domain, bytes32 _router) external override onlyOwner {
        _enrollRemoteRouter(_domain, _router);
    }

    /**
     * @dev Enroll multiple remote routers
     * @param domains_ array of domains of the remote routers
     * @param _routers array of addresses of the remote routers
     * @notice Only the owner can call this function
     */
    function enrollRemoteRouters(uint32[] calldata domains_, bytes32[] calldata _routers) external override onlyOwner {
        if (domains_.length != _routers.length) {
            revert Errors.InvalidInputLength();
        }

        for (uint256 i = 0; i < domains_.length; i++) {
            _enrollRemoteRouter(domains_[i], _routers[i]);
        }
    }

    /**
     * @dev Enroll a remote router
     * @param _domain domain of the remote router
     * @param _router address of the remote router
     */
    function _enrollRemoteRouter(uint32 _domain, bytes32 _router) internal {
        if (routers[_domain] != bytes32(0)) {
            revert Errors.AlreadyEnrolled(_domain);
        }
        routers[_domain] = _router;
        _domains.push(_domain);

        emit RemoteRouterEnroll(_domain, _router);
    }

    /**
     * @dev Purchase a ticket on the same domain as the event
     * @param _event address of the event
     * @notice Only whitelisted addresses can call this function
     */
    function purchaseTicket(address _event) external payable virtual {
        // TODO: Implement this function
    }

    /**
     * @dev Handle a message from the cross-chain router
     * @param _origin domain of the sender
     * @param _sender address of the sender
     * @param _message message body
     */
    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable virtual {
        // TODO: Implement this function
    }
}
