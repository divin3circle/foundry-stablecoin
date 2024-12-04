// SPDX-License-Identifier: MIT 

//Layout of Contract
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events 
// Modifiers
// Functions

//Layout of Functions
// constructor
// receive function (if it exists)
// fallback function (if it exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity 0.8.28;

/*
* @title Decentralized Stable Coin
* @author divin3circle
* This system is designed to be as minimal as possible, a nd have the tokens maintain a 1
* token == $1 peg
* This stable coin has the properties:
* - Exogenous collateral (ETH & BTC)
* - Algorithmic stable
* - Pegged to the US Dollar
* 
* It is similar to the DAI if DAI had no governance, no fees, and was only backed by
* WETH & WBTC.
* @notice This contract is the core of the DSC System. It handles all the logic for
* minting and redeeming DSC, as well as depositing & withdrawing collateral.
* @notice This contract is VERY loosely based on the MakerDAO DSS (DAI) stable coin system.
*/
contract DSCEngine {

}