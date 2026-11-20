
// File: @chainlink/local/src/shared/WETH9.sol

// Submitted for verification at Etherscan.io on 2017-12-12

// Copyright (C) 2015, 2016, 2017 Dapphub

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
pragma solidity ^0.8.19;

contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    receive() external payable {
        _deposit();
    }

    function _deposit() internal {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function deposit() external payable {
        _deposit();
    }

    function withdraw(uint256 wad) external {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint128).max) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/IERC677Receiver.sol


pragma solidity ^0.8.6;

interface IERC677Receiver {
  function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external;
}

// File: @chainlink/contracts/src/v0.8/shared/token/ERC677/IERC677.sol


pragma solidity ^0.8.0;

interface IERC677 {
  event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

  /// @notice Transfer tokens from `msg.sender` to another address and then call `onTransferReceived` on receiver
  /// @param to The address which you want to transfer to
  /// @param amount The amount of tokens to be transferred
  /// @param data bytes Additional data with no specified format, sent in call to `to`
  /// @return true unless throwing
  function transferAndCall(address to, uint256 amount, bytes memory data) external returns (bool);
}

// File: @openzeppelin/contracts@4.8.3/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts@4.8.3/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts@4.8.3/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts@4.8.3/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @chainlink/contracts/src/v0.8/shared/token/ERC677/ERC677.sol


pragma solidity ^0.8.0;




contract ERC677 is IERC677, ERC20 {
  constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

  /// @inheritdoc IERC677
  function transferAndCall(address to, uint256 amount, bytes memory data) public returns (bool success) {
    super.transfer(to, amount);
    emit Transfer(msg.sender, to, amount, data);
    if (to.code.length > 0) {
      IERC677Receiver(to).onTokenTransfer(msg.sender, amount, data);
    }
    return true;
  }
}

// File: @chainlink/local/src/shared/LinkToken.sol


pragma solidity ^0.8.19;


/// @title LinkToken
/// @notice This contract implements the ChainLink Token (LINK) using the ERC677 standard.
/// @dev Inherits from the ERC677 token contract and initializes with a fixed total supply and standard token details.
contract LinkToken is ERC677 {
    /// @notice The total supply of LINK tokens.
    uint256 private constant TOTAL_SUPPLY = 10 ** 27;

    /// @notice The name of the LINK token.
    string private constant NAME = "ChainLink Token";

    /// @notice The symbol of the LINK token.
    string private constant SYMBOL = "LINK";

    /**
     * @notice Constructor to initialize the LinkToken contract with a fixed total supply, name, and symbol.
     * @dev Calls the ERC677 constructor with the name and symbol, and then mints the total supply to the contract deployer.
     */
    constructor() ERC677(NAME, SYMBOL) {
        _onCreate();
    }

    /**
     * @notice Hook that is called when this contract is created.
     * @dev Useful to override constructor behaviour in child contracts (e.g., LINK bridge tokens).
     *      The default implementation mints 10**27 tokens to the contract deployer.
     */
    function _onCreate() internal virtual {
        _mint(msg.sender, TOTAL_SUPPLY);
    }
}

// File: @chainlink/contracts/src/v0.8/shared/token/ERC20/IBurnMintERC20.sol


pragma solidity ^0.8.0;


interface IBurnMintERC20 is IERC20 {
  /// @notice Mints new tokens for a given address.
  /// @param account The address to mint the new tokens to.
  /// @param amount The number of tokens to be minted.
  /// @dev this function increases the total supply.
  function mint(address account, uint256 amount) external;

  /// @notice Burns tokens from the sender.
  /// @param amount The number of tokens to be burned.
  /// @dev this function decreases the total supply.
  function burn(
    uint256 amount
  ) external;

  /// @notice Burns tokens from a given address..
  /// @param account The address to burn tokens from.
  /// @param amount The number of tokens to be burned.
  /// @dev this function decreases the total supply.
  function burn(address account, uint256 amount) external;

  /// @notice Burns tokens from a given address..
  /// @param account The address to burn tokens from.
  /// @param amount The number of tokens to be burned.
  /// @dev this function decreases the total supply.
  function burnFrom(address account, uint256 amount) external;
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/IOwnable.sol


pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(
    address recipient
  ) external;

  function acceptOwnership() external;
}

// File: @chainlink/contracts/src/v0.8/shared/access/ConfirmedOwnerWithProposal.sol


pragma solidity ^0.8.0;


/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line gas-custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Allows an owner to begin transferring ownership to a new address.
  function transferOwnership(
    address to
  ) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice validate, transfer ownership, and emit relevant events
  function _transferOwnership(
    address to
  ) private {
    // solhint-disable-next-line gas-custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol


pragma solidity ^0.8.0;


/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(
    address newOwner
  ) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// File: @chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol


pragma solidity ^0.8.0;


/// @title The OwnerIsCreator contract
/// @notice A contract with helpers for basic contract ownership.
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}

// File: @openzeppelin/contracts@4.8.3/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: @openzeppelin/contracts@4.8.3/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts@4.8.3/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File: @chainlink/contracts/src/v0.8/shared/token/ERC677/BurnMintERC677.sol


pragma solidity ^0.8.4;









/// @notice A basic ERC677 compatible token contract with burn and minting roles.
/// @dev The total supply can be limited during deployment.
contract BurnMintERC677 is IBurnMintERC20, ERC677, IERC165, ERC20Burnable, OwnerIsCreator {
  using EnumerableSet for EnumerableSet.AddressSet;

  error SenderNotMinter(address sender);
  error SenderNotBurner(address sender);
  error MaxSupplyExceeded(uint256 supplyAfterMint);

  event MintAccessGranted(address indexed minter);
  event BurnAccessGranted(address indexed burner);
  event MintAccessRevoked(address indexed minter);
  event BurnAccessRevoked(address indexed burner);

  // @dev the allowed minter addresses
  EnumerableSet.AddressSet internal s_minters;
  // @dev the allowed burner addresses
  EnumerableSet.AddressSet internal s_burners;

  /// @dev The number of decimals for the token
  uint8 internal immutable i_decimals;

  /// @dev The maximum supply of the token, 0 if unlimited
  uint256 internal immutable i_maxSupply;

  constructor(string memory name, string memory symbol, uint8 decimals_, uint256 maxSupply_) ERC677(name, symbol) {
    i_decimals = decimals_;
    i_maxSupply = maxSupply_;
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public pure virtual override returns (bool) {
    return interfaceId == type(IERC20).interfaceId || interfaceId == type(IERC677).interfaceId
      || interfaceId == type(IBurnMintERC20).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  // ================================================================
  // |                            ERC20                             |
  // ================================================================

  /// @dev Returns the number of decimals used in its user representation.
  function decimals() public view virtual override returns (uint8) {
    return i_decimals;
  }

  /// @dev Returns the max supply of the token, 0 if unlimited.
  function maxSupply() public view virtual returns (uint256) {
    return i_maxSupply;
  }

  /// @dev Uses OZ ERC20 _transfer to disallow sending to address(0).
  /// @dev Disallows sending to address(this)
  function _transfer(address from, address to, uint256 amount) internal virtual override validAddress(to) {
    super._transfer(from, to, amount);
  }

  /// @dev Uses OZ ERC20 _approve to disallow approving for address(0).
  /// @dev Disallows approving for address(this)
  function _approve(address owner, address spender, uint256 amount) internal virtual override validAddress(spender) {
    super._approve(owner, spender, amount);
  }

  /// @dev Exists to be backwards compatible with the older naming convention.
  function decreaseApproval(address spender, uint256 subtractedValue) external virtual returns (bool success) {
    return decreaseAllowance(spender, subtractedValue);
  }

  /// @dev Exists to be backwards compatible with the older naming convention.
  function increaseApproval(address spender, uint256 addedValue) external virtual {
    increaseAllowance(spender, addedValue);
  }

  /// @notice Check if recipient is valid (not this contract address).
  /// @param recipient the account we transfer/approve to.
  /// @dev Reverts with an empty revert to be compatible with the existing link token when
  /// the recipient is this contract address.
  modifier validAddress(
    address recipient
  ) virtual {
    // solhint-disable-next-line reason-string, gas-custom-errors
    if (recipient == address(this)) revert();
    _;
  }

  // ================================================================
  // |                      Burning & minting                       |
  // ================================================================

  /// @inheritdoc ERC20Burnable
  /// @dev Uses OZ ERC20 _burn to disallow burning from address(0).
  /// @dev Decreases the total supply.
  function burn(
    uint256 amount
  ) public virtual override(IBurnMintERC20, ERC20Burnable) onlyBurner {
    super.burn(amount);
  }

  /// @inheritdoc IBurnMintERC20
  /// @dev Alias for BurnFrom for compatibility with the older naming convention.
  /// @dev Uses burnFrom for all validation & logic.
  function burn(address account, uint256 amount) public virtual override {
    burnFrom(account, amount);
  }

  /// @inheritdoc ERC20Burnable
  /// @dev Uses OZ ERC20 _burn to disallow burning from address(0).
  /// @dev Decreases the total supply.
  function burnFrom(address account, uint256 amount) public virtual override(IBurnMintERC20, ERC20Burnable) onlyBurner {
    super.burnFrom(account, amount);
  }

  /// @inheritdoc IBurnMintERC20
  /// @dev Uses OZ ERC20 _mint to disallow minting to address(0).
  /// @dev Disallows minting to address(this)
  /// @dev Increases the total supply.
  function mint(address account, uint256 amount) external virtual override onlyMinter validAddress(account) {
    if (i_maxSupply != 0 && totalSupply() + amount > i_maxSupply) revert MaxSupplyExceeded(totalSupply() + amount);

    _mint(account, amount);
  }

  // ================================================================
  // |                            Roles                             |
  // ================================================================

  /// @notice grants both mint and burn roles to `burnAndMinter`.
  /// @dev calls public functions so this function does not require
  /// access controls. This is handled in the inner functions.
  function grantMintAndBurnRoles(
    address burnAndMinter
  ) external virtual {
    grantMintRole(burnAndMinter);
    grantBurnRole(burnAndMinter);
  }

  /// @notice Grants mint role to the given address.
  /// @dev only the owner can call this function.
  function grantMintRole(
    address minter
  ) public virtual onlyOwner {
    if (s_minters.add(minter)) {
      emit MintAccessGranted(minter);
    }
  }

  /// @notice Grants burn role to the given address.
  /// @dev only the owner can call this function.
  function grantBurnRole(
    address burner
  ) public virtual onlyOwner {
    if (s_burners.add(burner)) {
      emit BurnAccessGranted(burner);
    }
  }

  /// @notice Revokes mint role for the given address.
  /// @dev only the owner can call this function.
  function revokeMintRole(
    address minter
  ) public virtual onlyOwner {
    if (s_minters.remove(minter)) {
      emit MintAccessRevoked(minter);
    }
  }

  /// @notice Revokes burn role from the given address.
  /// @dev only the owner can call this function
  function revokeBurnRole(
    address burner
  ) public virtual onlyOwner {
    if (s_burners.remove(burner)) {
      emit BurnAccessRevoked(burner);
    }
  }

  /// @notice Returns all permissioned minters
  function getMinters() public view virtual returns (address[] memory) {
    return s_minters.values();
  }

  /// @notice Returns all permissioned burners
  function getBurners() public view virtual returns (address[] memory) {
    return s_burners.values();
  }

  // ================================================================
  // |                            Access                            |
  // ================================================================

  /// @notice Checks whether a given address is a minter for this token.
  /// @return true if the address is allowed to mint.
  function isMinter(
    address minter
  ) public view virtual returns (bool) {
    return s_minters.contains(minter);
  }

  /// @notice Checks whether a given address is a burner for this token.
  /// @return true if the address is allowed to burn.
  function isBurner(
    address burner
  ) public view virtual returns (bool) {
    return s_burners.contains(burner);
  }

  /// @notice Checks whether the msg.sender is a permissioned minter for this token
  /// @dev Reverts with a SenderNotMinter if the check fails
  modifier onlyMinter() {
    if (!isMinter(msg.sender)) revert SenderNotMinter(msg.sender);
    _;
  }

  /// @notice Checks whether the msg.sender is a permissioned burner for this token
  /// @dev Reverts with a SenderNotBurner if the check fails
  modifier onlyBurner() {
    if (!isBurner(msg.sender)) revert SenderNotBurner(msg.sender);
    _;
  }
}

// File: @chainlink/local/src/ccip/BurnMintERC677Helper.sol


pragma solidity ^0.8.19;


/// @title BurnMintERC677Helper
/// @notice This contract extends the functionality of the BurnMintERC677 token contract to include a `drip` function that mints one full token to a specified address.
/// @dev Inherits from the BurnMintERC677 contract and sets the token name, symbol, decimals, and initial supply in the constructor.
contract BurnMintERC677Helper is BurnMintERC677 {
    /**
     * @notice Constructor to initialize the BurnMintERC677Helper contract with a name and symbol.
     * @dev Calls the parent constructor of BurnMintERC677 with fixed decimals (18) and initial supply (0).
     * @param name - The name of the token.
     * @param symbol - The symbol of the token.
     */
    constructor(string memory name, string memory symbol) BurnMintERC677(name, symbol, 18, 0) {}

    /**
     * @notice Mints one full token (1e18) to the specified address.
     * @dev Calls the internal `_mint` function from the BurnMintERC677 contract.
     * @param to - The address to receive the minted token.
     */
    function drip(address to) external {
        _mint(to, 1e18);
    }
}

// File: @chainlink/contracts-ccip/contracts/libraries/Client.sol


pragma solidity ^0.8.0;

// End consumer library.
library Client {
  struct EVMTokenAmount {
    address token; // token address on the local chain.
    uint256 amount; // Amount of tokens.
  }

  struct Any2EVMMessage {
    bytes32 messageId; // MessageId corresponding to ccipSend on source.
    uint64 sourceChainSelector; // Source chain selector.
    bytes sender; // abi.encode(address) on EVM source chains; abi.decode(sender, (address)) to recover.
    bytes data; // payload sent in original message.
    EVMTokenAmount[] destTokenAmounts; // Tokens and their amounts in their destination chain representation.
  }

  // If extraArgs is empty bytes, the default is 200k gas limit.
  struct EVM2AnyMessage {
    bytes receiver; // abi.encode(receiver address) for dest EVM chains.
    bytes data; // Data payload.
    EVMTokenAmount[] tokenAmounts; // Token transfers.
    address feeToken; // Address of feeToken. address(0) means you will send msg.value.
    bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV3).
  }

  /// @notice Tag to indicate no execution on the destination chain. Execution will need to be done manually.
  /// @dev Preimage for this tag is: keccak256("NO_EXECUTION_TAG")[:4]
  bytes4 public constant NO_EXECUTION_TAG = 0xeba517d2;
  address public constant NO_EXECUTION_ADDRESS = address(bytes20(NO_EXECUTION_TAG));

  // ================================================================
  // │                           Legacy                             │
  // ================================================================

  // Tag to indicate only a gas limit. Only usable for EVM as destination chain.
  bytes4 public constant EVM_EXTRA_ARGS_V1_TAG = 0x97a657c9;

  struct EVMExtraArgsV1 {
    uint256 gasLimit;
  }

  function _argsToBytes(
    EVMExtraArgsV1 memory extraArgs
  ) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EVM_EXTRA_ARGS_V1_TAG, extraArgs);
  }

  // Tag to indicate a gas limit (or dest chain equivalent processing units) and Out Of Order Execution. This tag is
  // available for multiple chain families. If there is no chain family specific tag, this is the default available
  // for a chain.
  // Note: not available for Solana or Sui VM based chains.
  bytes4 public constant GENERIC_EXTRA_ARGS_V2_TAG = 0x181dcf10;

  /// @param gasLimit: gas limit for the callback on the destination chain.
  /// @param allowOutOfOrderExecution: if true, it indicates that the message can be executed in any order relative to
  /// other messages from the same sender. This value's default varies by chain. On some chains, a particular value is
  /// enforced, meaning if the expected value is not set, the message request will revert.
  /// @dev Fully compatible with the previously existing EVMExtraArgsV2.
  struct GenericExtraArgsV2 {
    uint256 gasLimit;
    bool allowOutOfOrderExecution;
  }

  // Extra args tag for chains that use the Sui VM.
  bytes4 public constant SUI_EXTRA_ARGS_V1_TAG = 0x21ea4ca9;

  // Extra args tag for chains that use the Solana VM.
  bytes4 public constant SVM_EXTRA_ARGS_V1_TAG = 0x1f3b3aba;

  struct SVMExtraArgsV1 {
    uint32 computeUnits;
    uint64 accountIsWritableBitmap;
    bool allowOutOfOrderExecution;
    bytes32 tokenReceiver;
    // Additional accounts needed for execution of CCIP receiver. Must be empty if message.receiver is zero.
    // Token transfer related accounts are specified in the token pool lookup table on SVM.
    bytes32[] accounts;
  }

  /// @dev The maximum number of accounts that can be passed in SVMExtraArgs.
  uint256 public constant SVM_EXTRA_ARGS_MAX_ACCOUNTS = 64;

  /// @dev The expected static payload size of a token transfer when Borsh encoded and submitted to SVM.
  /// TokenPool extra data and offchain data sizes are dynamic, and should be accounted for separately.
  uint256 public constant SVM_TOKEN_TRANSFER_DATA_OVERHEAD = (4 + 32) // source_pool
    + 32 // token_address
    + 4 // gas_amount
    + 4 // extra_data overhead
    + 32 // amount
    + 32 // size of the token lookup table account
    + 32 // token-related accounts in the lookup table, over-estimated to 32, typically between 11 - 13
    + 32 // token account belonging to the token receiver, e.g ATA, not included in the token lookup table
    + 32 // per-chain token pool config, not included in the token lookup table
    + 32 // per-chain token billing config, not always included in the token lookup table
    + 32; // OffRamp pool signer PDA, not included in the token lookup table

  /// @dev Number of overhead accounts needed for message execution on SVM.
  /// @dev These are message.receiver, and the OffRamp Signer PDA specific to the receiver.
  uint256 public constant SVM_MESSAGING_ACCOUNTS_OVERHEAD = 2;

  /// @dev The size of each SVM account address in bytes.
  uint256 public constant SVM_ACCOUNT_BYTE_SIZE = 32;

  struct SuiExtraArgsV1 {
    uint256 gasLimit;
    bool allowOutOfOrderExecution;
    bytes32 tokenReceiver;
    bytes32[] receiverObjectIds;
  }

  /// @dev The expected static payload size of a token transfer when BCS encoded and submitted to SUI.
  /// TokenPool extra data and offchain data sizes are dynamic, and should be accounted for separately.
  uint256 public constant SUI_TOKEN_TRANSFER_DATA_OVERHEAD = (4 + 32) // source_pool, 4 bytes for length, 32 bytes for address
    + 32 // dest_token_address
    + 4 // dest_gas_amount
    + 4 // extra_data length, the contents are calculated separately
    + 32; // amount

  /// @dev Number of overhead accounts needed for message execution on SUI.
  /// @dev This is the message.receiver.
  uint256 public constant SUI_MESSAGING_ACCOUNTS_OVERHEAD = 1;

  /// @dev The maximum number of receiver object ids that can be passed in SuiExtraArgs.
  uint256 public constant SUI_EXTRA_ARGS_MAX_RECEIVER_OBJECT_IDS = 64;

  /// @dev The size of each SUI account address in bytes.
  uint256 public constant SUI_ACCOUNT_BYTE_SIZE = 32;

  function _argsToBytes(
    GenericExtraArgsV2 memory extraArgs
  ) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(GENERIC_EXTRA_ARGS_V2_TAG, extraArgs);
  }

  function _svmArgsToBytes(
    SVMExtraArgsV1 memory extraArgs
  ) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(SVM_EXTRA_ARGS_V1_TAG, extraArgs);
  }

  function _suiArgsToBytes(
    SuiExtraArgsV1 memory extraArgs
  ) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(SUI_EXTRA_ARGS_V1_TAG, extraArgs);
  }
}

