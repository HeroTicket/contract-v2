// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

abstract contract EventManagement {
    error OnlyManager();
    error OnlyHost();
    error OnlyManagerOrHost();

    address private _manager;
    address private _host;

    modifier onlyManager() {
        if (msg.sender != _manager) {
            revert OnlyManager();
        }
        _;
    }

    modifier onlyHost() {
        if (msg.sender != _host) {
            revert OnlyHost();
        }
        _;
    }

    modifier onlyManagerOrHost() {
        if (msg.sender != _manager && msg.sender != _host) {
            revert OnlyManagerOrHost();
        }
        _;
    }

    constructor(address manager_, address host_) {
        if (manager_ == address(0)) {
            revert("EventManagement: manager is the zero address");
        }

        if (host_ == address(0)) {
            revert("EventManagement: host is the zero address");
        }

        _manager = manager_;
        _host = host_;
    }

    function manager() public view returns (address) {
        return _manager;
    }

    function host() public view returns (address) {
        return _host;
    }
}
