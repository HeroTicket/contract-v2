// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEvent, IEventExtended} from "./interfaces/IEventExtended.sol";
import {EventManagement} from "./EventManagement.sol";
import {IFCFSEvent} from "./interfaces/IFCFSEvent.sol";
import {IEventLock} from "./interfaces/IEventLock.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../libs/Errors.sol";

contract FCFSEvent is IEventExtended, IFCFSEvent, IEventLock, EventManagement, ERC721 {
    uint256 public constant SETTLEMENT_LOCK_PERIOD = 3 days;

    uint8 public override eventType;
    string public override eventName;
    string public override eventDescription;
    string public override bannerURI;
    uint64 public override saleStartAt;
    uint64 public override saleEndAt;
    uint64 public override eventStartAt;
    uint64 public override eventEndAt;
    string public override ticketURI;
    uint256 public override ticketPrice;
    uint256 public override maxTickets;

    address private _paymentToken;
    uint256 private _tokenId;
    uint256 private _issuedTickets;

    mapping(uint256 => uint64) public override ticketLockedUntil;

    /**
     * @dev Constructor for the FCFSEvent contract
     * @param _params CreateEventParams struct
     */
    constructor(address _host, address paymentToken_, CreateEventExtendedParams memory _params)
        EventManagement(msg.sender, _host)
        ERC721(_params.eventName, _params.eventSymbol)
    {
        // TODO: validate params

        eventType = uint8(Type.FCFS);
        eventName = _params.eventName;
        eventDescription = _params.eventDescription;
        bannerURI = _params.bannerURI;
        ticketURI = _params.ticketURI;
        ticketPrice = _params.ticketPrice;
        maxTickets = _params.maxTickets;
        saleStartAt = _params.saleStartAt;
        saleEndAt = _params.saleEndAt;
        eventStartAt = _params.eventStartAt;
        eventEndAt = _params.eventEndAt;
        _paymentToken = paymentToken_;
    }

    /**
     * @dev Return the payment token address
     * @return address
     */
    function paymentToken() external view override returns (address) {
        return _paymentToken;
    }

    /**
     * @dev Buy a ticket directly from the contract
     * @notice refund is only available when the purchase is failed on cross-chain purchasement
     */
    function buyTicket(address buyer, PaymentMethod method) external payable {
        // TODO: implement method

        // uint256 value = msg.value;

        // // Check if the value is enough
        // if (value < ticketPrice) {
        //     revert Errors.InsufficientPayment();
        // }

        // _mintTicket(msg.sender);
    }

    function claimSettlement(address to) external {
        // TODO: implement method
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
            revert Errors.NotOnSale();
        }
    }

    /**
     * @dev Check if the ticket is available
     */
    function _checkTicketAvailability() internal view {
        if (_issuedTickets == maxTickets) {
            revert Errors.SoldOut();
        }
    }

    /**
     * @dev Check if the address is valid
     * @param _to address to check
     */
    function _checkAddressValitidy(address _to) internal view {
        if (_to == address(0)) {
            revert Errors.ZeroAddress();
        }

        if (_to == host()) {
            revert Errors.HostCannotBuyTicket();
        }
    }

    /**
     * @dev Check if the address has already purchased a ticket
     * @param _to address to check
     */
    function _checkPurchaseLimit(address _to) internal view {
        uint256 balance = balanceOf(_to);
        if (balance > 0) {
            revert Errors.OnlyOneTicketPerAddress();
        }
    }

    /**
     * @dev Transfer a ticket from one address to another
     * @param from address to transfer the ticket from
     * @param to address to transfer the ticket to
     * @param tokenId uint256 ID of the ticket to transfer
     * @notice Transferred tickets are locked for 1 day
     */
    function transferFrom(address from, address to, uint256 tokenId) public override(IERC721, ERC721) {
        if (ticketLockedUntil[tokenId] > block.timestamp) {
            revert Errors.TicketLocked();
        }

        ticketLockedUntil[tokenId] = uint32(block.timestamp + 1 days);
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfer a ticket from one address to another
     * @param from address to transfer the ticket from
     * @param to address to transfer the ticket to
     * @param tokenId uint256 ID of the ticket to transfer
     * @notice Transferred tickets are locked for 1 day
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public override(IERC721, ERC721) {
        if (ticketLockedUntil[tokenId] > block.timestamp) {
            revert Errors.TicketLocked();
        }

        ticketLockedUntil[tokenId] = uint32(block.timestamp + 1 days);
        super.safeTransferFrom(from, to, tokenId);
    }

    /**
     * @dev Return the base URI for the ticket
     * @return string memory
     */
    function _baseURI() internal view override returns (string memory) {
        return ticketURI;
    }
}