// File: @chainlink/contracts-ccip/contracts/interfaces/IAny2EVMMessageReceiver.sol


pragma solidity ^0.8.0;


/// @notice Application contracts that intend to receive messages from  the router should implement this interface.
interface IAny2EVMMessageReceiver {
  /// @notice Called by the Router to deliver a message. If this reverts, any token transfers also revert.
  /// The message will move to a FAILED state and become available for manual execution.
  /// @param message CCIP Message.
  /// @dev Note ensure you check the msg.sender is the Router.
  function ccipReceive(
    Client.Any2EVMMessage calldata message
  ) external;
}

// File: @chainlink/contracts-ccip/contracts/interfaces/IAny2EVMMessageReceiverV2.sol


pragma solidity ^0.8.0;


interface IAny2EVMMessageReceiverV2 is IAny2EVMMessageReceiver {
  /// @notice Get the CCV configuration & allowed finality config for a source chain and sender.
  /// @dev Implementations must return an appropriate allowedFinalityConfig value. Returning
  /// FinalityCodec.WAIT_FOR_FINALITY_FLAG signals that only fully finalized messages are accepted. Returning a non-zero
  /// value allows faster-than-finality (FTF) messages whose requested finality is permitted by the
  /// allowedFinalityConfig (see `FinalityCodec._ensureRequestedFinalityAllowed`).
  /// When a trusted sender is used (and verified by the receiver), this is less critical as the trusted sender
  /// will only send messages with a certain level of finality. The simplest way to implement this is to either allow FTF
  /// messages when sender-verification is used, or require finality for all messages. That means the config can be a
  /// simple boolean instead of n^2 config where for each source, an allowed finality config must be chosen.
  ///
  /// A few methods to check the finality requirement are:
  /// - Only allow trusted senders, allow FTF broadly as the senders will decide on the final value
  /// - Return a single config for all chains
  /// - Return a config specific to the source chain (e.g. 10 blocks for chain A, 20 blocks for chain B)
  /// - Do not allow FTF messages at all, always return the WAIT_FOR_FINALITY_FLAG.
  ///
  /// @param sourceChainSelector The source chain selector of the incoming message. This can be used to specify
  /// different CCV requirements for different source chains, and provides context for the allowed finality config.
  /// @param sender The sender of the message on the source chain. This can be used to implement sender-specific
  /// security policies, such as allowing FTF only for trusted senders.
  /// @dev Messages are executable when either the required finality has been reached, or the chain has marked the
  /// block as finalized. Whichever one comes first will allow the message to be executed.
  /// @return requiredCCVs The list of required CCVs for messages from this source chain. All of these CCVs must pass
  /// verification for a message to be accepted.
  /// @return optionalCCVs The list of optional CCVs for messages from this source chain. These CCVs can be used to
  /// increase the security of messages from this source chain, but are not strictly required. If any optional CCVs are
  /// included, the optionalThreshold parameter must also be set to indicate how many of the optional CCVs must pass
  /// verification for a message to be accepted.
  /// @return optionalThreshold The number of optional CCVs that must pass verification for a message to be accepted.
  /// @return allowedFinalityConfig The allowed finality config, encoded according to the `FinalityCodec`. This allows
  /// the receiver to specify which finality configs are accepted for messages from this source chain.
  function getCCVsAndFinalityConfig(
    uint64 sourceChainSelector,
    bytes calldata sender
  )
    external
    view
    returns (
      address[] memory requiredCCVs,
      address[] memory optionalCCVs,
      uint8 optionalThreshold,
      bytes4 allowedFinalityConfig
    );
}

// File: @chainlink/contracts-ccip/contracts/interfaces/IRouter.sol


pragma solidity ^0.8.0;


interface IRouter {
  error OnlyOffRamp();

  /// @notice Route the message to its intended receiver contract.
  /// @param message Client.Any2EVMMessage struct.
  /// @param gasForCallExactCheck of params for exec.
  /// @param gasLimit set of params for exec.
  /// @param receiver set of params for exec.
  /// @dev if the receiver is a contracts that signals support for CCIP execution through EIP-165.
  /// the contract is called. If not, only tokens are transferred.
  /// @return success A boolean value indicating whether the ccip message was received without errors.
  /// @return retBytes A bytes array containing return data form CCIP receiver.
  /// @return gasUsed the gas used by the external customer call. Does not include any overhead.
  function routeMessage(
    Client.Any2EVMMessage calldata message,
    uint16 gasForCallExactCheck,
    uint256 gasLimit,
    address receiver
  ) external returns (bool success, bytes memory retBytes, uint256 gasUsed);

  /// @notice Returns the configured onRamp for a specific destination chain.
  /// @param destChainSelector The destination chain Id to get the onRamp for.
  /// @return onRampAddress The address of the onRamp.
  function getOnRamp(
    uint64 destChainSelector
  ) external view returns (address onRampAddress);

  /// @notice Return true if the given offRamp is a configured offRamp for the given source chain.
  /// @param sourceChainSelector The source chain selector to check.
  /// @param offRamp The address of the offRamp to check.
  function isOffRamp(
    uint64 sourceChainSelector,
    address offRamp
  ) external view returns (bool isOffRamp);
}

// File: @chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol


pragma solidity ^0.8.4;


interface IRouterClient {
  error UnsupportedDestinationChain(uint64 destChainSelector);
  error InsufficientFeeTokenAmount();
  error InvalidMsgValue();

  /// @notice Checks if the given chain ID is supported for sending/receiving.
  /// @param destChainSelector The chain to check.
  /// @return supported is true if it is supported, false if not.
  function isChainSupported(
    uint64 destChainSelector
  ) external view returns (bool supported);

  /// @param destinationChainSelector The destination chainSelector.
  /// @param message The cross-chain CCIP message including data and/or tokens.
  /// @return fee returns execution fee for the message.
  /// delivery to destination chain, denominated in the feeToken specified in the message.
  /// @dev Reverts with appropriate reason upon invalid message.
  function getFee(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage memory message
  ) external view returns (uint256 fee);

  /// @notice Request a message to be sent to the destination chain.
  /// @param destinationChainSelector The destination chain ID.
  /// @param message The cross-chain CCIP message including data and/or tokens.
  /// @return messageId The message ID.
  /// @dev Note if msg.value is larger than the required fee (from getFee) we accept.
  /// the overpayment with no refund.
  /// @dev Reverts with appropriate reason upon invalid message.
  function ccipSend(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage calldata message
  ) external payable returns (bytes32);
}

// File: @chainlink/contracts-ccip/contracts/libraries/CCVConfigValidation.sol


pragma solidity ^0.8.4;

