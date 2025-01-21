// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./errors.sol";

interface IFooBar {
    /**
     * @dev Mints new tokens for the given account.
     * @param account The address of the account to mint tokens for.
     * @param amount The amount of tokens to mint.
     */
    function mint(address account, uint256 amount) external;
}
