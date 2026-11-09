// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.7.0
pragma solidity ^0.8.27;
// MyERC20 ("My ERC-20 Token"/DPS) deployed at address 0x03cFfeb364538d3800ce52F867F004D28D28F7cF on Sepolia Ethereum Testnet.


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract MyERC20 is ERC20, ERC20Capped, Ownable, AccessControl {

    // If inheriting from AccessControl smart contract from OpenZepplin, to implement a Minter role.
    // 1. Inherit the AccessControl contract above in your contract declaration.
    // 2. Create a bytes32 constant state variable containing the hashed name of the the-role role identifier.
    //      E.G: bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // 3. Now, we can add the "onlyRole()" modifier from the AccessControl contract to our mint function 
    //      to add a check that the msg.sender has the role that we pass to the modifier. eg: onlyRole(MINTER_ROLE)
    //      E.G function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) { ... function body ... }
    // 4. However, we do not yet have a way to give addresses this MINTER_ROLE. 
    //      To do this we need another role that can grant roles to other addresses. 
    //      OpenZeppelin's AccessControl contract has a role that does this already, called the DEFAULT_ADMIN_ROLE.
    // 5. Let's grant this role to the deployer/owner in the constructor. 
    //      Grant the owner DEFAULT_ADMIN_ROLE and while we are at it, also the MINTER_ROLE (if so needed). 
    //      We can do this by calling the _grantRole function, which takes the role and the address to grant the role to.
    //      E.G _grantRole(MINTER_ROLE, msg.sender);   
    

    // Declaring the constructor for MyERC20 contract with 1 parameter. Then calling the constructor of each parent.
    constructor(address initialOwner, uint256 maxTokenCap) ERC20("My ERC-20 Token", "DPS") ERC20Capped(maxTokenCap) Ownable(initialOwner) {
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Capped) {
        super._update(from, to, value);
    }
}
