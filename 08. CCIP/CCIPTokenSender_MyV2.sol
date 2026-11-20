// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Deployed on Sepolia testnet: 0xbE68Ab850a648dA617742DdCa7b707570c8cc8A9

//// To Transfer CCIP-BnM cross-chain to Base Sepolia TxId: 0x883d861f9f50865c59f2f4373340bc3bbd27b9f35b04b86bd464ae65965550d0
// _token:                    0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05
// _destinationChainSelector: 10344971235874465080
// _receiver:                 my wallet address
// _amount:                   1000000000000000000
// _gasLimit:                 0
// _allowOutOfOrderExecution: true

//// To Transfer CCIP-BnM cross chain to zkSync Sepolia TxId: 0x5b063d7903729f41737bc1bf8b5339341e0afa57474896e4e424c56599c7b33f
// _token:                    0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05
// _destinationChainSelector: 6898391096552792247
// _receiver:                 my wallet address
// _amount:                   1000000000000000000
// _gasLimit:                 2000000
// _allowOutOfOrderExecution: true

// Token Approvals:     Before users can call transferTokens(), 
//                      they must approve CCIPTokenSender to spend their whichever transfer tokens.
// Contract Funding:    CCIPTokenSender must be funded with LINK tokens to pay the CCIP fees.
// Chain Selectors:     The destination chain selector is a unique identifier for ZKsync Sepolia. 
//                      Different destinations require different selectors
// Fee Management:      CCIP fees are paid in LINK tokens (or native tokens) and vary based on the destination chain 
//                      and current network conditions


import {IRouterClient} from "@chainlink/contracts@1.3.0/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts@1.3.0/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts@1.3.0/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@chainlink/contracts@1.3.0/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts@5.2.0/access/Ownable.sol";

contract CCIPTokenSender_MyV2 is Ownable {

    using SafeERC20 for IERC20;

    error CCIPTokenSender__InsufficientBalance(IERC20 token, uint256 currentBalance, uint256 requiredAmount);
    error CCIPTokenSender__NothingToWithdraw();
    error CCIPTokenSender__ChainNotSupported(uint64 destinationChainSelector);
    error CCIPTokenSender__InvalidReceiver();
    error CCIPTokenSender__InvalidAmount();

    // Ethereum Sepolia router and LINK
    IRouterClient private constant CCIP_ROUTER = IRouterClient(0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59);
    IERC20 private constant LINK_TOKEN = IERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    event TokensTransferred(bytes32 indexed messageId, uint64 indexed destinationChainSelector, 
                            address indexed receiver, address token, uint256 amount, uint256 gasLimit, uint256 ccipFee);

    constructor() Ownable(msg.sender) {}

    function transferTokens(address _token, uint64 _destinationChainSelector, address _receiver, uint256 _amount, uint256 _gasLimit, bool _allowOutOfOrderExecution) 
        external returns (bytes32 messageId) {

        if (_receiver == address(0)) revert CCIPTokenSender__InvalidReceiver();

        if (_amount == 0) revert CCIPTokenSender__InvalidAmount();

        if (!CCIP_ROUTER.isChainSupported(_destinationChainSelector)) {
            revert CCIPTokenSender__ChainNotSupported(_destinationChainSelector);
        }

        IERC20 token = IERC20(_token);

        uint256 userBalance = token.balanceOf(msg.sender);

        if (_amount > userBalance) {
            revert CCIPTokenSender__InsufficientBalance(token, userBalance, _amount);
        }

        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({token: _token, amount: _amount});

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
                                                    receiver: abi.encode(_receiver),
                                                    data: "",
                                                    tokenAmounts: tokenAmounts,
                                                    extraArgs: Client._argsToBytes(
                                                        Client.EVMExtraArgsV2({
                                                            gasLimit: _gasLimit,
                                                            allowOutOfOrderExecution: _allowOutOfOrderExecution
                                                        })
                                                    ),
                                                    feeToken: address(LINK_TOKEN)
        });

        uint256 ccipFee = CCIP_ROUTER.getFee(_destinationChainSelector, message);

        uint256 linkBalance = LINK_TOKEN.balanceOf(address(this));

        if (ccipFee > linkBalance) {
            revert CCIPTokenSender__InsufficientBalance(LINK_TOKEN, linkBalance, ccipFee);
        }

        LINK_TOKEN.safeIncreaseAllowance(address(CCIP_ROUTER), ccipFee);

        token.safeTransferFrom(msg.sender, address(this), _amount);

        token.safeIncreaseAllowance(address(CCIP_ROUTER), _amount);

        messageId = CCIP_ROUTER.ccipSend(_destinationChainSelector, message);

        emit TokensTransferred(messageId, _destinationChainSelector, _receiver, _token, _amount, _gasLimit, ccipFee);
    }

    // Withdraw any token (BnM, USDC, LINK) stuck in the contract
    function withdrawToken(address _token, address _beneficiary) external onlyOwner {

        // if (_beneficiary == address(0)) revert CCIPTokenSender__ZeroAddress();

        IERC20 token = IERC20(_token);

        uint256 amount = token.balanceOf(address(this));

        if (amount == 0) revert CCIPTokenSender__NothingToWithdraw();
        
        token.safeTransfer(_beneficiary, amount);
    }
}
