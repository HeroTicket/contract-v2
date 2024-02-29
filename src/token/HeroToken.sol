// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HeroToken is ERC20Burnable, Ownable {
    constructor() ERC20("HeroToken", "HT") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public override onlyOwner {
        super.burn(amount);
    }
}
