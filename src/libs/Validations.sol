// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

library Validations {
    error ZeroAddress();
    error EmptyString();
    error ZeroNumber();
    error NotGreaterThan(uint256 _a, uint256 _b);
    error NotGreaterThanOrEqual(uint256 _a, uint256 _b);

    /**
     * @dev Validate the address
     * @param _addr Address to validate
     */
    function mustNotZero(address _addr) public pure {
        if (_addr == address(0)) {
            revert ZeroAddress();
        }
    }

    /**
     * @dev Validate the number
     * @param _number Number to validate
     */
    function mustNotZero(uint256 _number) public pure {
        if (_number == 0) {
            revert ZeroNumber();
        }
    }

    /**
     * @dev Validate the string
     * @param _str String to validate
     */
    function mustNotEmpty(string memory _str) public pure {
        if (bytes(_str).length == 0) {
            revert EmptyString();
        }
    }

    /**
     * @dev Validate the time is after now
     * @param _time Time to validate
     */
    function mustAfterNow(uint256 _time) public view {
        uint256 _now = block.timestamp;
        if (_time <= _now) {
            revert NotGreaterThan(_time, _now);
        }
    }

    /**
     * @dev Validate _a is greater than _b
     * @param _a First number
     * @param _b Second number
     */
    function mustGreaterThan(uint256 _a, uint256 _b) public pure {
        if (_a <= _b) {
            revert NotGreaterThan(_a, _b);
        }
    }

    function mustGreaterThanOrEqual(uint256 _a, uint256 _b) public pure {
        if (_a < _b) {
            revert NotGreaterThanOrEqual(_a, _b);
        }
    }
}
