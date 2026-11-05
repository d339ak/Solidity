// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract SecureLending {

    // =========================================
    // STATE VARIABLES
    // =========================================

    AggregatorV3Interface public priceFeed;

    uint256 public constant MAX_PRICE_AGE = 1 hours;

    uint256 public constant TARGET_DECIMALS = 18;


    // =========================================
    // CUSTOM ERRORS
    // =========================================

    error InvalidFeedAddress();
    error InvalidPrice();
    error InvalidRound();
    error InvalidTimestamp();
    error FutureTimestamp();
    error StalePrice();
    error InvalidDecimals();
    error OracleCallFailed();


    // =========================================
    // CONSTRUCTOR
    // =========================================

    constructor(address _priceFeed) {
        if (_priceFeed == address(0)) {
            revert InvalidFeedAddress();
        }
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // =========================================
    // GET LATEST CHAINLINK PRICE
    // =========================================

    function getLatestPrice() public view returns (uint256)
    {
        // -------------------------------------
        // STEP 1: FETCH LATEST ROUND DATA
        // -------------------------------------
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();

        // -------------------------------------
        // STEP 2: VALIDATE ROUND
        // -------------------------------------
        if (roundId == 0 || answeredInRound < roundId) {
            revert InvalidRound();
        }

        // -------------------------------------
        // STEP 3: VALIDATE PRICE
        // -------------------------------------
        if (answer <= 0) {
            revert InvalidPrice();
        }

        // -------------------------------------
        // STEP 4: VALIDATE TIMESTAMPS
        // -------------------------------------
        if (startedAt == 0 || updatedAt == 0) {
            revert InvalidTimestamp();
        }

        if (updatedAt < startedAt) {
            revert InvalidTimestamp();
        }

        // -------------------------------------
        // STEP 5: CHECK FUTURE TIMESTAMP
        // -------------------------------------
        if (updatedAt > block.timestamp) {
            revert FutureTimestamp();
        }

        // -------------------------------------
        // STEP 6: CHECK STALE PRICE
        // -------------------------------------

        if (block.timestamp - updatedAt > MAX_PRICE_AGE) {
            revert StalePrice();
        }

        // -------------------------------------
        // STEP 7: READ FEED DECIMALS
        // -------------------------------------
        uint8 feedDecimals;

        try priceFeed.decimals() returns (uint8 decimalsValue) {
            feedDecimals = decimalsValue;
        } catch {
            revert OracleCallFailed();
        }

        // -------------------------------------
        // STEP 8: VALIDATE DECIMALS
        // -------------------------------------
        if (feedDecimals > TARGET_DECIMALS) {
            revert InvalidDecimals();
        }

        // -------------------------------------
        // STEP 9: NORMALISE PRICE
        // -------------------------------------

        uint256 price = uint256(answer);

        price = price * (10 ** (TARGET_DECIMALS - feedDecimals));

        // -------------------------------------
        // STEP 10: RETURN NORMALISED PRICE
        // -------------------------------------
        return price;
    }
}
