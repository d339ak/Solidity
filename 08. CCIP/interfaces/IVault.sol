// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IVault {
    function deposit(address account, uint256 amount) external;
    function withdraw(uint256 amount)  external;
}
