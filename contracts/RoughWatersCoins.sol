// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoughWatersCoins is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("RoughWatersCoins", "RWC") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
