// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IRouterClient} from "@chainlink/contracts@1.3.0/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts@1.3.0/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts@1.3.0/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@chainlink/contracts@1.3.0/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts@5.2.0/access/Ownable.sol";


// Token Approvals: Before users can call transferTokens(address _receiver, uint256 _amount), they must approve CCIPTokenSender to spend their USDC tokens.
// Contract Funding: CCIPTokenSender must be funded with LINK tokens to pay the CCIP fees.
// Chain Selectors: The destination chain selector is a unique identifier for Base Sepolia. Different destinations require different selectors
// Fee Management: CCIP fees are paid in LINK tokens (or native tokens) and vary based on the destination chain and current network conditions

contract CCIPTokenSender is Ownable {

    using SafeERC20 for IERC20;

    error CCIPTokenSender__InsufficientBalance(IERC20 token, uint256 currentBalance, uint256 requiredAmount);
    error CCIPTokenSender__NothingToWithdraw();

    // https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#ethereum-testnet-sepolia
    // Ethernet testnet sepolia (Router) = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59
    IRouterClient private constant CCIP_ROUTER = IRouterClient(0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59);
    
    // https://docs.chain.link/resources/link-token-contracts#ethereum-testnet-sepolia
    // Ethereum testnet sepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789, Base testnet sepolia = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410
    IERC20 private constant LINK_TOKEN = IERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    // https://developers.circle.com/stablecoins/docs/usdc-on-test-networks
    // Ethereum testnet sepolia = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238, Base testnet sepolia = 0x036CbD53842c5426634e7929541eC2318f3dCF7e
    IERC20 private constant USDC_TOKEN = IERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238);

    // https://docs.chain.link/ccip/directory/testnet/chain/ethereum-testnet-sepolia-base-1
    // Ethereum testnet sepolia (chain selector) = 16015286601757825753
    // Base testnet sepolia (chain selector) = 10344971235874465080
    uint64 private constant DESTINATION_CHAIN_SELECTOR = 10344971235874465080;

    event USDCTransferred(bytes32 messageId, uint64 indexed destinationChainSelector, address indexed receiver, uint256 amount, uint256 ccipFee);

    constructor() Ownable(msg.sender) {
    }

    function transferTokens(address _receiver, uint256 _amount) external returns (bytes32 messageId) {

        if (_amount > USDC_TOKEN.balanceOf(msg.sender)) {
            revert CCIPTokenSender__InsufficientBalance(USDC_TOKEN, USDC_TOKEN.balanceOf(msg.sender), _amount);
        }

        // We first create an empty Client.EVMTokenAmount array with a single element.
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);

        // Then, we create a Client.EVMTokenAmount variable and pass the USDC token address and the amount to send. 
        // This tells Chainlink what token and how much is being sent cross-chain.
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
                                                        token: address(USDC_TOKEN),
                                                        amount: _amount
                                                    });

        // Finally, we initialize the first element with the Client.EVMTokenAmount variable.
        tokenAmounts[0] = tokenAmount;

        // Building the CCIP message create a message Client.EVM2AnyMessage struct with the relevant values
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
                                                    receiver: abi.encode(_receiver),                    // abi.encode(receiver address) for dest EVM chains
                                                    data: "",                                           // Data that is being sent cross-chain with the tokens. 
                                                    tokenAmounts: tokenAmounts,                         // Token transfers
                                                    extraArgs: Client._argsToBytes(                     // Populate this with _argsToBytes(EVMExtraArgsV2)
                                                                Client.EVMExtraArgsV1({gasLimit: 0})    // Setting gasLimit to 0 
                                                    ),
                                                    feeToken: address(LINK_TOKEN)                       // Address of feeToken. address(0) means you will send msg.value.
                                                });
        // In the above setting gasLimit to 0 because,
        //      1 This is a token-only transfer to an EOA (external owned account) 
        //      2 No contract execution is happening on the receiving end 
        //      3 gasLimit is only needed when the receiver is a contract that needs to execute code upon receiving the message


        // Handling fees: Get the fees for the message via the Router contract, 
        uint256 ccipFee = CCIP_ROUTER.getFee(DESTINATION_CHAIN_SELECTOR, message);

        // check if the contract has a sufficient LINK balance to pay the fees, 
        if (ccipFee > LINK_TOKEN.balanceOf(address(this))) {
            revert CCIPTokenSender__InsufficientBalance(LINK_TOKEN, LINK_TOKEN.balanceOf(address(this)), ccipFee);
        }

        // and approve the Router to spend some of the CCIPTokenSender's LINK as fees
        LINK_TOKEN.approve(address(CCIP_ROUTER), ccipFee);

        // Transferring and approving USDC: Send the _amount to bridge to the CCIPTokenSender contract 
        USDC_TOKEN.safeTransferFrom(msg.sender, address(this), _amount);

        // and approve the Router to be able to spend _amount of USDC from the CCIPTokenSender contract
        USDC_TOKEN.approve(address(CCIP_ROUTER), _amount);

        // Sending the CCIP message: Finally, send the cross-chain message by calling the ccipSend function on the Router contract 
        // Send CCIP Message
        messageId = CCIP_ROUTER.ccipSend(DESTINATION_CHAIN_SELECTOR, message);

        // and emit an event
        emit USDCTransferred(messageId, DESTINATION_CHAIN_SELECTOR, _receiver, _amount, ccipFee);
    }

    // Finally, the function withdrawToken allows the owner to be able to withdraw any USDC sent to the contract to a specified address _beneficiary
    function withdrawToken(address _beneficiary) public onlyOwner {

        uint256 amount = IERC20(USDC_TOKEN).balanceOf(address(this));

        if (amount == 0) 
            revert CCIPTokenSender__NothingToWithdraw();

        IERC20(USDC_TOKEN).transfer(_beneficiary, amount);
    }
}
