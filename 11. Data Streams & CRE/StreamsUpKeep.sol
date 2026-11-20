// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; // currently, it is required you use a compiler version of 0.8.19

// Deployed on Sepolia: 0x27ee620a490DE9f88b5d775cb5eAEf818fcE04Cf

// Common: Utilities for working with Chainlink Low Latency Oracle (LLO) feeds
import {Common} from "@chainlink/contracts@1.3.0/src/v0.8/llo-feeds/libraries/Common.sol";
// StreamsLookupCompatibleInterface: Interface for contracts that work with Streams Lookup
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts@1.3.0/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
// ILogAutomation: Interface for log-triggered automation
import {ILogAutomation, Log} from "@chainlink/contracts@1.3.0/src/v0.8/automation/interfaces/ILogAutomation.sol";
// IRewardManager: Interface for managing rewards in the Chainlink ecosystem
import {IRewardManager} from "@chainlink/contracts@1.3.0/src/v0.8/llo-feeds/v0.3.0/interfaces/IRewardManager.sol";
// IERC20: Standard ERC20 interface for token interactions
import {IERC20} from "@chainlink/contracts@1.3.0/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/interfaces/IERC20.sol";

import {IFeeManager} from "./interfaces/IFeeManager.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";


// Inherits from two interfaces to be enabled for Chainlink Automation and Data Streams
contract StreamsUpkeep is ILogAutomation, StreamsLookupCompatibleInterface {

    error InvalidReportVersion(uint16 version); // Thrown when an unsupported report version is provided to verifyReport.

    /**
     * @dev Represents a data report from a Data Streams stream for v3 schema (crypto streams).
     * The `price`, `bid`, and `ask` values are carried to either 8 or 18 decimal places, depending on the stream.
     * For more information, see https://docs.chain.link/data-streams/crypto-streams and https://docs.chain.link/data-streams/reference/report-schema
     */
    struct ReportV3 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain’s native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 price; // DON consensus median price (8 or 18 decimals).
        int192 bid; // Simulated price impact of a buy order up to the X% depth of liquidity utilisation (8 or 18 decimals).
        int192 ask; // Simulated price impact of a sell order up to the X% depth of liquidity utilisation (8 or 18 decimals).
    }

    /**
     * @dev Represents a data report from a Data Streams stream for v4 schema (RWA streams).
     * The `price` value is carried to either 8 or 18 decimal places, depending on the stream.
     * The `marketStatus` indicates whether the market is currently open. Possible values: `0` (`Unknown`), `1` (`Closed`), `2` (`Open`).
     * For more information, see https://docs.chain.link/data-streams/rwa-streams and https://docs.chain.link/data-streams/reference/report-schema-v4
     */
    struct ReportV4 {
        bytes32 feedId; // The stream ID the report has data for.
        uint32 validFromTimestamp; // Earliest timestamp for which price is applicable.
        uint32 observationsTimestamp; // Latest timestamp for which price is applicable.
        uint192 nativeFee; // Base cost to validate a transaction using the report, denominated in the chain’s native token (e.g., WETH/ETH).
        uint192 linkFee; // Base cost to validate a transaction using the report, denominated in LINK.
        uint32 expiresAt; // Latest timestamp where the report can be verified onchain.
        int192 price; // DON consensus median benchmark price (8 or 18 decimals).
        uint32 marketStatus; // The DON's consensus on whether the market is currently open.
    }

    // simple structure to hold token addresses for fee quotes
    struct Quote {
        address quoteAddress;
    }

    // VERIFIER: the address of the Chainlink verifier(there is one verifier contract deployed on all available chains) on the specific chain you are working on.
    // https://docs.chain.link/data-streams/supported-networks
    IVerifierProxy public VERIFIER = IVerifierProxy(0x4e9935be37302B9C97Ff4ae6868F1b566ade26d2);

    string public constant DATASTREAMS_FEEDLABEL = "feedIDs";
    string public constant DATASTREAMS_QUERYLABEL = "timestamp";
    int192 public lastDecodedPrice;

    // This example reads the ID for the ETH/USD report.
    // Find a complete list of IDs at https://docs.chain.link/data-streams/crypto-streams.
    string[] public feedIds = [
        "0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782"
    ];

    // SIMULATION OFFCHAIN FUNCTION. This will get called, if the report is fetched then checkcallback is called else checkerrorhandler.
    // When Automation detects the event has been emitted, it runs the checkLog function implemented here. checkLog and will return a StreamsLookup custom error.
    // The checkLog function is the function called by Automation when it detects the event emission. 
    // The code example uses revert with the StreamsLookup custom error to convey all the information about what stream(s) to retrieve. 
    // This use of revert is part of the EIP-3668 specification, which proposes that contracts revert with specific data to indicate that off-chain data is needed. 
    // The revert message contains information needed for off-chain lookups. It intentionally reverts with a special error.
    // Chainlink nodes catch this revert and use it to fetch data from Data Streams. More information on EIP-3668.
    // This function uses revert to convey call information.
    // See https://eips.ethereum.org/EIPS/eip-3668#rationale for details.
    function checkLog(Log calldata log, bytes memory) external view returns (bool upkeepNeeded, bytes memory performData) {
            revert StreamsLookup(
                DATASTREAMS_FEEDLABEL,  // Specify the feed identifiers that will be provided
                feedIds,                // String list of feed identifiers
                DATASTREAMS_QUERYLABEL, // Specify query type
                log.timestamp,          // Specify query value
                ""                      // Any extra data user wants to receive in callback, alongside API bytes[]
            );
    }

    // SIMULATION OFFCHAIN FUNCTION.
    /**
     * @notice this is a new, optional function in streams lookup. It is meant to surface streams lookup errors.
     * @return upkeepNeeded boolean to indicate whether the keeper should call performUpkeep or not.
     * @return performData bytes that the keeper should call performUpkeep with, if
     * upkeep is needed. If you would like to encode data to decode later, try `abi.encode`.
     */
    function checkErrorHandler(uint256 /*errCode*/, bytes memory /*extraData*/) external pure returns (bool upkeepNeeded, bytes memory performData) {
        return (true, "0");
        // Hardcoded to always perform upkeep. Only for this learning. In real return false.
        // Read the StreamsLookup error handler guide for more information.
        // https://docs.chain.link/chainlink-automation/guides/streams-lookup-error-handler
    }

    // SIMULATION OFFCHAIN FUNCTION. Returns upkeepneeded true or false, and performdata is sent to perforupkeep.
    // The following function is a callback function (which is simulated off-chain, hence why it is pure), so it can be modified to further process the report data. 
    // The report and data are then passed into performUpkeep by Automation.
    // The Data Streams report bytes is passed here.
    // extraData is context data from stream lookup process.
    // Your contract may include logic to further process this data.
    // This method is intended only to be simulated offchain by Automation.
    // The data returned will then be passed by Automation into performUpkeep
    function checkCallback(bytes[] calldata values, bytes calldata extraData ) external pure returns (bool, bytes memory) {
        return (true, abi.encode(values, extraData));
    }

    // function will be performed onchain.
    // performUpkeep is the function that is executed on-chain by Automation. It contains the logic to process the data and record it on-chain
    function performUpkeep(bytes calldata performData) external {
        // Decode the performData bytes passed in by CL Automation.
        // This contains the data returned by your implementation in checkCallback().
        (bytes[] memory signedReports, ) = abi.decode(performData, (bytes[], bytes));

        bytes memory unverifiedReport = signedReports[0];

        (, /* bytes32[3] reportContextData */ bytes memory reportData) = abi.decode(unverifiedReport, (bytes32[3], bytes));

        // Extract report version from reportData
        uint16 reportVersion = (uint16(uint8(reportData[0])) << 8) |  uint16(uint8(reportData[1]));

        // Validate report version
        if (reportVersion != 3 && reportVersion != 4) {
            revert InvalidReportVersion(uint8(reportVersion));
        }

        // Report verification fees
        IFeeManager feeManager = IFeeManager(address(VERIFIER.s_feeManager()));
        IRewardManager rewardManager = IRewardManager(address(feeManager.i_rewardManager()));

        address feeTokenAddress = feeManager.i_linkAddress();

        (Common.Asset memory fee, , ) = feeManager.getFeeAndReward(address(this), reportData, feeTokenAddress);

        // Approve rewardManager to spend this contract's balance in fees
        IERC20(feeTokenAddress).approve(address(rewardManager), fee.amount);

        // REAL WORK.
        // Verify the report here. 
        bytes memory verifiedReportData = VERIFIER.verify(unverifiedReport, abi.encode(feeTokenAddress));

        // Decode verified report data into the appropriate Report struct based on reportVersion
        if (reportVersion == 3) {
            // v3 report schema
            ReportV3 memory verifiedReport = abi.decode(verifiedReportData, (ReportV3));

            // Store the price from the report
            lastDecodedPrice = verifiedReport.price;

        } else if (reportVersion == 4) {
            // v4 report schema
            ReportV4 memory verifiedReport = abi.decode(verifiedReportData, (ReportV4));

            // Store the price from the report
            lastDecodedPrice = verifiedReport.price;
        }
    }
}