/// @notice CCV config validation helpers.
library CCVConfigValidation {
  error MustSpecifyDefaultOrRequiredCCVs();
  error DuplicateCCVNotAllowed(address ccvAddress);
  error ZeroAddressNotAllowed();

  /// @notice Ensures at least one CCV combined, no zero addresses, no duplicates within or across both sets.
  /// @param defaultCCV The default CCVs.
  /// @param laneMandatedCCVs The mandated CCVs.
  function _validateDefaultAndMandatedCCVs(
    address[] memory defaultCCV,
    address[] memory laneMandatedCCVs
  ) internal pure {
    uint256 defaultLength = defaultCCV.length;
    uint256 mandatedLength = laneMandatedCCVs.length;
    uint256 totalLength = defaultLength + mandatedLength;

    // There must always be at least one default or mandated CCV. This ensures that any receiver who does not specify
    // CCVs will always have at least one CCV to validate the message.
    if (totalLength == 0) revert MustSpecifyDefaultOrRequiredCCVs();

    // We check for duplicates and zero addresses in the default and mandated CCVs. We need to check for duplicates
    // between the two sets of CCVs as well as within each set. Doing these checks here means we can assume there are
    // no duplicates or zero addresses in the rest of the code.
    for (uint256 combinedIndex = 0; combinedIndex < totalLength; ++combinedIndex) {
      address currentCCVAddress =
        combinedIndex < defaultLength ? defaultCCV[combinedIndex] : laneMandatedCCVs[combinedIndex - defaultLength];
      if (currentCCVAddress == address(0)) revert ZeroAddressNotAllowed();

      for (uint256 nextIndex = combinedIndex + 1; nextIndex < totalLength; ++nextIndex) {
        address compareCCVAddress =
          nextIndex < defaultLength ? defaultCCV[nextIndex] : laneMandatedCCVs[nextIndex - defaultLength];
        if (currentCCVAddress == compareCCVAddress) revert DuplicateCCVNotAllowed(currentCCVAddress);
      }
    }
  }

  function _assertNoDuplicates(
    address[] memory addresses
  ) internal pure {
    uint256 length = addresses.length;
    for (uint256 i = 0; i < length; ++i) {
      for (uint256 j = i + 1; j < length; ++j) {
        if (addresses[i] == addresses[j]) revert DuplicateCCVNotAllowed(addresses[i]);
      }
    }
  }

  function _assertNoDuplicatedBetweenLists(
    address[] memory listA,
    address[] memory listB
  ) internal pure {
    uint256 lengthA = listA.length;
    uint256 lengthB = listB.length;
    for (uint256 i = 0; i < lengthA; ++i) {
      for (uint256 j = 0; j < lengthB; ++j) {
        if (listA[i] == listB[j]) revert DuplicateCCVNotAllowed(listA[i]);
      }
    }
  }
}

// File: @chainlink/contracts-ccip/contracts/libraries/FinalityCodec.sol


pragma solidity ^0.8.4;

/// @notice This library provides encoding and validation for finality parameters used in cross-chain transfers.
/// @dev this codec supports all the bit flags, even though some might not be assigned any meaning yet. This is
/// intentional to allow for future flexibility.
///
/// @dev Bit layout of the `bytes4` finality value (32 bits, MSB on the left):
///
///  Bit: 31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16 | 15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
///      +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
///      | R | R | R | R | R | R | R | R | R | R | R | R | R | R | R | S |                          block depth (16 bits)                |
///      +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
///      \_______________________________  _____________________________/ \______________________________  _____________________________/
///                                      \/                                                              \/
///                                 flags (16 bits)                                                  depth (16 bits)
///                                                                                                max = 65535 (0xFFFF)
///
///  S  (bit 16) = WAIT_FOR_SAFE_FLAG  — wait for the `safe` tag.
///  R  (bits 17-31) = Reserved for future flags (currently unassigned; accepted on the wire).
///                    Reserved bits may be assigned in the future, read the docs for the latest bit definitions.
///
///  Special values:
///    0x00000000  WAIT_FOR_FINALITY_FLAG  — wait for full finality (safest, default).
///    0x00010000  WAIT_FOR_SAFE_FLAG      — wait for the `safe` head (bit 16 set, no depth).
///    0x00000001..0x0000FFFF              — wait for N blocks.
library FinalityCodec {
  error InvalidRequestedFinality(bytes4 requestedFinality, bytes4 allowedFinality);
  /// @notice Requested finality must be exactly one mode: any of the flag bits or a block depth with no upper flag bits.
  /// It cannot combine a flag with a block depth.
  error RequestedFinalityCanOnlyHaveOneMode(bytes4 encodedFinality);

  /// @notice The block depth is stored in the lower 16 bits, leaving the upper 16 bits for flags.
  /// For more security, users should wait for finality instead (bytes4(0)).
  uint256 public constant BLOCK_DEPTH_BITS = 16;
  /// @notice The maximum block depth that can be encoded in the finality params.
  uint16 public constant MAX_BLOCK_DEPTH = type(uint16).max;
  /// @notice The block depth mask to extract the block depth from the finality params.
  bytes4 public constant BLOCK_DEPTH_MASK = bytes4(uint32(MAX_BLOCK_DEPTH));

  /// @notice The finality flag for waiting for finality is 0, this is the safest option. Any block depth that's deeper
  /// than finality will fall back to finality, meaning a very deep block depth will not be more secure than finality.
  bytes4 public constant WAIT_FOR_FINALITY_FLAG = bytes4(0);
  /// @notice Signals to wait for the `safe` tag.
  bytes4 public constant WAIT_FOR_SAFE_FLAG = bytes4(uint32(1 << BLOCK_DEPTH_BITS));

  /// @notice Helper to encode block depth into the finality params. Returns WAIT_FOR_FINALITY_FLAG if the block depth
  /// is zero.
  /// @param blockDepth The block depth to encode into the finality params.
  /// @return The encoded finality params with the block depth.
  function _encodeBlockDepth(
    uint16 blockDepth
  ) internal pure returns (bytes4) {
    return bytes4(uint32(blockDepth));
  }

  /// @notice Helper to encode the `safe` tag plus a block depth into the finality params.
  /// NOTE: this format is only allowed for allowed finality, not requested finality, as requested finality can only
  /// contain a single flag or block depth, but allowed finality can contain multiple.
  /// @param blockDepth The block depth to encode into the finality params.
  /// @return The encoded finality params with the `safe` tag and block depth.
  function _encodeBlockDepthAndSafeFlag(
    uint16 blockDepth
  ) internal pure returns (bytes4) {
    return _encodeBlockDepth(blockDepth) | WAIT_FOR_SAFE_FLAG;
  }

  /// @notice Validates requested finality: either `bytes4(0)`, exactly one set bit among the upper flag bits, or a pure
  /// block depth (no flag bits, depth in `1..MAX_BLOCK_DEPTH`). Never a flag combined with a non-zero depth. Unknown
  /// flags are accepted here for wire compatibility; pools/CCVs reject modes they do not implement.
  /// @param encodedFinality The encoded finality params to validate.
  function _validateRequestedFinality(
    bytes4 encodedFinality
  ) internal pure {
    // Waiting for finality is always valid.
    if (encodedFinality == WAIT_FOR_FINALITY_FLAG) {
      return;
    }
    bool hasBlockDepth = encodedFinality & BLOCK_DEPTH_MASK != 0;
    uint256 activeModes = hasBlockDepth ? 1 : 0; // If it has depth, it counts as one active mode.

    uint32 flags = uint32(encodedFinality) >> BLOCK_DEPTH_BITS;
    if (flags != 0) {
      for (uint256 i = 0; i < 16; ++i) {
        if ((flags & (1 << i)) != 0) {
          activeModes += 1;
        }
      }
    }
    // There must be exactly one active mode: either a block depth or a single flag. Selecting multiple modes is only
    // allowed for `allowedFinality` set by Pools, CCVs, etc., but not for `requestedFinality` set by senders.
    if (activeModes != 1) {
      revert RequestedFinalityCanOnlyHaveOneMode(encodedFinality);
    }
  }

  /// @notice Validates that `requestedFinality` is well-formed and permitted by `allowedFinality`.
  /// @param requestedFinality The requested finality params to check.
  /// @param allowedFinality The allowed finality params to check against.
  function _ensureRequestedFinalityAllowed(
    bytes4 requestedFinality,
    bytes4 allowedFinality
  ) internal pure {
    // Finality is always allowed.
    if (requestedFinality == WAIT_FOR_FINALITY_FLAG) {
      return;
    }

    // Validate the structural shape of the requested finality, as it is only allowed to signal one mode.
    _validateRequestedFinality(requestedFinality);

    // If any of the flags match, the request is allowed only when it has no depth field (flag-only request).
    if (((requestedFinality >> BLOCK_DEPTH_BITS) & (allowedFinality >> BLOCK_DEPTH_BITS)) != 0) {
      return;
    }
    // Otherwise, it must be block-depth based.
    uint32 requestedBlockDepth = uint32(requestedFinality & BLOCK_DEPTH_MASK);
    uint32 allowedBlockDepth = uint32(allowedFinality & BLOCK_DEPTH_MASK);
    if (allowedBlockDepth == 0 || requestedBlockDepth < allowedBlockDepth) {
      revert InvalidRequestedFinality(requestedFinality, allowedFinality);
    }
  }
}

// File: @chainlink/contracts-ccip/contracts/libraries/ExtraArgsCodec.sol


pragma solidity ^0.8.4;


