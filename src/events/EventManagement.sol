// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IEventManagement} from "./interfaces/IEventManagement.sol";

abstract contract EventManagement is IEventManagement {
    error OnlyFactory();
    error OnlyHost();
    error OnlyFactoryOrHost();

    address private _factory;
    address private _host;

    modifier onlyFactory() {
        if (msg.sender != _factory) {
            revert OnlyFactory();
        }
        _;
    }

    modifier onlyHost() {
        if (msg.sender != _host) {
            revert OnlyHost();
        }
        _;
    }

    modifier onlyFactoryOrHost() {
        if (msg.sender != _factory && msg.sender != _host) {
            revert OnlyFactoryOrHost();
        }
        _;
    }

    constructor(address factory_, address host_) {
        if (factory_ == address(0)) {
            revert("EventManagement: factory is the zero address");
        }

        if (host_ == address(0)) {
            revert("EventManagement: host is the zero address");
        }

        _factory = factory_;
        _host = host_;
    }

    function factory() public view returns (address) {
        return _factory;
    }

    function host() public view returns (address) {
        return _host;
    }
}
