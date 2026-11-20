// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FallbackExample {
    uint256 public result;

    receive() external payable {
        //result = msg.value; // Store the amount sent to the contract
        result = 1;
    }

    fallback() external payable {
        result  = 2;
    }
}


// Is msg.data empty?
// ├─ No  → Does fallback() exist?
// │        ├─ Yes → Call fallback()
// │        └─ No  → Revert
// └─ Yes → Does receive() exist?
//          ├─ Yes → Call receive()
//          └─ No  → Does fallback() exist?
//                   ├─ Yes → Call fallback()
//                   └─ No  → Revert