/// @notice Gas-optimized assembly version of ExtraArgsCodec library.
library ExtraArgsCodec {
  error InvalidDataLength(EncodingErrorLocation location, uint256 offset);
  error InvalidExtraArgsTag(bytes4 expected, bytes4 actual);
  error InvalidAddressLength(uint256 length);
  error CCVArrayLengthMismatch(uint256 ccvsLength, uint256 ccvArgsLength);

  bytes4 public constant GENERIC_EXTRA_ARGS_V3_TAG = 0xa69dd4aa;
  bytes4 public constant SVM_EXECUTOR_ARGS_V1_TAG = 0x1a2b3c4d;
  bytes4 public constant SUI_EXECUTOR_ARGS_V1_TAG = 0x5e6f7a8b;

  // Base size excludes all variable-length fields (CCV addresses/args, executor address, executorArgs, tokenReceiver,
  // tokenArgs).
  // Encoding order: tag(4) + gasLimit(4) + requestedFinalityConfig(4) + ccvsLength(1) + executorLength(1) +
  // executorArgsLength(2) + tokenReceiverLength(1) + tokenArgsLength(2) = 19 bytes.
  uint256 public constant GENERIC_EXTRA_ARGS_V3_BASE_SIZE = 4 + 4 + 4 + 1 + 1 + 2 + 1 + 2;
  uint256 public constant GENERIC_EXTRA_ARGS_V3_STATIC_LENGTH_SIZE = 4 + 4 + 4 + 1;
  // Base size: tag(4) + useATA(1) + accountIsWritableBitmap(8) + accountsLength(1) = 14 bytes.
  uint256 public constant SVM_EXECUTOR_ARGS_V1_BASE_SIZE = 4 + 1 + 8 + 1;
  // Base size: tag(4) + objectIdsLength(1) = 5 bytes.
  uint256 public constant SUI_EXECUTOR_ARGS_V1_BASE_SIZE = 4 + 1;

  // Enum to indicate specific error locations during encoding/decoding.
  enum EncodingErrorLocation {
    // Generic decoding errors (used in helper functions).
    DECODE_FIELD_LENGTH, // 0 - Error reading a field's length prefix.
    DECODE_FIELD_CONTENT, // 1 - Error reading a field's content/payload.
    // Specific decoding errors (used in main decoding functions).
    EXTRA_ARGS_STATIC_LENGTH_FIELDS, // 2
    EXTRA_ARGS_FINAL_OFFSET, // 3
    SVM_EXECUTOR_ACCOUNTS_CONTENT, // 4
    SVM_EXECUTOR_FINAL_OFFSET, // 5
    SUI_EXECUTOR_OBJECT_IDS_CONTENT, // 6
    SUI_EXECUTOR_FINAL_OFFSET, // 7
    // Encoding validation errors.
    ENCODE_CCVS_ARRAY_LENGTH, // 8
    ENCODE_CCV_ARGS_LENGTH, // 9
    ENCODE_EXECUTOR_ARGS_LENGTH, // 10
    ENCODE_TOKEN_RECEIVER_LENGTH, // 11
    ENCODE_TOKEN_ARGS_LENGTH, // 12
    ENCODE_SVM_ACCOUNTS_LENGTH, // 13
    ENCODE_SUI_OBJECT_IDS_LENGTH // 14
  }

  /// @notice GenericExtraArgsV3 encoding format used for CCIP messages.
  /// Static length fields.
  ///   bytes4 tag;                     Version tag.
  ///   uint32 gasLimit;                Gas limit for the callback on the destination chain.
  ///   bytes4 requestedFinalityConfig;           Finality config (see `FinalityCodec`): block depth and/or flags.
  ///   uint8 ccvsLength;               Number of cross-chain verifiers.
  ///
  /// Variable length fields (per CCV, repeated ccvsLength times).
  ///   uint8 ccvAddressLength;         Length of the CCV address in bytes (0 or 20 for EVM addresses).
  ///   bytes ccvAddress;               CCV address as unpadded bytes (20 bytes for EVM addresses if non-zero).
  ///   uint16 ccvArgsLength;           Length of the CCV-specific arguments in bytes.
  ///   bytes ccvArgs;                  CCV-specific arguments.
  ///
  /// Variable length fields (executor and token config).
  ///   uint8 executorLength;           Length of the executor address in bytes (0 or 20 for EVM addresses).
  ///   bytes executor;                 Executor address as unpadded bytes (20 bytes for EVM addresses if non-zero).
  ///   uint16 executorArgsLength;      Length of the executor arguments in bytes.
  ///   bytes executorArgs;             Destination chain family-specific executor arguments.
  ///   uint8 tokenReceiverLength;      Length of the token receiver address in bytes (0 or 20 for EVM addresses).
  ///   bytes tokenReceiver;            Token receiver address as unpadded bytes (20 bytes for EVM addresses if non-zero).
  ///   uint16 tokenArgsLength;         Length of the token arguments in bytes.
  ///   bytes tokenArgs;                Token pool-specific arguments.
  // solhint-disable-next-line gas-struct-packing
  struct GenericExtraArgsV3 {
    /// @notice Gas limit for the callback on the destination chain. If the gas limit is zero and the message data
    /// length is also zero, no callback will be performed, even if a receiver is specified. A gas limit of zero is
    /// useful when only token transfers are desired, or when the receiver is an EOA account instead of a contract.
    /// Besides this gasLimit check, there are other checks on the destination chain that may prevent the callback from
    /// being executed, depending on the destination chain family.
    /// @dev The sender is billed for the gas specified, not the gas actually used. Any unspent gas is not refunded.
    /// There are various ways to estimate the gas required for a callback on the destination chain, depending on the
    /// chain family. Please refer to the documentation for each chain for more details.
    uint32 gasLimit;
    /// @notice The finality config, see FinalityCodec for encoding details.
    /// @dev May be zero to indicate waiting for finality is desired.
    bytes4 requestedFinalityConfig;
    /// @notice An array of CCV addresses representing the cross-chain verifiers to be used for the message.
    /// @dev May be empty to specify the default verifier(s) should be used.
    address[] ccvs;
    /// @notice Optional arguments that are passed into the CCV without modification or inspection. CCIP itself does not
    /// interpret these arguments: they are encoded in whatever format the CCV has decided.
    /// @dev Must be the same length as the `ccvs` array. May have empty bytes as arguments.
    bytes[] ccvArgs;
    /// @notice Address of the executor contract on the source chain. The executor is responsible for executing the
    /// message on the destination chains once a quorum of CCVs have verified the message.
    /// @dev May be address(0) to indicate the default executor should be used.
    address executor;
    /// @notice Destination chain family specific arguments for the executor. This field is passed to the destination
    /// chain as part of the message itself and these args are therefore fully protected through the message ID. The
    /// format of this field is specific to each chain family and is not interpreted by CCIP itself, only by the
    /// executor. Things that may be included here are Solana accounts or Sui object IDs, which must be secured through
    /// the message ID as passing in incorrect values can lead to loss of funds.
    /// @dev May be empty depending on the destination chain.
    bytes executorArgs;
    /// @notice Address of the token receiver on the destination chain, in bytes format. If an empty bytes array is
    /// provided, the receiver address from the message itself is used for token transfers. This field allows for
    /// scenarios where the token receiver is different from the message receiver.
    /// @dev May be empty, the behavior differs depending on if there is a token transfer or not:
    /// - If there is a token transfer, the receiver from the message is used.
    /// - If there is no token transfer, this field should be empty.
    bytes tokenReceiver;
    /// @notice Additional arguments for token transfers. This field is passed into the token pool on the source chain
    /// and is not inspected by CCIP itself. The format of this field is therefore specific to the token pool being used
    /// and may vary between different pools.
    /// @dev May be empty depending on the token pool.
    bytes tokenArgs;
  }

  /// @notice Creates a basic encoded GenericExtraArgsV3 with only gasLimit and finality config set.
  /// @param gasLimit The gas limit for the callback on the destination chain.
  /// @param finalityConfig The finality config, encoded via `FinalityCodec`.
  /// @return encoded The encoded extra args as bytes. These are ready to be passed into CCIP functions.
  function _getBasicEncodedExtraArgsV3(
    uint32 gasLimit,
    bytes4 finalityConfig
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(GENERIC_EXTRA_ARGS_V3_TAG, gasLimit, finalityConfig, bytes7(0));
  }

  /// @notice Creates a basic encoded GenericExtraArgsV3 with only gasLimit and block-depth finality set.
  /// @param gasLimit The gas limit for the callback on the destination chain.
  /// @param blockDepth Block depth encoded via `FinalityCodec._encodeBlockDepth` (no upper flag bits).
  /// @return encoded The encoded extra args as bytes. These are ready to be passed into CCIP functions.
  function _getBasicEncodedExtraArgsV3BlockDepth(
    uint32 gasLimit,
    uint16 blockDepth
  ) internal pure returns (bytes memory) {
    return _getBasicEncodedExtraArgsV3(gasLimit, FinalityCodec._encodeBlockDepth(blockDepth));
  }

  /// @notice Creates a basic encoded GenericExtraArgsV3 with a given gasLimit and the Fast Confirmation Rule as
  /// the finality config. The Fast Confirmation Rule is a special finality config that signals to wait for the `safe`
  /// tag.
  /// @param gasLimit The gas limit for the callback on the destination chain.
  /// @return encoded The encoded extra args as bytes. These are ready to be passed into CCIP functions.
  function _getBasicEncodedExtraArgsV3FastConfirmationRule(
    uint32 gasLimit
  ) internal pure returns (bytes memory) {
    return _getBasicEncodedExtraArgsV3(gasLimit, FinalityCodec.WAIT_FOR_SAFE_FLAG);
  }

  enum SVMTokenReceiverUsage {
    DERIVE_ATA_AND_CREATE,
    DERIVE_ATA_DONT_CREATE,
    USE_AS_IS
  }

  struct SVMExecutorArgsV1 {
    SVMTokenReceiverUsage useATA;
    uint64 accountIsWritableBitmap;
    // Additional accounts needed for execution of CCIP receiver. Must be empty if message.receiver is zero.
    // Token transfer related accounts are specified in the token pool lookup table on SVM.
    bytes32[] accounts;
  }

  struct SuiExecutorArgsV1 {
    bytes32[] receiverObjectIds;
  }

  /// @notice Helper function to read a uint8 length prefix and an address from calldata.
  /// @dev Reads length as 1 byte followed by the address bytes (20 bytes if non-zero).
  /// @param encoded The encoded bytes to read from.
  /// @param offset The current offset in the encoded bytes.
  /// @return addr The address read from calldata (address(0) if length was 0).
  /// @return newOffset The updated offset after reading.
  function _readUint8PrefixedAddress(
    bytes calldata encoded,
    uint256 offset
  ) private pure returns (address addr, uint256 newOffset) {
    // Unchecked is safe as the offset can never approach type(uint256).max.
    unchecked {
      // Read address length (1 byte).
      if (offset + 1 > encoded.length) revert InvalidDataLength(EncodingErrorLocation.DECODE_FIELD_LENGTH, offset);
      uint256 addrLength;
      assembly ("memory-safe") {
        addrLength := byte(0, calldataload(add(encoded.offset, offset)))
      }
      newOffset = offset + 1;

      // If the address is zero length, we are done and return address(0).
      if (addrLength == 0) {
        return (address(0), newOffset);
      }

      // Validate address length 20 as these extraArgs are for EVM and the only valid address length is 20.
      if (addrLength != 20) {
        revert InvalidAddressLength(addrLength);
      }

      // Read address content, unchecked is safe as the offset can never approach type(uint256).max.
      if (newOffset + addrLength > encoded.length) {
        revert InvalidDataLength(EncodingErrorLocation.DECODE_FIELD_CONTENT, newOffset);
      }

      assembly ("memory-safe") {
        let addrData := calldataload(add(encoded.offset, newOffset))
        addr := shr(96, addrData)
      }
      newOffset += addrLength;
    }
    return (addr, newOffset);
  }

  /// @notice Helper function to read a uint16 length prefix and bytes data from calldata.
  /// @dev Reads length as 2 bytes (big endian) followed by the data bytes.
  /// @param encoded The encoded bytes to read from.
  /// @param offset The current offset in the encoded bytes.
  /// @return data The bytes data read from calldata.
  /// @return newOffset The updated offset after reading.
  function _readUint16PrefixedBytes(
    bytes calldata encoded,
    uint256 offset
  ) private pure returns (bytes calldata data, uint256 newOffset) {
    // Unchecked is safe as the offset can never approach type(uint256).max.
    unchecked {
      // Read length (2 bytes).
      if (offset + 2 > encoded.length) revert InvalidDataLength(EncodingErrorLocation.DECODE_FIELD_LENGTH, offset);
      uint256 dataLength;
      assembly ("memory-safe") {
        let lengthData := calldataload(add(encoded.offset, offset))
        dataLength := and(shr(240, lengthData), 0xFFFF)
      }
      newOffset = offset + 2;

      if (newOffset + dataLength > encoded.length) {
        revert InvalidDataLength(EncodingErrorLocation.DECODE_FIELD_CONTENT, newOffset);
      }

      // Read content.
      data = encoded[newOffset:newOffset + dataLength];
      newOffset += dataLength;
    }
    return (data, newOffset);
  }

  /// @notice Helper function to read a uint8 length prefix and bytes data from calldata.
  /// @dev Reads length as 1 byte followed by the data bytes.
  /// @param encoded The encoded bytes to read from.
  /// @param offset The current offset in the encoded bytes.
  /// @return data The bytes data read from calldata.
  /// @return newOffset The updated offset after reading.
  function _readUint8PrefixedBytes(
    bytes calldata encoded,
    uint256 offset
  ) private pure returns (bytes calldata data, uint256 newOffset) {
    // Unchecked is safe as the offset can never approach type(uint256).max.
    unchecked {
      // Read length (1 byte).
      if (offset + 1 > encoded.length) revert InvalidDataLength(EncodingErrorLocation.DECODE_FIELD_LENGTH, offset);
      uint256 dataLength;
      assembly ("memory-safe") {
        dataLength := byte(0, calldataload(add(encoded.offset, offset)))
      }
      newOffset = offset + 1;

      if (newOffset + dataLength > encoded.length) {
        revert InvalidDataLength(EncodingErrorLocation.DECODE_FIELD_CONTENT, newOffset);
      }

      // Read content.
      data = encoded[newOffset:newOffset + dataLength];
      newOffset += dataLength;
    }
    return (data, newOffset);
  }

  /// @notice Helper function to write a uint8 length prefix and an address. This function writes 12 bytes of overshoot
  /// to the pointer location. This must be handled by the caller.
  /// @dev Writes length as 1 byte followed by the address bytes (20 bytes if non-zero).
  /// @param ptr The memory pointer where to start writing.
  /// @param addr The address to write.
  /// @return newPtr The updated memory pointer after writing.
  function _writeUint8PrefixedAddress(
    uint256 ptr,
    address addr
  ) private pure returns (uint256 newPtr) {
    assembly {
      let addrLength := mul(iszero(iszero(addr)), 20)
      // Write address length (1 byte).
      mstore8(ptr, addrLength)
      newPtr := add(ptr, 1)

      // Write address if non-zero.
      if gt(addrLength, 0) {
        mstore(newPtr, shl(96, addr))
        newPtr := add(newPtr, 20)
      }
    }
    return newPtr;
  }

  /// @notice Helper function to write a uint16 length prefix and copy bytes data. This function can write overshoot
  /// to the pointer location of at most 31 bytes. This must be handled by the caller. The overshoot depends on the data
  /// length.
  /// @dev Writes length as 2 bytes (big endian) followed by the data bytes.
  /// @param ptr The memory pointer where to start writing.
  /// @param data The bytes data to write.
  /// @return newPtr The updated memory pointer after writing.
  function _writeUint16PrefixedBytes(
    uint256 ptr,
    bytes memory data
  ) private pure returns (uint256 newPtr) {
    uint256 dataLength = data.length;
    assembly {
      // Write length (2 bytes, big endian).
      mstore8(ptr, shr(8, dataLength))
      mstore8(add(ptr, 1), and(dataLength, 0xFF))
      newPtr := add(ptr, 2)

      // Copy data.
      if gt(dataLength, 0) {
        let srcPtr := add(data, 32)
        for { let end := add(srcPtr, dataLength) } lt(srcPtr, end) { srcPtr := add(srcPtr, 32) } {
          mstore(newPtr, mload(srcPtr))
          newPtr := add(newPtr, 32)
        }
        // Adjust ptr if we overshot.
        newPtr := sub(newPtr, sub(and(add(dataLength, 31), not(31)), dataLength))
      }
    }
    return newPtr;
  }

  /// @notice Helper function to write a uint8 length prefix and copy bytes data. This function can write overshoot
  /// to the pointer location of at most 31 bytes. This must be handled by the caller. The overshoot depends on the data
  /// length.
  /// @dev Writes length as 1 byte followed by the data bytes.
  /// @param ptr The memory pointer where to start writing.
  /// @param data The bytes data to write.
  /// @return newPtr The updated memory pointer after writing.
  function _writeUint8PrefixedBytes(
    uint256 ptr,
    bytes memory data
  ) private pure returns (uint256 newPtr) {
    uint256 dataLength = data.length;
    assembly {
      // Write length (1 byte).
      mstore8(ptr, dataLength)
      newPtr := add(ptr, 1)

      // Copy data.
      if gt(dataLength, 0) {
        let srcPtr := add(data, 32)
        for { let end := add(srcPtr, dataLength) } lt(srcPtr, end) { srcPtr := add(srcPtr, 32) } {
          mstore(newPtr, mload(srcPtr))
          newPtr := add(newPtr, 32)
        }
        // Adjust ptr if we overshot.
        newPtr := sub(newPtr, sub(and(add(dataLength, 31), not(31)), dataLength))
      }
    }
    return newPtr;
  }

  /// @notice Encodes a GenericExtraArgsV3 struct into bytes using assembly for gas efficiency.
  /// @param extraArgs The GenericExtraArgsV3 struct to encode.
  /// @return encoded The encoded extra args as bytes.
  function _encodeGenericExtraArgsV3(
    GenericExtraArgsV3 memory extraArgs
  ) internal pure returns (bytes memory encoded) {
    // Validate ccvs and ccvArgs arrays have the same length.
    uint256 ccvsLength = extraArgs.ccvs.length;
    if (ccvsLength != extraArgs.ccvArgs.length) {
      revert CCVArrayLengthMismatch(ccvsLength, extraArgs.ccvArgs.length);
    }

    // Validate field lengths.
    if (ccvsLength > type(uint8).max) {
      revert InvalidDataLength(EncodingErrorLocation.ENCODE_CCVS_ARRAY_LENGTH, 0);
    }
    uint256 executorArgsLength = extraArgs.executorArgs.length;
    if (executorArgsLength > type(uint16).max) {
      revert InvalidDataLength(EncodingErrorLocation.ENCODE_EXECUTOR_ARGS_LENGTH, 0);
    }
    uint256 tokenReceiverLength = extraArgs.tokenReceiver.length;
    if (tokenReceiverLength > type(uint8).max) {
      revert InvalidDataLength(EncodingErrorLocation.ENCODE_TOKEN_RECEIVER_LENGTH, 0);
    }
    uint256 tokenArgsLength = extraArgs.tokenArgs.length;
    if (tokenArgsLength > type(uint16).max) {
      revert InvalidDataLength(EncodingErrorLocation.ENCODE_TOKEN_ARGS_LENGTH, 0);
    }

    // Calculate executor length.
    uint256 executorLength = extraArgs.executor == address(0) ? 0 : 20;

    // Calculate total CCV encoded size and validate.
    uint256 ccvsEncodedSize = 0;
    for (uint256 i = 0; i < ccvsLength; ++i) {
      uint256 ccvAddrLength = extraArgs.ccvs[i] == address(0) ? 0 : 20;

      uint256 ccvArgLength = extraArgs.ccvArgs[i].length;
      if (ccvArgLength > type(uint16).max) {
        revert InvalidDataLength(EncodingErrorLocation.ENCODE_CCV_ARGS_LENGTH, 0);
      }

      // 1 byte for address length + address bytes + 2 bytes for args length + args bytes.
      ccvsEncodedSize += 1 + ccvAddrLength + 2 + ccvArgLength;
    }

    // Allocate memory.
    // GENERIC_EXTRA_ARGS_V3_BASE_SIZE + all variable-length fields + 32 bytes to account for any potential overshoot
    // that comes from writing 32-byte blocks of data.
    encoded = new bytes(
      GENERIC_EXTRA_ARGS_V3_BASE_SIZE + ccvsEncodedSize + executorLength + executorArgsLength + tokenReceiverLength
        + tokenArgsLength + 32
    );

    bytes memory staticFields = abi.encodePacked(
      GENERIC_EXTRA_ARGS_V3_TAG, extraArgs.gasLimit, extraArgs.requestedFinalityConfig, uint8(ccvsLength)
    );

    uint256 ptr;
    // This block is memory safe because it only writes to the allocated `encoded` bytes.
    assembly ("memory-safe") {
      ptr := add(encoded, 32) // Skip length prefix.

      // Write static-length fields.
      mstore(ptr, mload(add(staticFields, 32)))
      ptr := add(ptr, GENERIC_EXTRA_ARGS_V3_STATIC_LENGTH_SIZE)
    }

    // Write CCVs data.
    for (uint256 i = 0; i < ccvsLength; ++i) {
      ptr = _writeUint8PrefixedAddress(ptr, extraArgs.ccvs[i]);
      ptr = _writeUint16PrefixedBytes(ptr, extraArgs.ccvArgs[i]);
    }

    // Write executor, executorArgs, tokenReceiver, tokenArgs.
    ptr = _writeUint8PrefixedAddress(ptr, extraArgs.executor);
    ptr = _writeUint16PrefixedBytes(ptr, extraArgs.executorArgs);
    ptr = _writeUint8PrefixedBytes(ptr, extraArgs.tokenReceiver);
    ptr = _writeUint16PrefixedBytes(ptr, extraArgs.tokenArgs);

    // Verify that we've exactly filled the allocated bytes. We load the data offset of the bytes array to be able to
    // compare with ptr.
    uint256 encodedDataOffset;
    assembly ("memory-safe") {
      mstore(encoded, sub(mload(encoded), 32)) // Set correct length as we overprovisioned for overshoot.
      encodedDataOffset := encoded
    }
    // The pointer should be at the end of the allocated data (data offset + length + 32 bytes for length prefix).
    if (ptr != encodedDataOffset + encoded.length + 32) {
      revert InvalidDataLength(EncodingErrorLocation.EXTRA_ARGS_FINAL_OFFSET, ptr - encodedDataOffset);
    }

    return encoded;
  }

  /// @notice Decodes bytes into a GenericExtraArgsV3 struct using assembly for gas efficiency.
  /// @param encoded The encoded bytes to decode.
  /// @return extraArgs The decoded GenericExtraArgsV3 struct.
  function _decodeGenericExtraArgsV3(
    bytes calldata encoded
  ) internal pure returns (GenericExtraArgsV3 memory extraArgs) {
    // Check if encodedLength is at least the minimum size.
    if (encoded.length < GENERIC_EXTRA_ARGS_V3_BASE_SIZE) {
      revert InvalidDataLength(EncodingErrorLocation.EXTRA_ARGS_STATIC_LENGTH_FIELDS, encoded.length);
    }

    // Check tag.
    bytes4 tag;
    assembly ("memory-safe") {
      tag := calldataload(encoded.offset)
    }

    if (tag != GENERIC_EXTRA_ARGS_V3_TAG) {
      revert InvalidExtraArgsTag(GENERIC_EXTRA_ARGS_V3_TAG, tag);
    }

    uint256 ccvsLength;
    // Read static-length fields.
    assembly ("memory-safe") {
      // Read gas limit (4 bytes).
      let gasLimit := calldataload(add(encoded.offset, 4))
      mstore(extraArgs, and(shr(224, gasLimit), 0xFFFFFFFF))

      // Read requestedFinalityConfig (4 bytes).
      // bytes4 is left-aligned in memory, so mask the top 4 bytes of the loaded word directly
      // instead of shifting right (which would produce a right-aligned uint that reads back as zero).
      let finalityWord := calldataload(add(encoded.offset, 8))
      mstore(add(extraArgs, 32), and(finalityWord, shl(224, 0xFFFFFFFF)))

      // Read ccvs length (1 byte).
      ccvsLength := byte(0, calldataload(add(encoded.offset, 12)))
    }

    uint256 offset = GENERIC_EXTRA_ARGS_V3_STATIC_LENGTH_SIZE; // Skip tag, gasLimit, requestedFinalityConfig, ccvsLength.

    // Allocate arrays for CCVs.
    extraArgs.ccvs = new address[](ccvsLength);
    extraArgs.ccvArgs = new bytes[](ccvsLength);

    // Decode CCVs and args.
    for (uint256 i = 0; i < ccvsLength; ++i) {
      (extraArgs.ccvs[i], offset) = _readUint8PrefixedAddress(encoded, offset);
      (extraArgs.ccvArgs[i], offset) = _readUint16PrefixedBytes(encoded, offset);
    }

    // Read executor, executorArgs, tokenReceiver, and tokenArgs.
    (extraArgs.executor, offset) = _readUint8PrefixedAddress(encoded, offset);
    (extraArgs.executorArgs, offset) = _readUint16PrefixedBytes(encoded, offset);
    (extraArgs.tokenReceiver, offset) = _readUint8PrefixedBytes(encoded, offset);
    (extraArgs.tokenArgs, offset) = _readUint16PrefixedBytes(encoded, offset);

    // Ensure we've consumed all bytes.
    if (offset != encoded.length) revert InvalidDataLength(EncodingErrorLocation.EXTRA_ARGS_FINAL_OFFSET, offset);

    return extraArgs;
  }

  /// @notice Encodes a SVMExecutorArgsV1 struct into bytes.
  /// @param executorArgs The SVMExecutorArgsV1 struct to encode.
  /// @return encoded The encoded executor args as bytes.
  function _encodeSVMExecutorArgsV1(
    SVMExecutorArgsV1 memory executorArgs
  ) internal pure returns (bytes memory encoded) {
    uint256 accountsLength = executorArgs.accounts.length;
    if (accountsLength > type(uint8).max) {
      revert InvalidDataLength(EncodingErrorLocation.ENCODE_SVM_ACCOUNTS_LENGTH, 0);
    }

    return abi.encodePacked(
      SVM_EXECUTOR_ARGS_V1_TAG,
      uint8(executorArgs.useATA),
      executorArgs.accountIsWritableBitmap,
      uint8(accountsLength),
      executorArgs.accounts
    );
  }

  /// @notice Decodes bytes into a SVMExecutorArgsV1 struct using assembly.
  /// @param encoded The encoded bytes to decode.
  /// @return executorArgs The decoded SVMExecutorArgsV1 struct.
  function _decodeSVMExecutorArgsV1(
    bytes calldata encoded
  ) internal pure returns (SVMExecutorArgsV1 memory executorArgs) {
    // Unchecked is safe as the offset can never approach type(uint256).max.
    unchecked {
      if (encoded.length < SVM_EXECUTOR_ARGS_V1_BASE_SIZE) {
        revert InvalidDataLength(EncodingErrorLocation.EXTRA_ARGS_STATIC_LENGTH_FIELDS, encoded.length);
      }

      // Check tag.
      bytes4 tag;
      assembly ("memory-safe") {
        tag := calldataload(encoded.offset)
      }

      if (tag != SVM_EXECUTOR_ARGS_V1_TAG) {
        revert InvalidExtraArgsTag(SVM_EXECUTOR_ARGS_V1_TAG, tag);
      }

      uint256 accountsLength;
      // uint8, not bytes1: byte(0,...) returns a right-aligned value (low 8 bits set).
      uint8 useATA;

      // Read static-length fields.
      assembly ("memory-safe") {
        // Read useATA (1 byte) - enum value.
        // byte(0, x) extracts the MSB of x and places it right-aligned, matching uint8 layout.
        useATA := byte(0, calldataload(add(encoded.offset, 4)))
        mstore(executorArgs, useATA)

        // Read accountIsWritableBitmap (8 bytes).
        let bitmap := calldataload(add(encoded.offset, 5))
        mstore(add(executorArgs, 32), and(shr(192, bitmap), 0xFFFFFFFFFFFFFFFF))

        // Read accounts length (1 byte).
        accountsLength := byte(0, calldataload(add(encoded.offset, 13)))
      }

      if (useATA > uint8(SVMTokenReceiverUsage.USE_AS_IS)) {
        revert InvalidDataLength(EncodingErrorLocation.DECODE_FIELD_CONTENT, 4);
      }

      uint256 offset = SVM_EXECUTOR_ARGS_V1_BASE_SIZE;

      // Read accounts.
      if (offset + accountsLength * 32 > encoded.length) {
        revert InvalidDataLength(EncodingErrorLocation.SVM_EXECUTOR_ACCOUNTS_CONTENT, offset);
      }

      executorArgs.accounts = new bytes32[](accountsLength);
      for (uint256 i = 0; i < accountsLength; ++i) {
        assembly ("memory-safe") {
          let data := calldataload(add(add(encoded.offset, offset), mul(i, 32)))
          let accountsArray := mload(add(executorArgs, 64))
          mstore(add(add(accountsArray, 32), mul(i, 32)), data)
        }
      }
      offset += accountsLength * 32;

      // Ensure we've consumed all bytes.
      if (offset != encoded.length) revert InvalidDataLength(EncodingErrorLocation.SVM_EXECUTOR_FINAL_OFFSET, offset);
    }
    return executorArgs;
  }

  /// @notice Encodes a SuiExecutorArgsV1 struct into bytes.
  /// @param executorArgs The SuiExecutorArgsV1 struct to encode.
  /// @return encoded The encoded executor args as bytes.
  function _encodeSuiExecutorArgsV1(
    SuiExecutorArgsV1 memory executorArgs
  ) internal pure returns (bytes memory encoded) {
    uint256 objectIdsLength = executorArgs.receiverObjectIds.length;
    if (objectIdsLength > type(uint8).max) {
      revert InvalidDataLength(EncodingErrorLocation.ENCODE_SUI_OBJECT_IDS_LENGTH, 0);
    }

    return abi.encodePacked(SUI_EXECUTOR_ARGS_V1_TAG, uint8(objectIdsLength), executorArgs.receiverObjectIds);
  }

  /// @notice Decodes bytes into a SuiExecutorArgsV1 struct using assembly.
  /// @param encoded The encoded bytes to decode.
  /// @return executorArgs The decoded SuiExecutorArgsV1 struct.
  function _decodeSuiExecutorArgsV1(
    bytes calldata encoded
  ) internal pure returns (SuiExecutorArgsV1 memory executorArgs) {
    // Unchecked is safe as the offset can never approach type(uint256).max.
    unchecked {
      if (encoded.length < SUI_EXECUTOR_ARGS_V1_BASE_SIZE) {
        revert InvalidDataLength(EncodingErrorLocation.EXTRA_ARGS_STATIC_LENGTH_FIELDS, encoded.length);
      }

      // Check tag.
      bytes4 tag;
      assembly ("memory-safe") {
        tag := calldataload(encoded.offset)
      }

      if (tag != SUI_EXECUTOR_ARGS_V1_TAG) {
        revert InvalidExtraArgsTag(SUI_EXECUTOR_ARGS_V1_TAG, tag);
      }

      // Read objectIds length.
      uint256 objectIdsLength;
      assembly ("memory-safe") {
        objectIdsLength := byte(0, calldataload(add(encoded.offset, 4)))
      }

      uint256 offset = SUI_EXECUTOR_ARGS_V1_BASE_SIZE;
      // Read objectIds.
      if (offset + objectIdsLength * 32 > encoded.length) {
        revert InvalidDataLength(EncodingErrorLocation.SUI_EXECUTOR_OBJECT_IDS_CONTENT, offset);
      }

      executorArgs.receiverObjectIds = new bytes32[](objectIdsLength);
      for (uint256 i = 0; i < objectIdsLength; ++i) {
        assembly ("memory-safe") {
          let data := calldataload(add(add(encoded.offset, offset), mul(i, 32)))
          let objectIdsArray := mload(executorArgs)
          mstore(add(add(objectIdsArray, 32), mul(i, 32)), data)
        }
      }
      offset += objectIdsLength * 32;

      // Ensure we've consumed all bytes.
      if (offset != encoded.length) revert InvalidDataLength(EncodingErrorLocation.SUI_EXECUTOR_FINAL_OFFSET, offset);
    }
    return executorArgs;
  }
}

