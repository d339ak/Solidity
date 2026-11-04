// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConvertor} from "PriceConvertor.sol";

// 810,122
// after constant keyword usage the new gas is 790,164
contract FundMe {
    using PriceConvertor for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    // 307 gas - constant
    // 2451 gas - not constant * 41000000 = 100,491,000,000 wei

    address[] public funders;

    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;
    // 444 = immutable
    // 2,580 = non immutable 

    constructor () {
        i_owner = msg.sender;
    }

    function fund() public payable {
        //Allow users to send $
        //Have a minimum $ sent of $5
        require (msg.value.getConversionRate() >= MINIMUM_USD, "didnt send enough ether.");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);

        // actually withdraw the funds
        // transfer, send and call. 3 ways to do it.
        // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
         // call, is the recommended way.
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        require (msg.sender == i_owner, "Sender is not owner!");
        _;
    }
}
