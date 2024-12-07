// SPDX-License-Identifier: MIT 

//Layout of Contract
// version
// imports
// interfaces, libraries, contracts
// Type declarations
// errors
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

import { DecentralizedStableCoin } from "./DecentralizedStableCoin.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

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
contract DSCEngine is ReentrancyGuard {
     /****************** 
     **** ERRORS ****
     ******************/
     error DSCEngine__NeedsMoreThanZero();
     error DSCEngine__TokenAddressAndPriceFeedAddressMustBeSameLength();
     error DSCEngine__TokenNotSupported();


     /****************** 
     **** STATE VARIABLES ****
     ******************/
     mapping(address token => address priceFeed) public s_priceFeeds; //tokenToPriceFeed
     mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

     DecentralizedStableCoin private immutable i_dsc;


    /****************** 
     **** MODIFIERS ****
     ******************/
     modifier moreThanZero(uint256 _amount){
        if(_amount == 0){
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
     }
     modifier isAllowedToken(address _tokenAddress){
        if(s_priceFeeds[_tokenAddress] == address(0)){
            revert DSCEngine__TokenNotSupported();
         _;
     }
     }


     /****************** 
     **** FUNCTIONS ****
     ******************/
     constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if(tokenAddresses.length != priceFeedAddresses.length){
            revert DSCEngine__TokenAddressAndPriceFeedAddressMustBeSameLength();
        }

        for(uint256 i = 0, i < tokenAddresses.length, i++){
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
     }

      /****************** 
     **** EXTERNAL FUNCTIONS ****
     ******************/

    function depositCollateralAndMintDsc() external {}

    /*
    * @param tokenCollateralAddress The address of the token to deposit as collateral
    * @param collateralAmount The amount of the token to deposit as collateral
    *
    */
    function depositCollateral(address tokenCollateralAddress, uint256 collateralAmount) external moreThanZero(collateralAmount) isAllowedToken(tokenCollateralAddress) nonReentrant{
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += collateralAmount;
    }

    function redeemCollateral(){}

    function redeemCollateralForDsc(){}

    function mintDsc(){}

    function burnDsc(){}

    function liquidate(){}

    function getHealthFactor() external view {}
}