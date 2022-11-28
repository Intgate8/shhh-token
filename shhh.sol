// SPDX-License-Identifier: MIT
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
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
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}

/**
 * @dev String operations.
 */
library Strings {

    /**
    * Converts a `uint256` to its ASCII `string`
    */    
    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
         if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }        

    /*
    * converts a `address` to string
    */
    function toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }

    return string(abi.encodePacked("0x",s));
    }

}
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev Emitted when the pause is triggered by `account` but date is out of rank.
     */
    event PauseFailed(string _message);

    bool private _paused;

    uint256 public maxPauseDate = 1648763999; //2022-03-31 23:59:59

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     * Contract can not be paused after 2022-03-31
     */
    function paused() public view virtual returns (bool) {
        if(block.timestamp>maxPauseDate) {
            return false;
        }
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        if(block.timestamp>maxPauseDate) {
            _paused = false;
            emit PauseFailed('Contract can not be paused. Date out of range');
        }else {
            _paused = true;
            emit Paused(_msgSender());
        }
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;

    using Strings for address;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    //check owner
    event OwnerCheck(address sender, address owner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        //emit OwnerCheck(msg.sender, owner);
        require(msg.sender == owner, string(abi.encodePacked("Caller is not owner ", msg.sender.toAsciiString(),' ', owner.toAsciiString())));
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

contract ShhhToken is ERC20, Owner, Pausable {

    using SafeMath for uint256;
    using Strings for uint256;
    using Strings for address;

    uint tokenSupply = 100000000;
    bool isInitedDistribution;

    // event for show airdrop adresses action
    event ListOfAddresses(string addresses, string amounts);

    // event for show access adresses action
    event ListOfAccessAddresses(string addresses);

    // event triggered when new address was added or address was deleted
    event AccessAddressAction(address _address);

   // airdops addresses
    struct AirdopBeneficiary {
        address Address;
        uint256 amount;
        uint256 created;
    }
    mapping(uint256 => AirdopBeneficiary) public airdropsBeneficiary;
    uint256 public airdropsMembers = 0;

    address[] internal accessContract;

    // Token Distribution
    uint256 public airdropTotalAmount         = 3000000000000000000000000;  //3%
    uint256 public liquidityTotalAmount       = 12500000000000000000000000; //12.5%
    uint256 public idoTotalAmount             = 2000000000000000000000000;  //2%
    uint256 public publicSaleTotalAmount      = 3000000000000000000000000;  //3%
    uint256 public treasureTotalAmount        = 10000000000000000000000000; //10%
    uint256 public communityTotalAmount       = 10000000000000000000000000; //10%
    uint256 public marketingTotalAmount       = 20000000000000000000000000; //20%
    uint256 public teamTotalAmount            = 15000000000000000000000000;  //1.5%
    uint256 public seedTotalAmount            = 15000000000000000000000000;  //1.5%
    uint256 public advisorsTotalAmount        = 4500000000000000000000000;  //4.5%
    uint256 public developmentFundTotalAmount = 5000000000000000000000000;  //5%

    address public airdropAddr         = 0x2929aa943066a205F3d19930dACd069EF67c1ef6;
    address public liquidityAddr       = 0xcB6c850829e027376BE8eEF331d4E7Ed12fb9ccE;
    address public idoAddr             = 0xA0f9654CF9d1964dE43F2D4E1e63a93455fb68e7;
    address public publicSaleAddr      = 0xFc9d88858ca96dC36465fF96aeC8665ee06b854D;
    address public treasureAddr        = 0x001B238850EeEcC1fA31EbD4301B1F89208e5F85;
    address public communityAddr       = 0x85FbD7D25758F3486E08281f08c88a44C81B259B;
    address public marketingAddr       = 0x770c8708E314D04FeDAf5d706dFE71D813979491;
    address public teamAddr            = 0x3786Ec2BFDcA4A71c1127088a937996240558238;
    address public seedAddr            = 0x9Fd6450cD8EcBcF94ba680e286e844f37D4b0128;
    address public advisorsAddr        = 0x2f220691e6aC7D1b993bd0d9337b32C3EF7899dF;
    address public developmentFundAddr = 0x69cAD3E4313b5bf03DaEaB67C9eB0f0f4Bf6Afda;

    constructor () ERC20("Shhh.zone token", "SHHH") {
        _mint(msg.sender, tokenSupply * (10 ** uint256(decimals())));
        isInitedDistribution = false;
    }

    function transfer(address _to, uint256 _value) whenNotPaused public override returns (bool) {
        if(isAccessContractExists(_msgSender())) {
            _transfer(_msgSender(),_to, _value);
        }else {
            uint256 toBurn = _value.div(100).mul(2);
            _transfer(_msgSender(),_to, _value-toBurn);
            _burn(_msgSender(),toBurn);
        }
        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public override returns (bool) {
        uint256 currentAllowance = allowance(_from,_msgSender());
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= _value, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(_from, _msgSender(), currentAllowance - _value);
            }
        }
        if(isAccessContractExists(_msgSender())) {
            _transfer(_from,_to, _value);
        }else {
            uint256 toBurn = _value.div(100).mul(2);
            _transfer(_from,_to, _value-toBurn);
            _burn(_from,toBurn);
        }
        return true;
    }

    function startDistribution() isOwner public payable {
        require(isInitedDistribution == false, "Distribution already inited");

        _transfer(_msgSender(), airdropAddr, airdropTotalAmount);
        _transfer(_msgSender(), liquidityAddr, liquidityTotalAmount);
        _transfer(_msgSender(), idoAddr, idoTotalAmount);
        _transfer(_msgSender(), publicSaleAddr, publicSaleTotalAmount);
        _transfer(_msgSender(), treasureAddr, treasureTotalAmount);
        _transfer(_msgSender(), communityAddr, communityTotalAmount);
        _transfer(_msgSender(), marketingAddr, marketingTotalAmount);
        _transfer(_msgSender(), teamAddr, teamTotalAmount);
        _transfer(_msgSender(), seedAddr, seedTotalAmount);
        _transfer(_msgSender(), advisorsAddr, advisorsTotalAmount);
        _transfer(_msgSender(), developmentFundAddr, developmentFundTotalAmount);

        isInitedDistribution = true;
    }

    /*
        Airdrop function. Check if address already exists
    */
    function isExistsAirdropAddress(address _address) public view returns(bool) {
        for (uint256 i = 0; i < airdropsMembers; i++)
        {
            if(airdropsBeneficiary[i].Address == _address) {
                return true;
            }
        }
        return false;
    }

    /*
        Airdrop function. Add beneficiary address and amount
    */
    function addAirDropBeneficiary(address _address, uint256 _amount) isOwner public {
        require(!isExistsAirdropAddress(_address), "Airdrop to this address already added");

        airdropsBeneficiary[airdropsMembers] = AirdopBeneficiary({
            Address : _address,
            amount : _amount,
            created : block.timestamp
        });
        ++airdropsMembers;
    }

    /*
        Airdrop function. Add beneficiary address and amount
    */
    function addAirDropMultiBeneficiary(AirdopBeneficiary[] memory _addresses) isOwner public {
        for(uint256 i = 0; i < _addresses.length; ++i) {
            if(!isExistsAirdropAddress(_addresses[i].Address)) {
                addAirDropBeneficiary(_addresses[i].Address,_addresses[i].amount);
            }
        }
    }

    /*
        Airdrop function. Clear beneficiary airdrop list
    */
    function clearAirDropBeneficiary() isOwner public {

            for (uint256 i = 0; i < airdropsMembers; i++)
            {
                delete airdropsBeneficiary[i];
            }
            airdropsMembers = 0;
    }

    /*
        Airdrop function. Clear beneficiary airdrop list
    */
    function getAirDropBeneficiaryAtPos(uint256 i) isOwner private view returns(AirdopBeneficiary memory) {
        require(airdropsBeneficiary[i].amount > 0);
        return airdropsBeneficiary[i];
    }


    /*
        Airdrop function. Run airdrop for added addresses
    */
    function airDrop() whenNotPaused isOwner public payable {
        for (uint256 i = 0; i < airdropsMembers; i++)
        {
        _transfer(_msgSender(), airdropsBeneficiary [i].Address,airdropsBeneficiary [i].amount);
        delete airdropsBeneficiary[i];
        }
        airdropsMembers = 0;
    }

    /*
    *  Airdrop function. Listing of added addresses
    */
    function showAirdropAddresses() isOwner public {
        string memory accounts;
        string memory amounts;
        for (uint256 i = 0; i < airdropsMembers; i++) {
            accounts = string(abi.encodePacked(accounts, getAirDropBeneficiaryAtPos(i).Address.toAsciiString(),' '));
            amounts = string(abi.encodePacked(amounts, getAirDropBeneficiaryAtPos(i).amount.uint2str(),' '));
        }
        emit ListOfAddresses(accounts, amounts);
    }

    /*
    *  Checking if address already added to the list of access contract
    */
    function isAccessContractExists(address _address) private view returns (bool) {
        for(uint256 i = 0; i<accessContract.length; ++i) {
            if(_address == accessContract[i]) {
                return true;
            }
        }
        return false;
    }

    /*
    *  Adding new address of contract who will have extra credentials
    */
    function addAccessContract(address _address) isOwner public {
        require(isAccessContractExists(_address) == false, 'Address already added');
        accessContract.push(_address);
        emit AccessAddressAction(_address);
    }

    /*
    *  Removal of the contract address that had additional credentials
    */
    function deleteAccessContract(address _address) isOwner public {
        require(isAccessContractExists(_address) == true, 'Address not exists');
        for(uint256 i =0; i < accessContract.length; ++i) {
            if(accessContract[i] == _address) {
                accessContract[i] = accessContract[accessContract.length-1];
                accessContract.pop();
            }
        }
        emit AccessAddressAction(_address);
    }

    /*
    *  Adding aproove from passed address to address. 
    *  Function allowed only for contracts whose addresses have been added to the accessList
    */
    function approveFrom(address _from, uint256 _amount) public {
        require(isAccessContractExists(msg.sender) == true, 'Your address not allowed to run this action');
        _approve(_from, _msgSender(), _amount);
    }

    /**
     * Increases the allowance granted to `spender` by the `_from` address.
     * Function allowed only for contracts whose addresses have been added to the accessList
     */
    function increaseAllowanceFrom(address _from, uint256 addedValue) public virtual returns (bool) {
        require(isAccessContractExists(msg.sender) == true, 'Your address not allowed to run this action');
        _approve(_from, _msgSender(), allowance(_from, _msgSender()) + addedValue);
        return true;
    }

    /**
     * Increases the allowance granted to `spender` by the `_from` address.
     * Function allowed only for contracts whose addresses have been added to the accessList
     */
    function decreaseAllowanceFrom(address _from, uint256 subtractedValue) public virtual returns (bool) {
        require(isAccessContractExists(msg.sender) == true, 'Your address not allowed to run this action');
        uint256 currentAllowance = allowance(_from,_msgSender());
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_from, _msgSender(), currentAllowance - subtractedValue);
        }

        return true;
    }

    /*
    *  Listing of access addresses
    */
    function showAccessAddresses() isOwner public {
        string memory addresses;
        for (uint256 i = 0; i < accessContract.length; i++) {
            addresses = string(abi.encodePacked(addresses, accessContract[i].toAsciiString(),' '));
        }
        emit ListOfAccessAddresses(addresses);
    }

    /*
    * Setting the pause status of contract
    * Setting pause to "true" is available due 2022-03-31
    */
    function setPause(bool state) isOwner public {
        if(state) {
            super._pause();
        } else {
            super._unpause();
        }
    }
}
