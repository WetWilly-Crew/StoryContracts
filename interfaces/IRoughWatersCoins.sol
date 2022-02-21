//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRoughWatersCoins is IERC20 {
  function mint(address to, uint256 amount) external;
}
