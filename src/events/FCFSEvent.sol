// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Event} from "./Event.sol";
import {IFCFSEvent} from "./interfaces/IFCFSEvent.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FCFSEvent is Event, IFCFSEvent, ERC721 {
    uint256 private _tokenId;
    uint256 private _issuedTickets;
    string private _ticketURI;

    mapping(uint256 => uint32) public lockedUntil;

    /**
     * @dev Constructor for the FCFSEvent contract
     * @param _host host of the event
     * @param _name name of the event
     * @param _symbol symbol of the event token
     * @param description description of the event
     * @param ticketURI_ URI for the ticket
     * @param _ticketPrice price of the ticket
     * @param _maxTickets maximum number of tickets available
     * @param _saleStartAt time when the sale starts
     * @param _saleEndAt time when the sale ends
     * @param _drawAt time when the draw is scheduled
     * @param _eventStartAt time when the event starts
     * @param _eventEndAt time when the event ends
     */
    constructor(
        address _host,
        string memory _name,
        string memory _symbol,
        string memory description,
        string memory ticketURI_,
        uint256 _ticketPrice,
        uint256 _maxTickets,
        uint32 _saleStartAt,
        uint32 _saleEndAt,
        uint32 _drawAt,
        uint32 _eventStartAt,
        uint32 _eventEndAt
    )
        Event(
            _host,
            _name,
            description,
            _ticketPrice,
            _maxTickets,
            _saleStartAt,
            _saleEndAt,
            _drawAt,
            _eventStartAt,
            _eventEndAt
        )
        ERC721(_name, _symbol)
    {
        eventType = uint8(Type.FCFS);
        _ticketURI = ticketURI_;
    }

    /**
     * @dev Buy a ticket directly from the contract
     * @notice refund is only available when the purchase is failed on cross-chain purchasement
     */
    function buyTicket() external payable {
        uint256 value = msg.value;

        // Check if the value is enough
        if (value < ticketPrice) {
            revert InsufficientPayment();
        }

        _mintTicket(msg.sender);
    }

    /**
     * @dev Mint a ticket on purchase
     * @param _to address to mint the ticket to
     * @notice Only the manager can call this function
     */
    function issueTicket(address _to) external onlyManager {
        _mintTicket(_to);
    }

    /**
     * @dev Mint a ticket on purchase
     * @param _to address to mint the ticket to
     */
    function _mintTicket(address _to) internal {
        _checkTicketSale();
        _checkTicketAvailability();
        _checkAddressValitidy(_to);
        _checkPurchaseLimit(_to);

        // Mint the ticket
        _issuedTickets++;
        _tokenId++;
        _safeMint(_to, _tokenId);
    }

    /**
     * @dev Check if the ticket sale is ongoing
     */
    function _checkTicketSale() internal view {
        uint32 now_ = uint32(block.timestamp);
        if (now_ < saleStartAt || now_ > saleEndAt) {
            revert NotOnSale();
        }
    }

    /**
     * @dev Check if the ticket is available
     */
    function _checkTicketAvailability() internal view {
        if (_issuedTickets == maxTickets) {
            revert SoldOut();
        }
    }

    /**
     * @dev Check if the address is valid
     * @param _to address to check
     */
    function _checkAddressValitidy(address _to) internal view {
        if (_to == address(0)) {
            revert ZeroAddress();
        }

        if (_to == host) {
            revert HostCannotBuyTicket();
        }
    }

    /**
     * @dev Check if the address has already purchased a ticket
     * @param _to address to check
     */
    function _checkPurchaseLimit(address _to) internal view {
        uint256 balance = balanceOf(_to);
        if (balance > 0) {
            revert OnlyOneTicketPerAddress();
        }
    }

    /**
     * @dev Transfer a ticket from one address to another
     * @param from address to transfer the ticket from
     * @param to address to transfer the ticket to
     * @param tokenId uint256 ID of the ticket to transfer
     * @notice Transferred tickets are locked for 1 day
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
        if (lockedUntil[tokenId] > block.timestamp) {
            revert TicketLocked();
        }

        lockedUntil[tokenId] = uint32(block.timestamp + 1 days);
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfer a ticket from one address to another
     * @param from address to transfer the ticket from
     * @param to address to transfer the ticket to
     * @param tokenId uint256 ID of the ticket to transfer
     * @notice Transferred tickets are locked for 1 day
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        if (lockedUntil[tokenId] > block.timestamp) {
            revert TicketLocked();
        }

        lockedUntil[tokenId] = uint32(block.timestamp + 1 days);
        super.safeTransferFrom(from, to, tokenId);
    }

    /**
     * @dev Return the base URI for the ticket
     * @return string memory
     */
    function _baseURI() internal view override returns (string memory) {
        return _ticketURI;
    }
}
