// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEventMetadata, Event} from "./Event.sol";
import {IRaffleEvent} from "./interfaces/IRaffleEvent.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract RaffleEvent is Event, IRaffleEvent, ERC721 {
    uint256 private _tokenId;
    string private _ticketURI;
    mapping(uint256 => uint32) public lockedUntil;

    mapping(address => bool) public applied;
    mapping(address => uint256) public applicantNumber;
    uint256 public totalApplicants;
    uint256 private _applicantId;

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
        eventType = uint8(IEventMetadata.Type.RAFFLE);
        _ticketURI = ticketURI_;
    }

    /**
     * @dev Enter the raffle directly by sending the ticket price
     * @notice The applicant must send the ether greater than or equal to the ticket price
     */
    function enter() public payable {
        address _applicant = msg.sender;

        if (applied[_applicant]) {
            revert AlreadyApplied();
        }

        uint32 now_ = uint32(block.timestamp);

        if (now_ < saleStartAt || now_ > saleEndAt) {
            revert NotApplicable();
        }

        if (msg.value < ticketPrice) {
            revert InsufficientPayment();
        }

        totalApplicants += 1;
        _applicantId += 1;
        applied[_applicant] = true;
        applicantNumber[_applicant] = _applicantId;
    }

    /**
     * @dev Refund the ticket price
     * @notice The applicant can refund the ticket price if the raffle is not yet drawn
     */
    function refund() public {
        // TODO: Implement logic for refund
    }

    /**
     * @dev Draw the raffle
     */
    function draw() public {
        // TODO: Implement logic for random draw
    }

    /**
     * @dev Add an applicant to the raffle
     * @param _applicant address of the applicant
     * @notice Only the manager can add an applicant
     */
    function addApplicant(address _applicant) public onlyManager {
        if (applied[_applicant]) {
            revert AlreadyApplied();
        }

        uint32 now_ = uint32(block.timestamp);

        if (now_ < saleStartAt || now_ > saleEndAt) {
            revert NotApplicable();
        }

        totalApplicants += 1;
        _applicantId += 1;
        applied[_applicant] = true;
        applicantNumber[_applicant] = _applicantId;
    }

    /**
     * @dev Remove an applicant from the raffle by the manager
     * @dev This function is used to cross-chain refund for the applicant
     * @param _applicant address of the applicant
     * @notice Only the manager can remove an applicant
     */
    function removeApplicant(address _applicant) public onlyManager {
        if (!applied[_applicant]) {
            revert NotApplied();
        }

        uint32 now_ = uint32(block.timestamp);

        if (now_ < saleStartAt || now_ > saleEndAt) {
            revert NotRefundable();
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
