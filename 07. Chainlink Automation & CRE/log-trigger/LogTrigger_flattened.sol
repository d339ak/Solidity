
// File: @chainlink/contracts@1.3.0/src/v0.8/automation/interfaces/ILogAutomation.sol

pragma solidity ^0.8.0;

/**
 * @member index the index of the log in the block. 0 for the first log
 * @member timestamp the timestamp of the block containing the log
 * @member txHash the hash of the transaction containing the log
 * @member blockNumber the number of the block containing the log
 * @member blockHash the hash of the block containing the log
 * @member source the address of the contract that emitted the log
 * @member topics the indexed topics of the log
 * @member data the data of the log
 */
struct Log {
  uint256 index;
  uint256 timestamp;
  bytes32 txHash;
  uint256 blockNumber;
  bytes32 blockHash;
  address source;
  bytes32[] topics;
  bytes data;
}

interface ILogAutomation {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param log the raw log data matching the filter that this contract has
   * registered as a trigger
   * @param checkData user-specified extra data to provide context to this upkeep
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkLog(
    Log calldata log,
    bytes memory checkData
  ) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}



// File: contracts/log-trigger/LogTrigger.sol

pragma solidity ^0.8.26;
// Deployed on Testnet Sepolia: 0xE6195482385028309E83b23982d65f13830b9F8c

contract LogTrigger is ILogAutomation {  

    event CountedBy(address indexed msgSender);

    uint256 public counted;

    constructor() {}

    function checkLog(Log calldata log, bytes memory) external pure returns (bool upkeepNeeded, bytes memory performData) {  
        upkeepNeeded = true;  
        address logSender = bytes32ToAddress(log.topics[1]);  
        
        // abi.encode(...) takes values, as many as you like.
        performData = abi.encode(logSender);  
    }

    function performUpkeep(bytes calldata performData) external override {  
        counted += 1;

        // abi.decode(data, (types)) always takes 2 things: the bytes to decode, and a list of types that says how to read those bytes.
        // So the (address) in decode isn’t a second value. It’s an instruction: “read these bytes as one address.”
        address logSender = abi.decode(performData, (address));  
        emit CountedBy(logSender);  
    }

    function bytes32ToAddress(bytes32 _address) public pure returns (address) {  
        return address(uint160(uint256(_address)));  
    }  
}
