// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEvent} from "./events/interfaces/IEvent.sol";
import {IEventExtended} from "./events/interfaces/IEventExtended.sol";
import {Event} from "./events/Event.sol";
import {FCFSEvent} from "./events/FCFSEvent.sol";
import {IHeroTicketFactory} from "./interfaces/IHeroTicketFactory.sol";
import {Validations} from "./libs/Validations.sol";
import {Errors} from "./libs/Errors.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HeroTicketFactory is IHeroTicketFactory, Ownable {
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public eventCreated;
    address[] public events;

    constructor() Ownable() {}

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
        IEvent.Type eventType = IEvent.Type(_eventType);

        // create the event based on the type
        if (eventType == IEvent.Type.FCFS) {
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
        } else if (eventType == IEvent.Type.RAFFLE) {
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
        } else if (eventType == IEvent.Type.FREE) {
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
        // RaffleEvent event_ = new RaffleEvent(
        //     msg.sender,
        //     _eventName,
        //     _eventSymbol,
        //     _eventDescription,
        //     _ticketURI,
        //     _ticketPrice,
        //     _maxTickets,
        //     _saleStartAt,
        //     _saleEndAt,
        //     _drawAt,
        //     _eventStartAt,
        //     _eventEndAt
        // );

        // address eventAddress = address(event_);

        // eventCreated[eventAddress] = true;
        // events.push(eventAddress);

        // emit CreateEvent(eventAddress);
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
        // FCFSEvent event_ = new FCFSEvent(
        //     msg.sender,
        //     _eventName,
        //     _eventSymbol,
        //     _eventDescription,
        //     _ticketURI,
        //     _ticketPrice,
        //     _maxTickets,
        //     _saleStartAt,
        //     _saleEndAt,
        //     0,
        //     _eventStartAt,
        //     _eventEndAt
        // );

        // address eventAddress = address(event_);

        // eventCreated[eventAddress] = true;
        // events.push(eventAddress);

        // emit CreateEvent(eventAddress);
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
        // Event event_ = new Event(msg.sender, _eventName, _eventDescription, 0, 0, 0, 0, 0, _eventStartAt, _eventEndAt);

        // address eventAddress = address(event_);

        // eventCreated[eventAddress] = true;
        // events.push(eventAddress);

        // emit CreateEvent(eventAddress);
    }
}
