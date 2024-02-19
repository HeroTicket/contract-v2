// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEventMetadata, Event} from "./Event.sol";
import {IFCFSEvent} from "./interfaces/IFCFSEvent.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FCFSEvent is Event, IFCFSEvent, ERC721 {
    uint256 private _tokenId;
    uint256 private _issuedTickets;
    string private _ticketURI;

    mapping(uint256 => uint32) public lockedUntil;

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
        eventType = uint8(IEventMetadata.Type.FCFS);
        _ticketURI = ticketURI_;
    }

    function buyTicket() external payable {
        // TODO: Implement buyTicket
    }
    function refund() external {
        // TODO: Implement refund
    }

    /**
     * @dev Mint a ticket on purchase
     * @param _to address to mint the ticket to
     * @notice Only the manager can call this function
     */
    function issueTicket(address _to) external onlyManager {
        uint32 now_ = uint32(block.timestamp);

        // Check if the ticket is on sale
        if (now_ < saleStartAt || now_ > saleEndAt) {
            revert NotOnSale();
        }

        // Check if the ticket is sold out
        if (_issuedTickets == maxTickets) {
            revert SoldOut();
        }

        uint256 balance = balanceOf(_to);

        // Check if the address already has a ticket
        if (balance > 0) {
            revert OnlyOneTicketPerAddress();
        }

        // Mint the ticket
        _issuedTickets++;
        _tokenId++;
        _safeMint(_to, _tokenId);
    }

    /**
     * @dev Burn a ticket on refund
     * @param tokenId uint256 ID of the ticket to burn
     * @notice Only the manager can call this function
     */
    function burnTicket(uint256 tokenId) external onlyManager {
        uint32 now_ = uint32(block.timestamp);

        // Check if the ticket is refundable
        if (now_ >= saleEndAt) {
            revert RefundNotAllowed();
        }

        // Burn the ticket
        _issuedTickets--;
        _burn(tokenId);
    }

    /**
     * @dev Transfer a ticket from one address to another
     * @param from address to transfer the ticket from
     * @param to address to transfer the ticket to
     * @param tokenId uint256 ID of the ticket to transfer
     * @notice Transferred tickets are locked for 1 day
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
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
