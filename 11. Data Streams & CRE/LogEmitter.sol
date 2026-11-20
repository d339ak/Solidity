// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Deployed on Sepolia: 0x20DE5711D3B091DA7CC08906b8Aaa45E69f1bb06

contract LogEmitter {
    event Log(address indexed msgSender);

    function emitLog() public {
        emit Log(msg.sender);
    }
}