// File: @chainlink/contracts-ccip/contracts/libraries/Internal.sol


pragma solidity ^0.8.4;

/// @notice Library for CCIP internal definitions common to multiple contracts.
/// @dev The following is a non-exhaustive list of "known issues" for CCIP:
/// - We could implement yield claiming for Blast. This is not worth the custom code path on non-blast chains.
/// - uint32 is used for timestamps, which will overflow in 2106. This is not a concern for the current use case, as we
/// expect to have migrated to a new version by then.
library Internal {
  // bytes4(keccak256("CCIP ChainFamilySelector EVM"));
  bytes4 public constant CHAIN_FAMILY_SELECTOR_EVM = 0x2812d52c;

  // bytes4(keccak256("CCIP ChainFamilySelector SVM"));
  bytes4 public constant CHAIN_FAMILY_SELECTOR_SVM = 0x1e10bdc4;

  // bytes4(keccak256("CCIP ChainFamilySelector APTOS"));
  bytes4 public constant CHAIN_FAMILY_SELECTOR_APTOS = 0xac77ffec;

  // bytes4(keccak256("CCIP ChainFamilySelector SUI"));
  bytes4 public constant CHAIN_FAMILY_SELECTOR_SUI = 0xc4e05953;

  // byte4(keccak256("CCIP ChainFamilySelector TVM"));
  bytes4 public constant CHAIN_FAMILY_SELECTOR_TVM = 0x647e2ba9;

  error InvalidEVMAddress(bytes encodedAddress);
  error Invalid32ByteAddress(bytes encodedAddress);
  error InvalidTVMAddress(bytes encodedAddress);

  /// @dev We limit return data to a selector plus 4 words. This is to avoid malicious contracts from returning
  /// large amounts of data and causing repeated out-of-gas scenarios.
  uint16 internal constant MAX_RET_BYTES = 4 + 4 * 32;

  /// @dev The address used to send calls for gas estimation.
  /// You only need to use this address if the minimum gas limit specified by the user is not actually enough to execute the
  /// given message and you're attempting to estimate the actual necessary gas limit
  address public constant GAS_ESTIMATION_SENDER = address(0xC11C11C11C11C11C11C11C11C11C11C11C11C1);

  /// @notice A collection of token price and gas price updates.
  struct PriceUpdates {
    TokenPriceUpdate[] tokenPriceUpdates;
    GasPriceUpdate[] gasPriceUpdates;
  }

  /// @notice Token price in USD.
  struct TokenPriceUpdate {
    address sourceToken; // Source token.
    uint224 usdPerToken; // 1e18 USD per 1e18 of the smallest token denomination.
  }

  /// @notice Gas price for a given chain in USD, its value may contain tightly packed fields.
  struct GasPriceUpdate {
    uint64 destChainSelector; // Destination chain selector.
    uint224 usdPerUnitGas; // 1e18 USD per smallest unit (e.g. wei) of destination chain gas.
  }

  /// @notice A timestamped uint224 value that can contain several tightly packed fields.
  struct TimestampedPackedUint224 {
    uint224 value; // ────╮ Value in uint224, packed.
    uint32 timestamp; // ─╯ Timestamp of the most recent price update.
  }

  /// @dev Gas price is stored in 112-bit unsigned int. uint224 can pack 2 prices.
  /// When packing L1 and L2 gas prices, L1 gas price is left-shifted to the higher-order bits.
  /// Using uint8 type, which cannot be higher than other bit shift operands, to avoid shift operand type warning.
  uint8 public constant GAS_PRICE_BITS = 112;

  struct SourceTokenData {
    // The source pool address, abi encoded. This value is trusted as it was obtained through the onRamp. It can be
    // relied upon by the destination pool to validate the source pool.
    bytes sourcePoolAddress;
    // The address of the destination token, abi encoded in the case of EVM chains.
    // This value is UNTRUSTED as any pool owner can return whatever value they want.
    bytes destTokenAddress;
    // Optional pool data to be transferred to the destination chain. Be default this is capped at
    // CCIP_LOCK_OR_BURN_V1_RET_BYTES bytes. If more data is required, the TokenTransferFeeConfig.destBytesOverhead
    // has to be set for the specific token.
    bytes extraData;
    uint32 destGasAmount; // The amount of gas available for the releaseOrMint and balanceOf calls on the offRamp
  }

  /// @dev We disallow the first 1024 addresses to avoid calling into a range known for hosting precompiles. Calling
  /// into precompiles probably won't cause any issues, but to be safe we can disallow this range. It is extremely
  /// unlikely that anyone would ever be able to generate an address in this range. There is no official range of
  /// precompiles, but EIP-7587 proposes to reserve the range 0x100 to 0x1ff. Our range is more conservative, even
  /// though it might not be exhaustive for all chains, which is OK. We also disallow the zero address, which is a
  /// common practice.
  uint256 public constant EVM_PRECOMPILE_SPACE = 1024;

  // According to the Aptos docs, the first 0xa addresses are reserved for precompiles.
  // https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-framework/doc/account.md#function-create_framework_reserved_account-1
  uint256 public constant APTOS_PRECOMPILE_SPACE = 0x0b;

  // According to the Sui docs, a set of non-contiguous addresses below 0xdee9 are reserved for system use.
  // https://github.com/MystenLabs/sui/blob/54ae98508569804127bd73d84aa2fb816bdea402/crates/sui-types/src/lib.rs#L141
  uint256 public constant SUI_PRECOMPILE_SPACE = 0xdee9;

  /// @notice This methods provides validation for parsing abi encoded addresses by ensuring the address is within the
  /// EVM address space. If it isn't it will revert with an InvalidEVMAddress error, which we can catch and handle
  /// more gracefully than a revert from abi.decode.
  function _validateEVMAddress(
    bytes memory encodedAddress
  ) internal pure {
    if (encodedAddress.length != 32) revert InvalidEVMAddress(encodedAddress);
    uint256 encodedAddressUint = abi.decode(encodedAddress, (uint256));
    if (encodedAddressUint > type(uint160).max || encodedAddressUint < EVM_PRECOMPILE_SPACE) {
      revert InvalidEVMAddress(encodedAddress);
    }
  }

  /// @notice This method left-pads a byte array to 32 bytes. If the input data is longer than 32 bytes, it will
  /// revert with an Invalid32ByteAddress error.
  /// @param data The byte array to left-pad.
  /// @return The left-padded byte array.
  function _leftPadBytesToBytes32(
    bytes memory data
  ) internal pure returns (bytes32) {
    if (data.length > 32) {
      revert Invalid32ByteAddress(data);
    }
    return bytes32(uint256(bytes32(data)) >> (256 - data.length * 8));
  }

  /// @notice This methods provides validation for parsing abi encoded addresses by ensuring the address is within the
  /// bounds of [minValue, uint256.max]. If it isn't it will revert with an Invalid32ByteAddress error.
  function _validate32ByteAddress(
    bytes memory encodedAddress,
    uint256 minValue
  ) internal pure {
    if (encodedAddress.length != 32) revert Invalid32ByteAddress(encodedAddress);
    if (minValue > 0) {
      if (abi.decode(encodedAddress, (uint256)) < minValue) {
        revert Invalid32ByteAddress(encodedAddress);
      }
    }
  }

  /// @notice This methods provides validation for TON User-friendly addresses by ensuring the address is 36 bytes long.
  /// @dev The encodedAddress is expected to be the 36-byte raw representation:
  /// - 1 byte: flags (isBounceable, isTestnetOnly, etc.)
  /// - 1 byte: workchain_id (0x00 for BaseChain, 0xff for MasterChain)
  /// - 32 bytes: account_id (must be non-zero)
  /// - 2 bytes: CRC16 checksum(computationally heavy, validation omitted for simplicity)
  /// @param encodedAddress The 36-byte TON address.
  function _validateTVMAddress(
    bytes memory encodedAddress
  ) internal pure {
    if (encodedAddress.length != 36) revert InvalidTVMAddress(encodedAddress);
    bytes32 accountId;
    assembly {
      accountId := mload(add(encodedAddress, 0x22)) // 0x22 = 0x20 (data start) + 2 (offset for account_id)
    }
    if (accountId == bytes32(0)) revert InvalidTVMAddress(encodedAddress);
  }

  /// @notice Enum listing the possible message execution states within the offRamp contract.
  /// UNTOUCHED never executed.
  /// IN_PROGRESS currently being executed, used a replay protection.
  /// SUCCESS successfully executed. End state.
  /// FAILURE unsuccessfully executed, manual execution is now enabled.
  enum MessageExecutionState {
    UNTOUCHED,
    IN_PROGRESS,
    SUCCESS,
    FAILURE
  }

  struct EVM2AnyTokenTransfer {
    // The source pool EVM address. This value is trusted as it was obtained through the onRamp. It can be relied
    // upon by the destination pool to validate the source pool.
    address sourcePoolAddress;
    // The EVM address of the destination token.
    // This value is UNTRUSTED as any pool owner can return whatever value they want.
    bytes destTokenAddress;
    // Optional pool data to be transferred to the destination chain. Be default this is capped at
    // CCIP_LOCK_OR_BURN_V1_RET_BYTES bytes. If more data is required, the TokenTransferFeeConfig.destBytesOverhead
    // has to be set for the specific token.
    bytes extraData;
    uint256 amount; // Amount of tokens.
    // Destination chain data used to execute the token transfer on the destination chain. For an EVM destination, it
    // consists of the amount of gas available for the releaseOrMint and transfer calls made by the offRamp.
    bytes destExecData;
  }

  /// @dev Holds a merkle root and interval for a source chain so that an array of these can be passed in the CommitReport.
  /// @dev Inefficient struct packing intentionally chosen to maintain order of specificity. Not a storage struct so impact is minimal.
  // solhint-disable-next-line gas-struct-packing
  struct MerkleRoot {
    uint64 sourceChainSelector; // Remote source chain selector that the Merkle Root is scoped to
    bytes onRampAddress; //        Generic onRamp address, to support arbitrary sources; for EVM, use abi.encode
    uint64 minSeqNr; // ─────────╮ Minimum sequence number, inclusive
    uint64 maxSeqNr; // ─────────╯ Maximum sequence number, inclusive
    bytes32 merkleRoot; //         Merkle root covering the interval & source chain messages
  }
}

