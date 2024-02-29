// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IMailbox} from "@hyperlane-v3/contracts/interfaces/IMailbox.sol";
import {IRouter} from "@hyperlane-v3/contracts/interfaces/IRouter.sol";
import {IPostDispatchHook} from "@hyperlane-v3/contracts/interfaces/hooks/IPostDispatchHook.sol";
import {StandardHookMetadata} from "@hyperlane-v3/contracts/hooks/libs/StandardHookMetadata.sol";
import {TypeCasts} from "@hyperlane-v3/contracts/libs/TypeCasts.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Errors} from "../libs/Errors.sol";

contract HeroTicketRouter is Ownable, IRouter {
    address public immutable MAILBOX;
    address public immutable GAS_PAYMASTER;

    uint32[] private _nftDomains;
    mapping(uint32 => bytes32) private _nftRouters;

    event RemoteRouterEnroll(uint32 indexed domain, bytes32 indexed router);
    event SendNft(uint32 indexed domain, address indexed to, string tokenURI);

    constructor(address _mailbox, address _gasPaymaster) Ownable() {
        MAILBOX = _mailbox;
        GAS_PAYMASTER = _gasPaymaster;
    }

    function domains() external view override returns (uint32[] memory) {
        return _nftDomains;
    }

    function routers(uint32 _domain) external view override returns (bytes32) {
        return _nftRouters[_domain];
    }

    function enrollRemoteRouter(uint32 _domain, bytes32 _router) external onlyOwner {
        _enrollRemoteRouter(_domain, _router);
    }

    function enrollRemoteRouters(uint32[] calldata _domains, bytes32[] calldata _routers) external onlyOwner {
        if (_domains.length != _routers.length) {
            revert Errors.InvalidInputLength();
        }

        for (uint256 i = 0; i < _domains.length; i++) {
            _enrollRemoteRouter(_domains[i], _routers[i]);
        }
    }

    function _enrollRemoteRouter(uint32 _domain, bytes32 _router) internal {
        if (_nftRouters[_domain] != bytes32(0)) {
            revert Errors.AlreadyEnrolled(_domain);
        }
        _nftRouters[_domain] = _router;
        _nftDomains.push(_domain);

        emit RemoteRouterEnroll(_domain, _router);
    }

    function sendNft(uint32 _domainId, address _to, string memory _tokenURI) external payable {
        bytes32 recipientAddress = _tryGetRecipientAddress(_domainId);
        bytes memory messageBody = abi.encode(_to, _tokenURI);

        IMailbox(MAILBOX).dispatch{value: msg.value}(
            _domainId,
            recipientAddress,
            messageBody,
            bytes(""), // TODO: Add custom hook metadata
            IPostDispatchHook(GAS_PAYMASTER)
        );

        emit SendNft(_domainId, _to, _tokenURI);
    }

    function _tryGetRecipientAddress(uint32 _domainId) internal view returns (bytes32 recipientAddress) {
        recipientAddress = _nftRouters[_domainId];
        if (recipientAddress == bytes32(0)) {
            revert Errors.RouterNotEnrolled(_domainId);
        }
    }

    function estimateFee(uint32 _domainId, address _to, string memory _tokenURI) external view returns (uint256) {
        bytes32 recipientAddress = _tryGetRecipientAddress(_domainId);
        bytes memory messageBody = abi.encode(_to, _tokenURI);

        return _estimateFee(_domainId, recipientAddress, messageBody);
    }

    function _estimateFee(uint32 destinationDomain, bytes32 recipientAddress, bytes memory messageBody)
        internal
        view
        returns (uint256)
    {
        return IMailbox(MAILBOX).quoteDispatch(destinationDomain, recipientAddress, messageBody);
    }
}
