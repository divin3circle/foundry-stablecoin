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

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
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
    /**
     *
     * ERRORS ****
     *
     */
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressAndPriceFeedAddressMustBeSameLength();
    error DSCEngine__TokenNotSupported();
    error DSCEngine__DepositCollateralFailed();
    error DSCEngine__HealthFactorTooLow(uint256 healthFactor);

    /**
     *
     * STATE VARIABLES ****
     *
    */
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // 200%
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) public s_priceFeeds; //tokenToPriceFeed
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_dscMinted;
    DecentralizedStableCoin private immutable i_dsc;
    address[] private s_collateralTokens;

     /**
     *
     * EVENTS ****
     *
     */
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);
  

    /**
     *
     * MODIFIERS ****
     *
     */
    modifier moreThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address _tokenAddress) {
        if (s_priceFeeds[_tokenAddress] == address(0)) {
            revert DSCEngine__TokenNotSupported();
          
        }
          _;
    }

    /**
     *
     * FUNCTIONS ****
     *
     */
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressAndPriceFeedAddressMustBeSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    /**
     *
     * EXTERNAL FUNCTIONS ****
     *
     */
    function depositCollateralAndMintDsc() external {}

    /*
    * @notice CEI
    * @param tokenCollateralAddress The address of the token to deposit as collateral
    * @param collateralAmount The amount of the token to deposit as collateral
    *
    */
    function depositCollateral(address tokenCollateralAddress, uint256 collateralAmount)
        external
        moreThanZero(collateralAmount)
        isAllowedToken(tokenCollateralAddress){
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += collateralAmount;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, collateralAmount);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), collateralAmount);
        if (!success) {
            revert DSCEngine__DepositCollateralFailed();
        }
    }

    function redeemCollateral() external {}

    function redeemCollateralForDsc() external {}

    /*
    * @notice CEI
    * @param amountDscToMint The amount of DSC to mint
    * @notice they must have more collateral value that the minimum threshold
    *
    */
    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) {
        s_dscMinted[msg.sender] += amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
        
    }

    function burnDsc() external{}

    function liquidate() external {}

    function getHealthFactor() external view {}


    /**
     *
     * PRIVATE & INTERNAL FUNCTIONS ****
     *
     */
     function _getAccountInformation(address user) private view returns(uint256 totalDscMinted, uint256 collateralValueInUsd){
        totalDscMinted = s_dscMinted[user];
        collateralValueInUsd = getAccountCollateralValueInUsd(user);
     }
      /*
    * Returns how close a user is to liquidation
    * If a user goes below 1, then they can get liquidated
    * @param user The address of the user to check the health factor of 
    *
    */
     function _healthFactor(address user) private view returns(uint256) {
        //total DSC minted
        //total collateral value
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / 100;
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
     }

     function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 healthFactor = _healthFactor(user);
        if(healthFactor < MIN_HEALTH_FACTOR){
            revert DSCEngine__HealthFactorTooLow(healthFactor);
        }
     }

     /**
     *
     * PUBLIC & EXTERNAL VIEW FUNCTIONS ****
     *
     */
     function getAccountCollateralValueInUsd(address user) public view returns(uint256 totalCollateralValueInUsd){
        //loop through each collateral token, get the amount they have and map it to the price 
        // to get usd value
        for(uint256 i; i < s_collateralTokens.length; i++){
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += amount * getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
     }
     function getUsdValue(address token, uint256 amount) public view returns(uint256){
       AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
       (, int256 price, , ,) = priceFeed.latestRoundData();
       return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
     }
}