// File: @chainlink/contracts/src/v0.8/shared/call/CallWithExactGas.sol


pragma solidity ^0.8.0;

/// @notice This library contains various callWithExactGas functions. All of them are
/// safe from gas bomb attacks.
/// @dev There is code duplication in this library. This is done to not leave the assembly
/// the blocks.
library CallWithExactGas {
  error NoContract();
  error NoGasForCallExactCheck();
  error NotEnoughGasForCall();

  bytes4 internal constant NO_CONTRACT_SIG = 0x0c3b563c;
  bytes4 internal constant NO_GAS_FOR_CALL_EXACT_CHECK_SIG = 0xafa32a2c;
  bytes4 internal constant NOT_ENOUGH_GAS_FOR_CALL_SIG = 0x37c3be29;

  /// @notice calls target address with exactly gasAmount gas and payload as calldata.
  /// Accounts for gasForCallExactCheck gas that will be used by this function. Will revert
  /// if the target is not a contact. Will revert when there is not enough gas to call the
  /// target with gasAmount gas.
  /// @dev Ignores the return data, which makes it immune to gas bomb attacks.
  /// @return success whether the call succeeded
  function _callWithExactGas(
    bytes memory payload,
    address target,
    uint256 gasLimit,
    uint16 gasForCallExactCheck
  ) internal returns (bool success) {
    assembly {
      // solidity calls check that a contract actually exists at the destination, so we do the same
      // Note we do this check prior to measuring gas so gasForCallExactCheck (our "cushion")
      // doesn't need to account for it.
      if iszero(extcodesize(target)) {
        mstore(0x0, NO_CONTRACT_SIG)
        revert(0x0, 0x4)
      }

      let g := gas()
      // Compute g -= gasForCallExactCheck and check for underflow
      // The gas actually passed to the callee is _min(gasAmount, 63//64*gas available).
      // We want to ensure that we revert if gasAmount >  63//64*gas available
      // as we do not want to provide them with less, however that check itself costs
      // gas. gasForCallExactCheck ensures we have at least enough gas to be able
      // to revert if gasAmount >  63//64*gas available.
      if lt(g, gasForCallExactCheck) {
        mstore(0x0, NO_GAS_FOR_CALL_EXACT_CHECK_SIG)
        revert(0x0, 0x4)
      }
      g := sub(g, gasForCallExactCheck)
      // if g - g//64 <= gasAmount, revert. We subtract g//64 because of EIP-150
      if iszero(gt(sub(g, div(g, 64)), gasLimit)) {
        mstore(0x0, NOT_ENOUGH_GAS_FOR_CALL_SIG)
        revert(0x0, 0x4)
      }

      // call and return whether we succeeded. ignore return data
      // call(gas,addr,value,argsOffset,argsLength,retOffset,retLength)
      success := call(gasLimit, target, 0, add(payload, 0x20), mload(payload), 0x0, 0x0)
    }
    return success;
  }

  /// @notice calls target address with exactly gasAmount gas and payload as calldata.
  /// Account for gasForCallExactCheck gas that will be used by this function. Will revert
  /// if the target is not a contact. Will revert when there is not enough gas to call the
  /// target with gasAmount gas.
  /// @dev Caps the return data length, which makes it immune to gas bomb attacks.
  /// @dev Return data cap logic borrowed from
  /// https://github.com/nomad-xyz/ExcessivelySafeCall/blob/main/src/ExcessivelySafeCall.sol.
  /// @return success whether the call succeeded
  /// @return retData the return data from the call, capped at maxReturnBytes bytes
  /// @return gasUsed the gas used by the external call. Does not include the overhead of this function.
  function _callWithExactGasSafeReturnData(
    bytes memory payload,
    address target,
    uint256 gasLimit,
    uint16 gasForCallExactCheck,
    uint16 maxReturnBytes
  ) internal returns (bool success, bytes memory retData, uint256 gasUsed) {
    // allocate retData memory ahead of time
    retData = new bytes(maxReturnBytes);

    assembly {
      // solidity calls check that a contract actually exists at the destination, so we do the same
      // Note we do this check prior to measuring gas so gasForCallExactCheck (our "cushion")
      // doesn't need to account for it.
      if iszero(extcodesize(target)) {
        mstore(0x0, NO_CONTRACT_SIG)
        revert(0x0, 0x4)
      }

      let g := gas()
      // Compute g -= gasForCallExactCheck and check for underflow
      // The gas actually passed to the callee is _min(gasAmount, 63//64*gas available).
      // We want to ensure that we revert if gasAmount >  63//64*gas available
      // as we do not want to provide them with less, however that check itself costs
      // gas. gasForCallExactCheck ensures we have at least enough gas to be able
      // to revert if gasAmount >  63//64*gas available.
      if lt(g, gasForCallExactCheck) {
        mstore(0x0, NO_GAS_FOR_CALL_EXACT_CHECK_SIG)
        revert(0x0, 0x4)
      }
      g := sub(g, gasForCallExactCheck)
      // if g - g//64 <= gasAmount, revert. We subtract g//64 because of EIP-150
      if iszero(gt(sub(g, div(g, 64)), gasLimit)) {
        mstore(0x0, NOT_ENOUGH_GAS_FOR_CALL_SIG)
        revert(0x0, 0x4)
      }

      // We save the gas before the call so we can calculate how much gas the call used
      let gasBeforeCall := gas()
      // call and return whether we succeeded. ignore return data
      // call(gas,addr,value,argsOffset,argsLength,retOffset,retLength)
      success := call(gasLimit, target, 0, add(payload, 0x20), mload(payload), 0x0, 0x0)
      gasUsed := sub(gasBeforeCall, gas())

      // limit our copy to maxReturnBytes bytes
      let toCopy := returndatasize()
      if gt(toCopy, maxReturnBytes) { toCopy := maxReturnBytes }
      // Store the length of the copied bytes
      mstore(retData, toCopy)
      // copy the bytes from retData[0:_toCopy]
      returndatacopy(add(retData, 0x20), 0x0, toCopy)
    }
    return (success, retData, gasUsed);
  }

  /// @notice Calls target address with exactly gasAmount gas and payload as calldata
  /// or reverts if at least gasLimit gas is not available.
  /// @dev Does not check if target is a contract. If it is not a contract, the low-level
  /// call will still be made and it will succeed.
  /// @dev Ignores the return data, which makes it immune to gas bomb attacks.
  /// @return success whether the call succeeded
  /// @return sufficientGas Whether there was enough gas to make the call
  function _callWithExactGasEvenIfTargetIsNoContract(
    bytes memory payload,
    address target,
    uint256 gasLimit,
    uint16 gasForCallExactCheck
  ) internal returns (bool success, bool sufficientGas) {
    assembly {
      let g := gas()
      // Compute g -= CALL_WITH_EXACT_GAS_CUSHION and check for underflow. We
      // need the cushion since the logic following the above call to gas also
      // costs gas which we cannot account for exactly. So cushion is a
      // conservative upper bound for the cost of this logic.
      if iszero(lt(g, gasForCallExactCheck)) {
        g := sub(g, gasForCallExactCheck)
        // If g - g//64 <= gasAmount, we don't have enough gas. We subtract g//64 because of EIP-150.
        if gt(sub(g, div(g, 64)), gasLimit) {
          // Call and ignore success/return data. Note that we did not check
          // whether a contract actually exists at the target address.
          success := call(gasLimit, target, 0, add(payload, 0x20), mload(payload), 0x0, 0x0)
          sufficientGas := true
        }
      }
    }
    return (success, sufficientGas);
  }
}

