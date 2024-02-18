// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMessageRecipient} from "@hyperlane-v3/contracts/interfaces/IMessageRecipient.sol";
import {TypeCasts} from "@hyperlane-v3/contracts/libs/TypeCasts.sol";
import {ERC721, ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Errors} from "./lib/Errors.sol";

contract HeroTicket is ERC721URIStorage, Ownable, IMessageRecipient {
    address public immutable MAILBOX;
    uint256 public tokenId;

    uint32 public routerOrigin;
    address public routerAddress;

    modifier onlyMailbox() {
        if (_msgSender() != MAILBOX) {
            revert Errors.NotFromMailbox(_msgSender());
        }
        _;
    }

    constructor(address _mailbox) ERC721("HeroTicketNft", "HTNFT") Ownable() {
        MAILBOX = _mailbox;
    }

    function setRouter(
        uint32 _routerOrigin,
        address _routerAddress
    ) external onlyOwner {
        if (_routerOrigin == 0) {
            revert Errors.InvalidOrigin(_routerOrigin);
        }

        if (_routerAddress == address(0)) {
            revert Errors.ZeroAddress();
        }

        routerOrigin = _routerOrigin;
        routerAddress = _routerAddress;
    }

    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external payable onlyMailbox {
        if (!_isRouter(_origin, _sender)) {
            revert Errors.FromUnknownRouter(_origin, _sender);
        }

        (address _to, string memory _tokenURI) = abi.decode(
            _message,
            (address, string)
        );

        uint256 _tokenId = ++tokenId;

        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
    }

    function _isRouter(
        uint32 _origin,
        bytes32 _sender
    ) internal view returns (bool) {
        if (_origin != routerOrigin) {
            return false;
        }

        address _senderAddress = TypeCasts.bytes32ToAddress(_sender);

        if (_senderAddress != routerAddress) {
            return false;
        }

        return true;
    }

    // TODO: override base URI, transfer
}
