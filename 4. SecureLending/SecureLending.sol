// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

//This code does not yet include liquidation, interest, pause controls, or all oracle safeguards.

contract SecureLending is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // =========================================
    // STATE VARIABLES
    // =========================================

    IERC20 public collateralToken;
    IERC20 public lendingToken;
    
    mapping(address => uint256) public collateralDeposited;
    mapping(address => uint256) public borrowedAmount;

    //MAX_LTV = 7500 means users can borrow up to 75% of their collateral's USD value.
    uint256 public constant MAX_LTV = 7500;
    uint256 public constant PRECISION = 10000;

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
    // EVENTS
    // =========================================
    event CollateralDeposited(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    // =========================================
    // CONSTRUCTOR
    // =========================================

    constructor(address _priceFeed, address _collateralToken, address _lendingToken) {
        if (_priceFeed == address(0)) {
            revert InvalidFeedAddress();
        }
        priceFeed = AggregatorV3Interface(_priceFeed);

        require(_collateralToken != address(0), "Invalid collateral token");

        require(_lendingToken != address(0), "Invalid lending token");

        collateralToken = IERC20(_collateralToken);

        lendingToken = IERC20(_lendingToken);

        require(IERC20Metadata(_collateralToken).decimals() <= 18, "Unsupported collateral decimals");

        require(IERC20Metadata(_lendingToken).decimals() <= 18, "Unsupported lending decimals");
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

    function depositCollateral(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
    
        uint256 balanceBefore = collateralToken.balanceOf(address(this));
    
        collateralToken.safeTransferFrom(msg.sender, address(this), amount);
    
        uint256 received = collateralToken.balanceOf(address(this)) - balanceBefore;
    
        require(received == amount, "Unsupported transfer fee");
    
        collateralDeposited[msg.sender] += received;
    
        emit CollateralDeposited(msg.sender, received);
    }

    function getCollateralValue(address user) public view returns (uint256) {
        return getCollateralValueForAmount(collateralDeposited[user]);
    }

    function getCollateralValueForAmount(uint256 amount) public view returns (uint256) {
        uint256 price = getLatestPrice();
    
        uint256 tokenDecimals = IERC20Metadata(address(collateralToken)).decimals();
    
        return amount * price / (10 ** tokenDecimals);
    }

    function borrow(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
    
        uint256 collateralValue = getCollateralValue(msg.sender);
    
        uint256 maximumBorrow = collateralValue * MAX_LTV / PRECISION;
    
        uint256 currentDebt = borrowedAmount[msg.sender];
    
        uint256 newDebt = currentDebt + amount;
    
        uint256 newDebtValue = newDebt * 1e18 / (10 ** IERC20Metadata(address(lendingToken)).decimals());
    
        require(newDebtValue <= maximumBorrow,"Insufficient collateral");
    
        require(lendingToken.balanceOf(address(this)) >= amount, "Insufficient lending liquidity" );
    
        borrowedAmount[msg.sender] = newDebt;
    
        lendingToken.safeTransfer(msg.sender, amount);
    
        emit Borrowed(msg.sender, amount);
    }

    function withdrawCollateral(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
    
        require(amount <= collateralDeposited[msg.sender], "Insufficient collateral");
    
        uint256 remainingCollateral = collateralDeposited[msg.sender] - amount;
    
        uint256 remainingCollateralValue = getCollateralValueForAmount(remainingCollateral);
    
        uint256 debtValue = borrowedAmount[msg.sender] * 1e18 / (10 ** IERC20Metadata(address(lendingToken)).decimals());
    
        uint256 maximumBorrow = remainingCollateralValue * MAX_LTV / PRECISION;
    
        require(debtValue <= maximumBorrow, "Withdrawal would make position unsafe");
    
        collateralDeposited[msg.sender] = remainingCollateral;
    
        collateralToken.safeTransfer(msg.sender, amount);
    
        emit CollateralWithdrawn(msg.sender, amount);
    }

    function repay(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
    
        require(amount <= borrowedAmount[msg.sender], "Repayment exceeds debt");
    
        borrowedAmount[msg.sender] -= amount;
    
        lendingToken.safeTransferFrom(msg.sender, address(this), amount);
    
        emit Repaid(msg.sender, amount);
    }
}
