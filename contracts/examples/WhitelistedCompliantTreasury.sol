// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20Securely} from "contracts/interfaces/IERC20Securely.sol";
import {CompliantFunds} from "./CompliantFunds.sol";

/// @title WhitelistedCompliantTreasury
/// @author Securely.id
/// @notice This contract is a vault ensuring all funds going in and out are compliant. Whitelisted addresses can bypass the check.
contract WhitelistedCompliantTreasury is CompliantFunds, AccessControl {
    /// @notice The whitelisted addresses role
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    /// @dev mapping(receiver => currency => amount)
    /// @dev Using currency = 0x0 for native ethers.
    mapping(address => mapping(address => uint256)) private _treasury;

    /// @dev For easy history tracking
    event Withdrawal(address indexed withdrawer, address indexed currency, uint256 amount);

    constructor(address compliance) CompliantFunds(compliance) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(WHITELISTED_ROLE, msg.sender);
    }

    /// @notice Pay native ethers to a recipient
    /// @param destination The recipient address
    function payEthers(
        address payable destination
    ) external payable enableCompliance(!_isWhitelisted()) requiresEthTransferCompliance(msg.sender, destination, msg.value) {
        _pay(destination, address(0), msg.value);
    }

    /// @notice Pay ERC20 tokens to a recipient
    /// @param destination The recipient address
    /// @param token The ERC20 token address
    /// @param amount The amount of tokens to pay
    function payTokens(
        address destination,
        address token,
        uint256 amount
    ) external enableCompliance(!_isWhitelisted()) requiresErc20TransferCompliance(msg.sender, destination, token, amount) {
        require(token != address(0), "Invalid token address");
        _pay(destination, token, amount);
    }

    /// @notice Withdraw your funds from the treasury
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of tokens to withdraw. Use 0 to withdraw all
    function withdraw(address currency, uint256 amount) external {
        transferTo(msg.sender, currency, amount);
    }

    /// @notice Get the treasury balance of an account
    /// @param account The account address
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @return The balance of the account
    function balanceOf(address account, address currency) external view returns (uint256) {
        return _treasury[account][currency];
    }

    /// @notice Transfer funds from the treasury to a recipient
    /// @param destination The recipient address
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of tokens to transfer. Use 0 to transfer all
    function transferTo(
        address destination,
        address currency,
        uint256 amount
    ) public enableCompliance(true) requiresErc20TransferCompliance(address(this), destination, currency, amount) {
        require(!_isWhitelisted(), "Whitelisted addresses need to use the payXXX functions to transfer funds");
        require(amount <= _treasury[msg.sender][currency], "Insufficient funds in the treasury");
        if (amount == 0)
            amount = _treasury[msg.sender][currency];
        require(amount > 0, "Impossible to transfer 0 funds");

        _treasury[msg.sender][currency] -= amount;
        emit Withdrawal(msg.sender, currency, amount);
        _transferTo(destination, currency, amount);
    }

    /// @dev Actually transfer funds to a recipient
    /// @param destination The recipient address
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of tokens to transfer
    function _transferTo(address destination, address currency, uint256 amount) private {
        uint256 netAmount = amount;
        if (!_isWhitelisted())
            netAmount = compliance.getNetAmount(amount);
        bool sent;
        if (currency == address(0))
            (sent, ) = destination.call{value: netAmount}("");
        else
            sent = IERC20(currency).transfer(destination, netAmount);
        require(sent, "Unable to transfer funds");
    }

    /// @dev Pay funds to a recipient
    /// @param destination The recipient address
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of tokens to pay
    function _pay(address destination, address currency, uint256 amount) private {
        uint256 netAmount = amount;
        if (_isWhitelisted()) {
            require(netAmount <= _treasury[msg.sender][currency], "Insufficient compliant funds");
            _treasury[msg.sender][currency] -= netAmount;
            emit Withdrawal(msg.sender, currency, netAmount);
        } else {
            netAmount = compliance.getNetAmount(amount);
        }
        require (netAmount > 0, "Impossible to pay 0 funds");
        if (destination == address(0))
            destination = defaultDestination;
        if (currency != address(0)) {
            bool sent = IERC20(currency).transferFrom(msg.sender, address(this), netAmount);
            require(sent, "Unable to transfer tokens");
        }
        _payed(destination, currency, netAmount);
        _treasury[destination][currency] += netAmount;
        if (hasRole(WHITELISTED_ROLE, destination))
            _transferTo(destination, currency, netAmount);
    }

    /// @dev Check if the sender is whitelisted
    /// @return true if the sender is whitelisted
    function _isWhitelisted() private view returns (bool) {
        return hasRole(WHITELISTED_ROLE, msg.sender);
    }
}
