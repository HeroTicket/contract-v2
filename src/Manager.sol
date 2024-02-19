// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IManager} from "./interfaces/IManager.sol";
import {IEventMetadata} from "./events/interfaces/IEventMetadata.sol";
import {Event} from "./events/Event.sol";
import {FCFSEvent} from "./events/FCFSEvent.sol";
import {RaffleEvent} from "./events/RaffleEvent.sol";
import {Validations} from "./libs/Validations.sol";
import {Errors} from "./libs/Errors.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Manager is IManager, Ownable {
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public saleBalances;
    mapping(address => bool) public eventCreated;
    address[] public events;

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
     * @dev Constructor
     * @notice The deployer of this contract is whitelisted by default
     */
    constructor() Ownable() {
        whitelisted[msg.sender] = true;
    }

    /**
     * @dev Set the whitelisted status of an address
     * @param _addr address to set the whitelisted status of
     * @param _whitelisted bool to set the whitelisted status to
     * @notice Only the owner can call this function
     */
    function setWhitelisted(
        address _addr,
        bool _whitelisted
    ) external virtual onlyOwner {
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
            _createFreeEvent(
                _eventName,
                _eventDescription,
                _eventStartAt,
                _eventEndAt
            );
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
        Validations.validateStringNotEmpty(_eventName);
        Validations.validateStringNotEmpty(_eventDescription);
        Validations.validateStringNotEmpty(_ticketURI);
        Validations.validateNumberNotZero(_ticketPrice);
        Validations.validateNumberNotZero(_maxTickets);
        Validations.validateTimeAfterNow(_saleStartAt);
        Validations.validateGreaterThan(_saleEndAt, _saleStartAt);
        Validations.validateGreaterThan(_drawAt, _saleEndAt);
        Validations.validateGreaterThan(_eventStartAt, _drawAt);
        Validations.validateGreaterThan(_eventEndAt, _eventStartAt);

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
        Validations.validateStringNotEmpty(_eventName);
        Validations.validateStringNotEmpty(_eventDescription);
        Validations.validateStringNotEmpty(_ticketURI);
        Validations.validateGreaterThan(_ticketPrice, 0);
        Validations.validateGreaterThan(_maxTickets, 0);
        Validations.validateTimeAfterNow(_saleStartAt);
        Validations.validateGreaterThan(_saleEndAt, _saleStartAt);
        Validations.validateGreaterThan(_eventStartAt, _saleEndAt);
        Validations.validateGreaterThan(_eventEndAt, _eventStartAt);

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
        Validations.validateStringNotEmpty(_eventName);
        Validations.validateStringNotEmpty(_eventDescription);
        Validations.validateTimeAfterNow(_eventStartAt);
        Validations.validateGreaterThan(_eventEndAt, _eventStartAt);

        // Create the event
        Event event_ = new Event(
            msg.sender,
            _eventName,
            _eventDescription,
            0,
            0,
            0,
            0,
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
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external payable virtual {
        // TODO: Implement this function
    }
}