// File: @openzeppelin/contracts@5.3.0/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts@5.3.0/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;


// File: @openzeppelin/contracts@5.3.0/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts@5.3.0/interfaces/IERC165.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;


// File: @openzeppelin/contracts@5.3.0/interfaces/IERC1363.sol


// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: @openzeppelin/contracts@5.3.0/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// File: @openzeppelin/contracts@5.3.0/utils/introspection/ERC165Checker.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.20;


/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the ERC-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface.
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC-165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC-165 as per the spec and support of _interfaceId
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     */
    function getSupportedInterfaces(
        address account,
        bytes4[] memory interfaceIds
    ) internal view returns (bool[] memory) {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC-165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = supportsERC165InterfaceUnchecked(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC-165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!supportsERC165InterfaceUnchecked(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC-165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC-165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     *
     * Some precompiled contracts will falsely indicate support for a given interface, so caution
     * should be exercised when using this function.
     *
     * Interface identification is specified in ERC-165.
     */
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeCall(IERC165.supportsInterface, (interfaceId));

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// File: @chainlink/local/src/ccip/CCIPLocalRouter.sol


pragma solidity ^0.8.20;














/// @title CCIPLocalRouter
/// @notice Local-mode router used by `CCIPLocalSimulator`. Mirrors `MockCCIPRouter` from `@chainlink/contracts-ccip`
///         2.0.0 (same ABI, events and behaviour) and additionally applies the CCIP 2.0 finality rules of the OnRamp and
///         OffRamp, so a test that passes locally does not fail on a fork or in production:
///         - the requested finality of `GenericExtraArgsV3` must use a single mode (OnRamp check at send time);
///         - a Faster-Than-Finality message that is not a token-only transfer is only delivered to a receiver whose
///           `getCCVsAndFinalityConfig` allows the requested finality (OffRamp check). Receivers without
///           `IAny2EVMMessageReceiverV2` accept finalized messages only.
/// @dev `MockCCIPRouter.ccipSend` is not virtual, and wrapping it would change `msg.sender`, hence the mirror.
contract CCIPLocalRouter is IRouter, IRouterClient {
    using SafeERC20 for IERC20;
    using ERC165Checker for address;

    error InvalidAddress(bytes encodedAddress);
    error InvalidExtraArgsTag();
    error ReceiverError(bytes err);
    /// @dev Mirrors `OnRamp.TokenReceiverNotAllowed`: `GenericExtraArgsV3.tokenReceiver` is rejected on all EVM lanes
    ///      (`DestChainConfig.tokenReceiverAllowed` is always false for EVM per its NatSpec).
    error TokenReceiverNotAllowed(uint64 destChainSelector);
    /// @dev Mirrors `FeeQuoter.MessageGasLimitTooHigh`.
    error MessageGasLimitTooHigh();
    /// @dev Mirrors `OnRamp.CanOnlySendOneTokenPerMessage`.
    error CanOnlySendOneTokenPerMessage();
    /// @dev Mirrors `OnRamp.CannotSendZeroTokens`.
    error CannotSendZeroTokens();
    /// @dev Mirrors `OffRamp.InvalidOptionalThreshold`.
    error InvalidOptionalThreshold(uint8 wanted, uint256 got);

    event MessageExecuted(bytes32 messageId, uint64 sourceChainSelector, address offRamp, bytes32 calldataHash);
    event MsgExecuted(bool success, bytes retData, uint256 gasUsed);

    uint16 public constant GAS_FOR_CALL_EXACT_CHECK = 5_000;
    uint32 public constant DEFAULT_GAS_LIMIT = 200_000;
    /// @dev Source chain selector stamped on local messages (Ethereum Sepolia), as in `MockCCIPRouter`.
    uint64 internal constant SOURCE_CHAIN_SELECTOR = 16015286601757825753;

    uint256 internal s_mockFeeTokenAmount; //use setFee() to change to non-zero to test fees
    /// @dev Nonce used to guarantee a unique messageId per send, see `ccipSend`.
    uint256 internal s_nonce;

    function routeMessage(
        Client.Any2EVMMessage calldata message,
        uint16 gasForCallExactCheck,
        uint256 gasLimit,
        address receiver
    ) external returns (bool success, bytes memory retData, uint256 gasUsed) {
        return _routeMessage(message, gasForCallExactCheck, gasLimit, receiver);
    }

    function _routeMessage(
        Client.Any2EVMMessage memory message,
        uint16 gasForCallExactCheck,
        uint256 gasLimit,
        address receiver
    ) internal returns (bool success, bytes memory retData, uint256 gasUsed) {
        if (_isTokenOnlyTransfer(message.data.length, gasLimit, receiver)) {
            return (true, "", 0);
        }

        bytes memory data = abi.encodeWithSelector(IAny2EVMMessageReceiver.ccipReceive.selector, message);

        (success, retData, gasUsed) = CallWithExactGas._callWithExactGasSafeReturnData(
            data, receiver, gasLimit, gasForCallExactCheck, Internal.MAX_RET_BYTES
        );

        // Event to assist testing, does not exist on real deployments
        emit MsgExecuted(success, retData, gasUsed);

        // Real router event
        emit MessageExecuted(message.messageId, message.sourceChainSelector, msg.sender, keccak256(data));
        return (success, retData, gasUsed);
    }

    /// @notice Sends the tx locally to the receiver instead of on the destination chain.
    /// @dev Ignores destinationChainSelector
    /// @dev Returns a mock message ID, which is not calculated from the message contents in the
    /// same way as the real message ID.
    function ccipSend(uint64 destinationChainSelector, Client.EVM2AnyMessage calldata message)
        external
        payable
        returns (bytes32)
    {
        if (message.receiver.length != 32) revert InvalidAddress(message.receiver);
        uint256 decodedReceiver = abi.decode(message.receiver, (uint256));
        // We want to disallow sending to address(0) and to precompiles, which exist on address(1) through address(9).
        if (decodedReceiver > type(uint160).max || decodedReceiver < 10) revert InvalidAddress(message.receiver);

        uint256 feeTokenAmount = getFee(destinationChainSelector, message);
        if (message.feeToken == address(0)) {
            if (msg.value < feeTokenAmount) revert InsufficientFeeTokenAmount();
        } else {
            if (msg.value > 0) revert InvalidMsgValue();
            IERC20(message.feeToken).safeTransferFrom(msg.sender, address(this), feeTokenAmount);
        }

        address receiver = address(uint160(decodedReceiver));
        (uint256 gasLimit, bytes4 requestedFinality) = _parseExtraArgs(destinationChainSelector, message.extraArgs);

        // Mirrors OnRamp 2.0: more than one token per message, or a zero-amount token, are rejected at send time.
        if (message.tokenAmounts.length > 1) revert CanOnlySendOneTokenPerMessage();
        if (message.tokenAmounts.length == 1 && message.tokenAmounts[0].amount == 0) revert CannotSendZeroTokens();

        // Unique per send: distinguishes otherwise-identical messages (same sender/receiver/data/dest) that would
        // otherwise collide on `keccak256(abi.encode(message))`.
        bytes32 mockMsgId = keccak256(abi.encode(++s_nonce, msg.sender, destinationChainSelector, message));

        Client.Any2EVMMessage memory executableMsg = Client.Any2EVMMessage({
            messageId: mockMsgId,
            sourceChainSelector: SOURCE_CHAIN_SELECTOR,
            sender: abi.encode(msg.sender),
            data: message.data,
            destTokenAmounts: message.tokenAmounts
        });

        _ensureReceiverAllowsFinality(receiver, executableMsg, gasLimit, requestedFinality);

        for (uint256 i = 0; i < message.tokenAmounts.length; ++i) {
            IERC20(message.tokenAmounts[i].token).safeTransferFrom(msg.sender, receiver, message.tokenAmounts[i].amount);
        }

        (bool success, bytes memory retData,) =
            _routeMessage(executableMsg, GAS_FOR_CALL_EXACT_CHECK, gasLimit, receiver);

        if (!success) revert ReceiverError(retData);

        return mockMsgId;
    }

    /// @dev Same token-only rule as OffRamp 2.0 `_isTokenOnlyTransfer`, which also decides whether the receiver is called.
    function _isTokenOnlyTransfer(uint256 dataLength, uint256 gasLimit, address receiver) internal view returns (bool) {
        return (dataLength == 0 && gasLimit == 0) || receiver.code.length == 0
            || !receiver.supportsInterface(type(IAny2EVMMessageReceiver).interfaceId);
    }

    /// @dev Mirrors OffRamp 2.0 `_getCCVsFromReceiver`, which is called for every message that is not a token-only
    ///      transfer regardless of requested finality (including fully finalized messages, not only Faster-Than-
    ///      Finality ones). Token-only transfers skip it entirely, as the pool enforces finality for them in
    ///      production (pools are not simulated in local mode).
    /// @dev Local mode has no CCV verifiers to query for quorum, so this only reproduces the validation and finality
    ///      parts of `_getCCVsFromReceiver`: duplicate required/optional CCVs and `optionalThreshold >
    ///      optionalCCVs.length` are rejected the same way, and the receiver's allowed finality is enforced.
    /// @dev If `getCCVsAndFinalityConfig` reverts, that revert is bubbled as-is (not wrapped in `ReceiverError`).
    ///      In production the OffRamp does not distinguish this from any other revert during message execution: it
    ///      simply records `ExecutionStateChanged(..., FAILURE, returnData)` with the getter's raw revert data.
    ///      `ReceiverError` is reserved for the narrower case of the receiver's own `ccipReceive` call failing (see
    ///      `_routeMessage`/`OffRamp._callReceiver`), so bubbling here (rather than wrapping) keeps that error
    ///      meaning precise while still failing the local send, consistent with this contract's "fails in
    ///      production" -> "ccipSend reverts locally" mapping.
    function _ensureReceiverAllowsFinality(
        address receiver,
        Client.Any2EVMMessage memory message,
        uint256 gasLimit,
        bytes4 requestedFinality
    ) internal view {
        if (_isTokenOnlyTransfer(message.data.length, gasLimit, receiver)) {
            return;
        }

        bytes4 allowedFinality = FinalityCodec.WAIT_FOR_FINALITY_FLAG;
        if (receiver.supportsInterface(type(IAny2EVMMessageReceiverV2).interfaceId)) {
            (
                address[] memory requiredCCVs,
                address[] memory optionalCCVs,
                uint8 optionalThreshold,
                bytes4 receiverFinality
            ) = IAny2EVMMessageReceiverV2(receiver)
                .getCCVsAndFinalityConfig(message.sourceChainSelector, message.sender);

            CCVConfigValidation._assertNoDuplicates(requiredCCVs);
            CCVConfigValidation._assertNoDuplicates(optionalCCVs);

            if (optionalThreshold > optionalCCVs.length) {
                revert InvalidOptionalThreshold(optionalThreshold, optionalCCVs.length);
            }

            allowedFinality = receiverFinality;
        }
        FinalityCodec._ensureRequestedFinalityAllowed(requestedFinality, allowedFinality);
    }

    /// @param destinationChainSelector Destination chain selector, used only for the `TokenReceiverNotAllowed` error.
    /// @return gasLimit Callback gas limit.
    /// @return requestedFinality `GenericExtraArgsV3.requestedFinalityConfig`, or WAIT_FOR_FINALITY for older tags.
    function _parseExtraArgs(uint64 destinationChainSelector, bytes calldata extraArgs)
        internal
        pure
        returns (uint256 gasLimit, bytes4 requestedFinality)
    {
        // Mirrors FeeQuoter._parseUnvalidatedEVMExtraArgsFromBytes/_parseSVMExtraArgsFromBytes etc.: extraArgs
        // shorter than 4 bytes (including empty) are treated as unset, not as an invalid tag.
        if (extraArgs.length < 4) {
            return (DEFAULT_GAS_LIMIT, FinalityCodec.WAIT_FOR_FINALITY_FLAG);
        }

        bytes4 extraArgsTag = bytes4(extraArgs);
        if (extraArgsTag == ExtraArgsCodec.GENERIC_EXTRA_ARGS_V3_TAG) {
            ExtraArgsCodec.GenericExtraArgsV3 memory decoded = ExtraArgsCodec._decodeGenericExtraArgsV3(extraArgs);
            // Mirrors OnRamp 2.0 `_parseExtraArgsWithDefaults`: tokenReceiver is rejected on all EVM lanes.
            if (decoded.tokenReceiver.length != 0) {
                revert TokenReceiverNotAllowed(destinationChainSelector);
            }
            // OnRamp 2.0 validates the wire shape of the requested finality at send time.
            FinalityCodec._validateRequestedFinality(decoded.requestedFinalityConfig);
            return (decoded.gasLimit, decoded.requestedFinalityConfig);
        } else if (extraArgsTag == Client.GENERIC_EXTRA_ARGS_V2_TAG) {
            return (
                _legacyGasLimit(abi.decode(extraArgs[4:], (Client.GenericExtraArgsV2)).gasLimit),
                FinalityCodec.WAIT_FOR_FINALITY_FLAG
            );
        } else if (extraArgsTag == Client.EVM_EXTRA_ARGS_V1_TAG) {
            return (_legacyGasLimit(abi.decode(extraArgs[4:], (uint256))), FinalityCodec.WAIT_FOR_FINALITY_FLAG);
        }

        revert InvalidExtraArgsTag();
    }

    /// @dev FeeQuoter compares the full uint256 V1/V2 gas limit against the lane's uint32 `maxPerMsgGasLimit` and reverts
    ///      `MessageGasLimitTooHigh`, so a value above uint32 is rejected everywhere; the upstream mock truncated it.
    ///      Local mode has no lane config, so lower lane caps are not enforced.
    function _legacyGasLimit(uint256 gasLimit) internal pure returns (uint256) {
        if (gasLimit > type(uint32).max) revert MessageGasLimitTooHigh();
        return gasLimit;
    }

    /// @notice Always returns true to make sure this check can be performed on any chain.
    function isChainSupported(uint64) external pure returns (bool supported) {
        return true;
    }

    /// @notice Returns an empty array.
    function getSupportedTokens(uint64) external pure returns (address[] memory tokens) {
        return new address[](0);
    }

    /// @notice Returns 0 as the fee is not supported in this mock contract.
    function getFee(uint64, Client.EVM2AnyMessage memory) public view returns (uint256) {
        return s_mockFeeTokenAmount;
    }

    /// @notice Sets the fees returned by getFee but is only checked when using native fee tokens
    function setFee(uint256 feeAmount) external {
        s_mockFeeTokenAmount = feeAmount;
    }

    /// @notice Always returns address(1234567890)
    function getOnRamp(
        uint64 /* destChainSelector */
    )
        external
        pure
        returns (address onRampAddress)
    {
        return address(1234567890);
    }

    /// @notice Always returns true
    function isOffRamp(
        uint64,
        /* sourceChainSelector */
        address /* offRamp */
    )
        external
        pure
        returns (bool)
    {
        return true;
    }
}

// File: @openzeppelin/contracts@4.8.3/token/ERC20/extensions/draft-IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts@4.8.3/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts@4.8.3/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @chainlink/contracts-ccip/contracts/interfaces/IOwner.sol


pragma solidity ^0.8.0;

interface IOwner {
  /// @notice Returns the owner of the contract.
  /// @dev This method is named to match with the OpenZeppelin Ownable contract.
  function owner() external view returns (address);
}

// File: @chainlink/contracts-ccip/contracts/interfaces/IGetCCIPAdmin.sol


pragma solidity ^0.8.0;

interface IGetCCIPAdmin {
  /// @notice Returns the admin of the token.
  /// @dev This method is named to never conflict with existing methods.
  function getCCIPAdmin() external view returns (address);
}

// File: @openzeppelin/contracts@5.3.0/access/IAccessControl.sol


// OpenZeppelin Contracts (last updated v5.3.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted to signal this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

// File: @openzeppelin/contracts@5.3.0/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts@5.3.0/utils/introspection/ERC165.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts@5.3.0/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v5.3.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;




/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` from `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

// File: @chainlink/local/src/ccip/CCIPLocalSimulator.sol


pragma solidity ^0.8.19;











/// @title CCIPLocalSimulator
/// @notice This contract simulates local CCIP (Cross-Chain Interoperability Protocol) operations for testing and development purposes.
/// @dev This contract includes methods to manage supported tokens and configurations for local simulations.
contract CCIPLocalSimulator {
    using SafeERC20 for IERC20;

    /// @notice The unique CCIP Chain Selector constant
    uint64 constant CHAIN_SELECTOR = 16015286601757825753;

    /// @notice The wrapped native token instance
    WETH9 internal immutable i_wrappedNative;

    /// @notice The LINK token instance
    LinkToken internal immutable i_linkToken;

    /// @notice The BurnMintERC677Helper instance for CCIP-BnM token
    BurnMintERC677Helper internal immutable i_ccipBnM;

    /// @notice The BurnMintERC677Helper instance for CCIP-LnM token
    BurnMintERC677Helper internal immutable i_ccipLnM;

    /// @notice The mock CCIP router instance
    CCIPLocalRouter internal immutable i_mockRouter;

    /// @notice The list of supported token addresses
    address[] internal s_supportedTokens;

    error CCIPLocalSimulator__MsgSenderIsNotTokenOwner();
    error CCIPLocalSimulator__RequiredRoleNotFound(address account, bytes32 role, address token);

    /**
     * @notice Constructor to initialize the contract and pre-deployed token instances
     */
    constructor() {
        i_wrappedNative = new WETH9();
        i_linkToken = new LinkToken();
        i_ccipBnM = new BurnMintERC677Helper("CCIP-BnM", "CCIP-BnM");
        i_ccipLnM = new BurnMintERC677Helper("CCIP-LnM", "CCIP-LnM");
        i_mockRouter = new CCIPLocalRouter();

        s_supportedTokens.push(address(i_ccipBnM));
        s_supportedTokens.push(address(i_ccipLnM));
    }

    /**
     * @notice Allows user to support any new token, besides CCIP BnM and CCIP LnM, for cross-chain transfers.
     *         Reverts if token does not implement owner() function.
     *         Reverts if the caller is not the token owner.
     *
     * @param tokenAddress - The address of the token to add to the list of supported tokens.
     */
    function supportNewTokenViaOwner(address tokenAddress) external {
        if (msg.sender != IOwner(tokenAddress).owner()) {
            revert CCIPLocalSimulator__MsgSenderIsNotTokenOwner();
        }
        s_supportedTokens.push(tokenAddress);
    }

    /**
     * @notice Allows user to support any new token, besides CCIP BnM and CCIP LnM, for cross-chain transfers.
     *         Reverts if token does not implement getCCIPAdmin() function.
     *         Reverts if the caller is not the token CCIPAdmin.
     *
     * @param tokenAddress - The address of the token to add to the list of supported tokens.
     */
    function supportNewTokenViaGetCCIPAdmin(address tokenAddress) external {
        if (msg.sender != IGetCCIPAdmin(tokenAddress).getCCIPAdmin()) {
            revert CCIPLocalSimulator__MsgSenderIsNotTokenOwner();
        }
        s_supportedTokens.push(tokenAddress);
    }

    /**
     * @notice Allows user to support any new token, besides CCIP BnM and CCIP LnM, for cross-chain transfers.
     *         The caller must have the DEFAULT_ADMIN_ROLE as defined by the contract itself.
     *         Reverts if the caller is not the admin of the token using OZ's AccessControl DEFAULT_ADMIN_ROLE.
     *
     * @param tokenAddress - The address of the token to add to the list of supported tokens.
     */
    function supportNewTokenViaAccessControlDefaultAdmin(address tokenAddress) external {
        bytes32 defaultAdminRole = AccessControl(tokenAddress).DEFAULT_ADMIN_ROLE();
        if (!AccessControl(tokenAddress).hasRole(defaultAdminRole, msg.sender)) {
            revert CCIPLocalSimulator__RequiredRoleNotFound(msg.sender, defaultAdminRole, tokenAddress);
        }
        s_supportedTokens.push(tokenAddress);
    }

    /**
     * @notice Checks whether the provided `chainSelector` is supported by the simulator.
     *
     * @param chainSelector - The unique CCIP Chain Selector.
     *
     * @return supported - Returns true if `chainSelector` is supported by the simulator.
     */
    function isChainSupported(uint64 chainSelector) public pure returns (bool supported) {
        supported = chainSelector == CHAIN_SELECTOR;
    }

    /**
     * @notice Gets a list of token addresses that are supported for cross-chain transfers by the simulator.
     *
     * @param chainSelector - The unique CCIP Chain Selector.
     *
     * @return tokens - Returns a list of token addresses that are supported for cross-chain transfers by the simulator.
     */
    function getSupportedTokens(uint64 chainSelector) external view returns (address[] memory tokens) {
        if (!isChainSupported(chainSelector)) {
            return new address[](0);
        }

        tokens = s_supportedTokens;
    }

    /**
     * @notice Requests LINK tokens from the faucet. The provided amount of tokens are transferred to provided destination address.
     *
     * @param to - The address to which LINK tokens are to be sent.
     * @param amount - The amount of LINK tokens to send.
     *
     * @return success - Returns `true` if the transfer of tokens was successful, otherwise `false`.
     */
    function requestLinkFromFaucet(address to, uint256 amount) external returns (bool success) {
        success = i_linkToken.transfer(to, amount);
    }

    /**
     * @notice Returns configuration details for pre-deployed contracts and services needed for local CCIP simulations.
     *
     * @return chainSelector_ - The unique CCIP Chain Selector.
     * @return sourceRouter_  - The source chain Router contract.
     * @return destinationRouter_ - The destination chain Router contract.
     * @return wrappedNative_ - The wrapped native token which can be used for CCIP fees.
     * @return linkToken_ - The LINK token.
     * @return ccipBnM_ - The ccipBnM token.
     * @return ccipLnM_ - The ccipLnM token.
     */
    function configuration()
        public
        view
        returns (
            uint64 chainSelector_,
            IRouterClient sourceRouter_,
            IRouterClient destinationRouter_,
            WETH9 wrappedNative_,
            LinkToken linkToken_,
            BurnMintERC677Helper ccipBnM_,
            BurnMintERC677Helper ccipLnM_
        )
    {
        return (
            CHAIN_SELECTOR,
            IRouterClient(address(i_mockRouter)),
            IRouterClient(address(i_mockRouter)),
            i_wrappedNative,
            i_linkToken,
            i_ccipBnM,
            i_ccipLnM
        );
    }
}

// File: contracts/chainlink-local/CCIPLocalSimulator.sol


pragma solidity ^0.8.19;

// solhint-disable no-unused-import
