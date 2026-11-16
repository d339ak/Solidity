// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// solhint-disable no-unused-import
import {CCIPLocalSimulator} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";


// configuration - got this from compiling this contract. Most probably will be different each time.
// 0: uint64: chainSelector_ 16015286601757825753
// 1: address: sourceRouter_ 0x4e2d190457f1fAA2BC7C8aabFb9b829Da008d18A
// 2: address: destinationRouter_ 0x4e2d190457f1fAA2BC7C8aabFb9b829Da008d18A
// 3: address: wrappedNative_ 0x5C9eb5D6a6C2c1B3EFc52255C0b356f116f6f66D
// 4: address: linkToken_ 0xb8f43EC36718ecCb339B75B727736ba14F174d77
// 5: address: ccipBnM_ 0x73d5596F97950f1048b251E3e3Ee5ab888d76d37
// 6: address: ccipLnM_ 0x3A09bB767270BADdFe534CD3cF830c14c65adA73
