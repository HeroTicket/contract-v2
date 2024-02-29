// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IHeroTicketRouter} from "./interfaces/IHeroTicketRouter.sol";
import {IEventMetadata} from "./events/interfaces/IEventMetadata.sol";
import {Event} from "./events/Event.sol";
import {FCFSEvent} from "./events/FCFSEvent.sol";
import {RaffleEvent} from "./events/RaffleEvent.sol";
import {Validations} from "./libs/Validations.sol";
import {Errors} from "./libs/Errors.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HeroTicketRouter is IHeroTicketRouter, Ownable {
    address public immutable MAILBOX;

    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public saleBalances;
    mapping(address => bool) public eventCreated;
    address[] public events;

    uint32[] private _domains;
    mapping(uint32 => bytes32) public override routers;

    /**
     * @dev Modifier to check if the caller is whitelisted
     */
    modifier onlyWhitelisted() {
        if (!whitelisted[msg.sender]) {
            revert Errors.NotWhitelisted();
        }
        _;
    }

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
        whitelisted[msg.sender] = true;
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

    // ============ Event Management ============

    /**
     * @dev Set the whitelisted status of an address
     * @param _addr address to set the whitelisted status of
     * @param _whitelisted bool to set the whitelisted status to
     * @notice Only the owner can call this function
     */
    function setWhitelisted(address _addr, bool _whitelisted) external virtual onlyOwner {
        whitelisted[_addr] = _whitelisted;

        emit Whitelist(_addr, _whitelisted);
    }

    /**
     * @dev Create an event
     * @param _eventType type of the event
     * @param _eventName name of the event
     * @param _eventSymbol symbol of the event
     * @param _eventDescription description of the event
     * @param _ticketURI URI of the ticket
     * @param _ticketPrice price of the ticket
     * @param _maxTickets maximum number of tickets
     * @param _saleStartAt start time of the sale
     * @param _saleEndAt end time of the sale
     * @param _drawAt time of the draw (for raffle)
     * @param _eventStartAt start time of the event
     * @param _eventEndAt end time of the event
     * @notice Only whitelisted addresses can call this function
     */
    function createEvent(
        uint8 _eventType,
        string memory _eventName,
        string memory _eventSymbol,
        string memory _eventDescription,
        string memory _ticketURI,
        uint256 _ticketPrice,
        uint256 _maxTickets,
        uint32 _saleStartAt,
        uint32 _saleEndAt,
        uint32 _drawAt,
        uint32 _eventStartAt,
        uint32 _eventEndAt
    ) external virtual onlyWhitelisted {
        IEventMetadata.Type eventType = IEventMetadata.Type(_eventType);

        // create the event based on the type
        if (eventType == IEventMetadata.Type.FCFS) {
            _createFCFSEvent(
                _eventName,
                _eventSymbol,
                _eventDescription,
                _ticketURI,
                _ticketPrice,
                _maxTickets,
                _saleStartAt,
                _saleEndAt,
                _eventStartAt,
                _eventEndAt
            );
        } else if (eventType == IEventMetadata.Type.RAFFLE) {
            _createRaffleEvent(
                _eventName,
                _eventSymbol,
                _eventDescription,
                _ticketURI,
                _ticketPrice,
                _maxTickets,
                _saleStartAt,
                _saleEndAt,
                _drawAt,
                _eventStartAt,
                _eventEndAt
            );
        } else if (eventType == IEventMetadata.Type.FREE) {
            _createFreeEvent(_eventName, _eventDescription, _eventStartAt, _eventEndAt);
        } else {
            revert Errors.InvalidEventType(_eventType);
        }
    }

    /**
     * @dev Create a raffle event
     * @param _eventName name of the event
     * @param _eventSymbol symbol of the event (ERC721)
     * @param _eventDescription description of the event
     * @param _ticketURI URI of the ticket (ERC721)
     * @param _ticketPrice price of the ticket
     * @param _maxTickets maximum number of tickets
     * @param _saleStartAt start time of the sale
     * @param _saleEndAt end time of the sale
     * @param _drawAt time of the draw (for raffle)
     * @param _eventStartAt start time of the event
     * @param _eventEndAt end time of the event
     */
    function _createRaffleEvent(
        string memory _eventName,
        string memory _eventSymbol,
        string memory _eventDescription,
        string memory _ticketURI,
        uint256 _ticketPrice,
        uint256 _maxTickets,
        uint32 _saleStartAt,
        uint32 _saleEndAt,
        uint32 _drawAt,
        uint32 _eventStartAt,
        uint32 _eventEndAt
    ) internal {
        // Validate inputs
        Validations.mustNotEmpty(_eventName);
        Validations.mustNotEmpty(_eventDescription);
        Validations.mustNotEmpty(_ticketURI);
        Validations.mustNotZero(_ticketPrice);
        Validations.mustNotZero(_maxTickets);
        Validations.mustAfterNow(_saleStartAt);
        Validations.mustGreaterThan(_saleEndAt, _saleStartAt);
        Validations.mustGreaterThan(_drawAt, _saleEndAt);
        Validations.mustGreaterThan(_eventStartAt, _drawAt);
        Validations.mustGreaterThan(_eventEndAt, _eventStartAt);

        // Create the event
        RaffleEvent event_ = new RaffleEvent(
            msg.sender,
            _eventName,
            _eventSymbol,
            _eventDescription,
            _ticketURI,
            _ticketPrice,
            _maxTickets,
            _saleStartAt,
            _saleEndAt,
            _drawAt,
            _eventStartAt,
            _eventEndAt
        );

        address eventAddress = address(event_);

        eventCreated[eventAddress] = true;
        events.push(eventAddress);

        emit CreateEvent(eventAddress);
    }

    /**
     * @dev Create a first-come-first-serve event
     * @param _eventName name of the event
     * @param _eventSymbol symbol of the event (ERC721)
     * @param _eventDescription description of the event
     * @param _ticketURI URI of the ticket (ERC721)
     * @param _ticketPrice price of the ticket
     * @param _maxTickets maximum number of tickets
     * @param _saleStartAt start time of the sale
     * @param _saleEndAt end time of the sale
     * @param _eventStartAt start time of the event
     * @param _eventEndAt end time of the event
     */
    function _createFCFSEvent(
        string memory _eventName,
        string memory _eventSymbol,
        string memory _eventDescription,
        string memory _ticketURI,
        uint256 _ticketPrice,
        uint256 _maxTickets,
        uint32 _saleStartAt,
        uint32 _saleEndAt,
        uint32 _eventStartAt,
        uint32 _eventEndAt
    ) internal {
        // Validate inputs
        Validations.mustNotEmpty(_eventName);
        Validations.mustNotEmpty(_eventDescription);
        Validations.mustNotEmpty(_ticketURI);
        Validations.mustGreaterThan(_ticketPrice, 0);
        Validations.mustGreaterThan(_maxTickets, 0);
        Validations.mustAfterNow(_saleStartAt);
        Validations.mustGreaterThan(_saleEndAt, _saleStartAt);
        Validations.mustGreaterThan(_eventStartAt, _saleEndAt);
        Validations.mustGreaterThan(_eventEndAt, _eventStartAt);

        // Create the event
        FCFSEvent event_ = new FCFSEvent(
            msg.sender,
            _eventName,
            _eventSymbol,
            _eventDescription,
            _ticketURI,
            _ticketPrice,
            _maxTickets,
            _saleStartAt,
            _saleEndAt,
            0,
            _eventStartAt,
            _eventEndAt
        );

        address eventAddress = address(event_);

        eventCreated[eventAddress] = true;
        events.push(eventAddress);

        emit CreateEvent(eventAddress);
    }

    /**
     * @dev Create a free event
     * @param _eventName name of the event
     * @param _eventDescription description of the event
     * @param _eventStartAt start time of the event
     * @param _eventEndAt end time of the event
     */
    function _createFreeEvent(
        string memory _eventName,
        string memory _eventDescription,
        uint32 _eventStartAt,
        uint32 _eventEndAt
    ) internal {
        // Validate inputs
        Validations.mustNotEmpty(_eventName);
        Validations.mustNotEmpty(_eventDescription);
        Validations.mustAfterNow(_eventStartAt);
        Validations.mustGreaterThan(_eventEndAt, _eventStartAt);

        // Create the event
        Event event_ = new Event(msg.sender, _eventName, _eventDescription, 0, 0, 0, 0, 0, _eventStartAt, _eventEndAt);

        address eventAddress = address(event_);

        eventCreated[eventAddress] = true;
        events.push(eventAddress);

        emit CreateEvent(eventAddress);
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
