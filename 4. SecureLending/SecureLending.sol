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
    // LIQUIDATION CONSTANTS
    // =========================================
    uint256 public constant LIQUIDATION_THRESHOLD = 8000; // 80% - Position can be liquidated if debt exceeds this
    uint256 public constant LIQUIDATION_BONUS = 500;     // 5% bonus paid to liquidators (in basis points)

    // =========================================
    // LENDER / LIQUIDITY POOL STATE
    // =========================================
    mapping(address => uint256) public supplierBalances;
    uint256 public totalLiquidity;

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
    // NEW EVENTS
    // =========================================
    event Liquidated(address indexed borrower, address indexed liquidator, uint256 repayAmount, uint256 collateralSeized);

    event Supplied(address indexed supplier, uint256 amount);
    event Withdrawn(address indexed supplier, uint256 amount);

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

    // for 1 usdc, amount's value will be 1000,000 (as usdc has 6 decimals)
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

    // this function takes in the amount which is in weth * 1e18 and returns usd * 1e18
    function getCollateralValueForAmount(uint256 amount) public view returns (uint256) {
        uint256 price = getLatestPrice();
    
        uint256 tokenDecimals = IERC20Metadata(address(collateralToken)).decimals();
    
        return amount * price / (10 ** tokenDecimals);
    }

    //this function takes in the amount which is in usdt * 1e6
    function borrow(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
    
        //this value is in usd * 1e18
        uint256 collateralValue = getCollateralValue(msg.sender);

        //this value is also in usd * 1e18
        uint256 maximumBorrow = collateralValue * MAX_LTV / PRECISION;

        //this value is in usdt * 1e6
        uint256 currentDebt = borrowedAmount[msg.sender];

        //this value in in usdt * 1e6
        uint256 newDebt = currentDebt + amount;

        //this value is now in usd + 1e18
        uint256 newDebtValue = newDebt * 1e18 / (10 ** IERC20Metadata(address(lendingToken)).decimals());

        require(newDebtValue <= maximumBorrow,"Insufficient collateral");

        //this check is happening in, usdt * 1e6. But liquidity functionality is missing at the moment.
        require(lendingToken.balanceOf(address(this)) >= amount, "Insufficient lending liquidity" );

        //this value will be in usdt * 1e6
        borrowedAmount[msg.sender] = newDebt;

        //this will transfer the amount (which is in usdt * 1e6) to the sender.
        lendingToken.safeTransfer(msg.sender, amount);
    
        emit Borrowed(msg.sender, amount);
    }

    //the amount paramater is in weth * 1e18
    function withdrawCollateral(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
    
        require(amount <= collateralDeposited[msg.sender], "Insufficient collateral");
    
        uint256 remainingCollateral = collateralDeposited[msg.sender] - amount;

        //this value will be in usd * 1e18
        uint256 remainingCollateralValue = getCollateralValueForAmount(remainingCollateral);

        //borrowedAmount[msg.sender] is in usdt * 1e6; 
        //debtValue variable will hold now usd * 1e18
        uint256 debtValue = borrowedAmount[msg.sender] * 1e18 / (10 ** IERC20Metadata(address(lendingToken)).decimals());

        //this will be in usd * 1e18
        uint256 maximumBorrow = remainingCollateralValue * MAX_LTV / PRECISION;
    
        require(debtValue <= maximumBorrow, "Withdrawal would make position unsafe");
    
        collateralDeposited[msg.sender] = remainingCollateral;
    
        collateralToken.safeTransfer(msg.sender, amount);
    
        emit CollateralWithdrawn(msg.sender, amount);
    }

    //the amount paramater is in usdt * 1e6
    function repay(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
    
        require(amount <= borrowedAmount[msg.sender], "Repayment exceeds debt");
    
        borrowedAmount[msg.sender] -= amount;
    
        lendingToken.safeTransferFrom(msg.sender, address(this), amount);
    
        emit Repaid(msg.sender, amount);
    }

    /// Allows anyone to liquidate an unhealthy borrower position
    /// @param borrower The address of the user whose position is undercollateralized
    /// @param repayAmount The amount of lending token the liquidator is paying back
    function liquidate(address borrower, uint256 repayAmount) external nonReentrant {
        require(repayAmount > 0, "Amount must be greater than zero");
        require(borrower != msg.sender, "Cannot liquidate yourself");
        
        uint256 debt = borrowedAmount[borrower];
        require(debt > 0, "Borrower has no debt");
        
        // Cap the repayment amount to the borrower's total debt if it exceeds it
        if (repayAmount > debt) {
            repayAmount = debt; 
        }

        // 1. Get borrower's collateral and debt values (both in USD * 1e18)
        uint256 collateralValue = getCollateralValue(borrower);
        uint256 debtValue = debt * 1e18 / (10 ** IERC20Metadata(address(lendingToken)).decimals());

        // 2. Check if position is undercollateralized based on the liquidation threshold
        uint256 liquidationLimit = collateralValue * LIQUIDATION_THRESHOLD / PRECISION;
        require(debtValue > liquidationLimit, "Position is healthy");

        // 3. Calculate the USD value of the debt being repaid
        uint256 repayValue = repayAmount * 1e18 / (10 ** IERC20Metadata(address(lendingToken)).decimals());
        
        // 4. Add the liquidation bonus to the seized value (repayValue + bonus)
        uint256 seizedValue = repayValue * (PRECISION + LIQUIDATION_BONUS) / PRECISION;
        
        // 5. Convert the seized USD value back into collateral token amount
        uint256 tokenDecimals = IERC20Metadata(address(collateralToken)).decimals();
        uint256 seizedCollateral = seizedValue * (10 ** tokenDecimals) / getLatestPrice();

        // Ensure we do not try to seize more collateral than the borrower actually deposited
        uint256 totalCollateral = collateralDeposited[borrower];
        if (seizedCollateral > totalCollateral) {
            seizedCollateral = totalCollateral;
        }

        // 6. Update state variables
        borrowedAmount[borrower] -= repayAmount;
        collateralDeposited[borrower] -= seizedCollateral;

        // 7. Execute token transfers
        // Liquidator pays back the debt to the contract
        lendingToken.safeTransferFrom(msg.sender, address(this), repayAmount);
        
        // Contract sends the seized collateral (plus bonus) to the liquidator
        collateralToken.safeTransfer(msg.sender, seizedCollateral);

        // 8. Emit liquidation event
        emit Liquidated(borrower, msg.sender, repayAmount, seizedCollateral);
    }

    /// Allows lenders to deposit lending tokens to provide liquidity for borrowers
    /// @param amount The amount of lending tokens to deposit
    function supply(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");

        // Update state
        supplierBalances[msg.sender] += amount;
        totalLiquidity += amount;

        // Transfer lending tokens from lender to contract
        lendingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Supplied(msg.sender, amount);
    }

    /// Allows lenders to withdraw their supplied tokens (plus any earnings if interest is implemented)
    /// @param amount The amount of lending tokens to withdraw
    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(supplierBalances[msg.sender] >= amount, "Insufficient supplied balance");

        // Ensure the contract actually has enough available liquidity 
        // (i.e., tokens not currently locked up as active borrows)
        uint256 contractBalance = lendingToken.balanceOf(address(this));
        require(contractBalance >= amount, "Not enough liquidity available in pool");

        // Update state
        supplierBalances[msg.sender] -= amount;
        totalLiquidity -= amount;

        // Transfer lending tokens back to the supplier
        lendingToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }
}
