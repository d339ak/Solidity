// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
// TokenShop deployed at address 0x35Fcb3f91F5c2A04e07e539A42A372027c853c66 on Sepolia Ethereum Testnet. 

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MyERC20} from "contracts/MyERC20.sol";

contract TokenShop is Ownable {

    AggregatorV3Interface internal immutable i_priceFeed;
    MyERC20 internal immutable i_token;

    uint256 public constant TOKEN_DECIMALS = 18;
    uint256 public constant TOKEN_USD_PRICE = 2 * 10 ** TOKEN_DECIMALS; // 2 USD per token with 18 decimals

    event BalanceWithdrawn();
    
    error TokenShop__ZeroETHSent();
    error TokenShop__CouldNotWithdraw();

    constructor(address tokenAddress) Ownable(msg.sender) {
        i_token = MyERC20(tokenAddress);

        /**
        * Network:      Sepolia
        * Aggregatore:  ETH/USD
        * Address:      0x694AA1769357215DE4FAC081bf1f309aDC325306
        */
        i_priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); // ETH/USD price feed
    }
    
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (, int price, , , ) = i_priceFeed.latestRoundData();

        return price;
    }

    function amountToMint(uint256 amountInETH) public view returns (uint256) {
        // Sent amountETH, convert to USD amount
        uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer()) * 10 ** 10; // ETH/USD price with 8 decimals -> 18 decimals
        uint256 ethAmountInUSD = amountInETH * ethUsd / 10 ** 18; // ETH = 18 decimals

        return(ethAmountInUSD * 10 ** TOKEN_DECIMALS) / TOKEN_USD_PRICE; // * 10 ** TOKEN_DECIMALS since tokenAmount (the amount to mint) needs to be in TOKEN_DECIMALS
    }

    receive() external payable {
        // convert the ETH amount to a token amount to mint
        if (msg.value == 0)
            revert TokenShop__ZeroETHSent();

        i_token.mint(msg.sender, amountToMint(msg.value));
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        if(!success)
            revert TokenShop__CouldNotWithdraw();
        
        emit BalanceWithdrawn();
    }
}
