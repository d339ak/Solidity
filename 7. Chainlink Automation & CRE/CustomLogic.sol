// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.26;
// Deployed on Testnet Sepolia: 0xc199BF1Eb796a7A291722f5E25454805Ea022850

import { AutomationCompatibleInterface } from "@chainlink/contracts@1.3.0/src/v0.8/automation/AutomationCompatible.sol";

contract CustomLogic is AutomationCompatibleInterface {

    uint256 public counter;  
    uint256 public immutable i_updateInterval;  
    uint256 public lastTimeStamp;

    constructor(uint256 _updateInterval) {  
        i_updateInterval = _updateInterval;  
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {  
        upkeepNeeded = (block.timestamp - lastTimeStamp) > i_updateInterval;  
        performData = "";
    }

    function performUpkeep(bytes calldata) external override {  
        if ((block.timestamp - lastTimeStamp) > i_updateInterval) {  
            lastTimeStamp = block.timestamp;  
            counter = counter + 1;  
        }  
    }  
}
