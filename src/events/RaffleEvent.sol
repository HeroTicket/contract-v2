// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {EventExtended} from "./EventExtended.sol";
import {IRaffleEvent} from "./interfaces/IRaffleEvent.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../libs/Errors.sol";

contract RaffleEvent is EventExtended, IRaffleEvent, ERC721 {
    uint256 private _tokenId;
    mapping(uint256 => uint32) public lockedUntil;

    mapping(address => bool) public applied;
    mapping(address => uint256) public applicantNumber;
    uint256 public totalApplicants;
    uint256 private _applicantId;

    constructor(CreateEventExtendedParams memory _params, string memory _ticketName, string memory _ticketSymbol)
        ERC721(_ticketName, _ticketSymbol)
    {
        // TODO: validate params
        eventType = uint8(Type.RAFFLE);
        host = _params.host;
        eventName = _params.eventName;
        eventDescription = _params.eventDescription;
        bannerURI = _params.bannerURI;
        ticketURI = _params.ticketURI;
        ticketPrice = _params.ticketPrice;
        maxTickets = _params.maxTickets;
        saleStartAt = _params.saleStartAt;
        saleEndAt = _params.saleEndAt;
        drawAt = _params.drawAt;
        eventStartAt = _params.eventStartAt;
        eventEndAt = _params.eventEndAt;
        manager = msg.sender;
    }

    /**
     * @dev Enter the raffle directly by sending the ticket price
     * @notice The applicant must send the ether greater than or equal to the ticket price
     * @param _applicant address of the applicant
     * @param _method PaymentMethod enum
     */
    function enter(address _applicant, PaymentMethod _method) public payable {
        // TODO: implement method

        // address _applicant = msg.sender;
        // uint256 value = msg.value;

        // if (value < ticketPrice) {
        //     revert Errors.InsufficientPayment();
        // }

        // _addApplicant(_applicant);
    }

    /**
     * @dev add an applicant to the raffle
     * @param _applicant address of the applicant
     */
    function _addApplicant(address _applicant) internal {
        _checkTicketSale();
        _checkApplied(_applicant);

        totalApplicants += 1;
        _applicantId += 1;
        applied[_applicant] = true;
        applicantNumber[_applicant] = _applicantId;
    }

    /**
     * @dev Check if the ticket is on sale
     */
    function _checkTicketSale() internal view {
        uint32 now_ = uint32(block.timestamp);
        if (now_ < saleStartAt || now_ > saleEndAt) {
            revert Errors.NotOnSale();
        }
    }

    /**
     * @dev Check if the applicant has already applied
     * @param _applicant address of the applicant
     */
    function _checkApplied(address _applicant) internal view {
        if (applied[_applicant]) {
            revert Errors.AlreadyApplied();
        }
    }

    /**
     * @dev Draw the raffle
     * @param _randomNumber uint256 random number to draw the raffle
     * @notice Only the manager can draw the raffle
     */
    function draw(uint256 _randomNumber) public onlyManager {
        // TODO: Implement logic for random draw
    }

    /**
     * @dev Remove an applicant from the raffle by the manager
     * @dev This function is used to cross-chain refund for the applicant
     * @param _applicant address of the applicant
     * @notice Only the manager can remove an applicant
     */
    function removeApplicant(address _applicant) public onlyManager {
        if (!applied[_applicant]) {
            revert Errors.NotApplied();
        }

        uint32 now_ = uint32(block.timestamp);

        if (now_ < saleStartAt || now_ > saleEndAt) {
            revert Errors.NotRefundable();
        }

        applied[_applicant] = false;
        applicantNumber[_applicant] = 0;
        totalApplicants -= 1;
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
            revert Errors.TicketLocked();
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
            revert Errors.TicketLocked();
        }

        lockedUntil[tokenId] = uint32(block.timestamp + 1 days);
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
