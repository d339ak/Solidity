// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.26;
// Deployed on Testnet Sepolia: 0x372455772F40558D59FB87330F75E30DA0E23EfA

contract EventEmitter {  

    // Emits a log with the address of the sender of the transaction that calls emitCountLog
    event WantsToCount(address indexed msgSender);

    constructor() {}

    function emitCountLog() public {  
        emit WantsToCount(msg.sender);  
    }  
}
