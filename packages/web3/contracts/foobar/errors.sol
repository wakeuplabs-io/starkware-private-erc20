// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IErrors {
    ///@notice Error thrown when max supply is reached
    error maxSupplyReached(uint256 maxSupply);
}
