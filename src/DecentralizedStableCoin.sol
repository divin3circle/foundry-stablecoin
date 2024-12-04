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

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


/*
* @title Decentralized Stable Coin
* @author divin3circle
* @notice A decentralized stable coin that is pegged to the US Dollar
* Collateral: Exogenous (ETH & BTC)
* Minting: Algorithmic
* Relative Stability: Pegged to the US Dollar / KES
*
* This is the contract meant to be governed by the DSCEngine. This contract is juts the ERC20 implementation of our stable coin system.
*
*/
contract DecentralizedStableCoin is ERC20Burnable, Ownable {

    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();
    error DecentralizedStableCoin__MintAmountExceedsMaxSupply();
    error DecentralizedStableCoin__NotToZeroAddress();

     constructor() ERC20("DecentralizedStableCoin", "DSC") Ownable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266){}

    function burn(uint256 _amount) public override onlyOwner {
       uint256 balance = balanceOf(msg.sender);
       if(_amount <= 0){
        revert DecentralizedStableCoin__MustBeMoreThanZero();
       }
       if(balance < _amount){
           revert DecentralizedStableCoin__BurnAmountExceedsBalance();
       }
       super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool){
        if(_to == address(0)){
            revert DecentralizedStableCoin__NotToZeroAddress();
        }
        if(_amount <= 0){
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}