// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "@openzeppelin/contracts/utils/Counters.sol";


/**
 * @dev Implementation of the ERC20 Epochs extension.
 *
 * Adds the Epoch related features, which provides fully ERC20 supported interfaces
 * with current epoch, and history data via changing ERC20 default {_balances} structure.
 */
contract ERC20Epochs is IERC20, IERC20Metadata {
    using Counters for Counters.Counter;

    // Epoch Events
    event TransferEpoch(
        uint256 indexed epoch,
        address indexed from,
        address indexed to,
        uint256 value
    );
    event ApprovalEpoch(
        uint256 indexed epoch,
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event EpochCreated(
        uint256 indexed epoch,
        address indexed creator
    );
    event EpochEnded(
        uint256 indexed epoch,
        uint256 totalSupply
    );

    mapping(uint256 => mapping(address => uint256)) private _balances;
    mapping(uint256 => mapping(address => mapping(address => uint256))) private _allowances;

    mapping(uint256 => uint256) private _totalSupply;
    string private _name;
    string private _symbol;

    Counters.Counter private _epoch;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply[_epoch.current()];
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[_epoch.current()][account];
    }

    function epoch() public view virtual returns (uint256) {
        return _epoch.current();
    }

    function createEpoch() public virtual returns (uint256) {
        address creator = msg.sender;
        uint256 currentEpoch = _epoch.current();
        uint256 currentTotalSupply = totalSupply();
        _epoch.increment();

        emit EpochEnded(currentEpoch, currentTotalSupply);
        emit EpochCreated(_epoch.current(), creator);

        return _epoch.current();
    }

    // ERC20 Override

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[_epoch.current()][owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_epoch.current()][owner][spender] = amount;
        emit Approval(owner, spender, amount);
        emit ApprovalEpoch(_epoch.current(), owner, spender, amount);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[_epoch.current()][from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[_epoch.current()][from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[_epoch.current()][to] += amount;
        }

        emit Transfer(from, to, amount);
        emit TransferEpoch(_epoch.current(), from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply[_epoch.current()] += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[_epoch.current()][account] += amount;
        }
        emit Transfer(address(0), account, amount);
        emit TransferEpoch(_epoch.current(), address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}