// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {CompliantContract} from "../CompliantContract.sol";

/// @title CompliantFunds
/// @author Securely.id
/// @notice This contract serves as a base for compliant funds management
abstract contract CompliantFunds is CompliantContract {
    /// @notice The default destination for payments
    address payable public defaultDestination;

    /// @notice A mapping tracking the total amounts going through this contract
    /// @dev mapping(receiver => (sender => (currency => amount)))
    /// @dev Using sender = 0x0 to wildcard sender.
    /// @dev Using currency = 0x0 for native ethers.
    mapping(address => mapping(address => mapping(address => uint256))) private _payedAmounts;

    /// @notice Event emitted when a compliant payment is made
    event CompliantPayment(
        address indexed sender,
        address indexed destination,
        address indexed currency,
        uint256 amount,
        bytes32 complianceFullHash
    );

    constructor() {
        defaultDestination = payable(msg.sender);
    }

    /// @notice Returns the amount of tokens/ethers payed to a recipient
    /// @param destination The recipient address
    /// @param sender The sender address. Use 0x0 to wildcard sender
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    function amountPayed(
        address destination,
        address sender,
        address currency
    ) public view returns(uint256) {
        return _payedAmounts[destination][sender][currency];
    }

    /// @notice Registers a compliant payment
    /// @param destination The recipient address
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param netAmount The net amount payed
    function _payed(
        address destination,
        address currency,
        uint256 netAmount
    ) internal requiresComplianceActivated(true) {
        _payedAmounts[destination][msg.sender][currency] += netAmount;
        _payedAmounts[destination][address(0)][currency] += netAmount;
        emit CompliantPayment(msg.sender, destination, currency, netAmount, complianceFullHash);
    }
}
