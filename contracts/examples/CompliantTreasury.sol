// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC20Securely} from "contracts/interfaces/IERC20Securely.sol";
import {CompliantFunds} from "./CompliantFunds.sol";

/// @title CompliantTreasury
/// @author Securely.id
/// @notice This contract is a vault ensuring all funds going in and out are compliant
contract CompliantTreasury is CompliantFunds {
    /// @dev mapping(receiver => currency => amount)
    /// @dev Using currency = 0x0 for native ethers.
    mapping(address => mapping(address => uint256)) private _treasury;

    /// @dev For easy history tracking
    event Withdrawal(address indexed withdrawer, address indexed currency, uint256 amount);

    constructor(address compliance) CompliantFunds(compliance) {}

    /// @notice Pay native ethers to a recipient
    /// @param destination The recipient address
    function payEthers(
        address payable destination
    ) external payable {
        requireEthTransferCompliance(msg.sender, destination, msg.value);
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
    ) external {
        requireErc20TransferCompliance(msg.sender, destination, token, amount);
        _pay(destination, token, amount);
    }

    /// @notice Withdraw your funds from the treasury
    /// @param amount The amount of tokens to withdraw. Use 0 to withdraw all
    /// @param tokenAddr The ERC20 token address. Use 0x0 for native ethers
    function withdraw(uint256 amount, address tokenAddr) external {
        transferTo(msg.sender, amount, tokenAddr);
    }

    /// @notice Transfer funds from the treasury to a recipient
    /// @param destination The recipient address
    /// @param amount The amount of tokens to transfer. Use 0 to transfer all
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    function transferTo(address destination, uint256 amount, address currency) public {
        require(amount <= _treasury[msg.sender][currency]);
        if (amount == 0) {
            amount = _treasury[msg.sender][currency];
        }
        require(amount > 0);

        _treasury[msg.sender][currency] -= amount;
        emit Withdrawal(msg.sender, currency, amount);
        bool sent;
        if (currency == address(0))
            (sent, ) = destination.call{value: amount}("");
        else
            sent = IERC20Securely(currency).transfer(destination, amount);
        require(sent, "Unable to transfer funds");
    }

    /// @dev Pay funds to a recipient
    /// @param destination The recipient address
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of tokens to pay
    function _pay(address destination, address currency, uint256 amount) private {
        uint256 netAmount = compliance.getNetAmount(amount);
        require (netAmount > 0);
        if (destination == address(0))
            destination = defaultDestination;
        if (currency != address(0)) {
            bool sent = IERC20Securely(currency).transferFrom(msg.sender, address(this), netAmount);
            require(sent, "Unable to transfer tokens");
        }
        _payed(destination, currency, netAmount);
        _treasury[destination][currency] += netAmount;
    }
}
