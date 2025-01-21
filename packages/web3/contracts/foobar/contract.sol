// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./errors.sol";
import "./interface.sol";

/**
 * @title Foobar
 * @dev Simple ERC20 Token example, with an initial supply sent to the deployer
 */
contract Foobar is ERC20, IErrors, Ownable, IFooBar {
    uint256 public maxSupply = 1_000_000 * 10 ** decimals();

    /**
     * @dev Constructor that gives msg.sender all of the initial supply.
     */
    constructor() ERC20("FoobarToken", "LCT24") Ownable(msg.sender) {}

    /// @inheritdoc IFooBar
    function mint(address account, uint256 amount) public onlyOwner {
        if (totalSupply() + amount > maxSupply) {
            revert maxSupplyReached(maxSupply);
        }
        _mint(account, amount);
    }
}
