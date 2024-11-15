// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC20} from "./interfaces/IERC20.sol";
import {ICompliance} from "./interfaces/ICompliance.sol";

/// @title Securely's Compliance Library
/// @author Securely.id
/// @notice This contract provides tools to enforce compliance rules
/// @dev This abstract contract provides five modifiers and a few internal functions to enforce compliance rules
abstract contract CompliantContract {
    /// @notice The Securely compliance contract address. It must be set before using the modifiers.
    /// @dev This contract is set by the owner and must implement the ICompliance interface.
    /// @dev Multiple dapps can share the same compliance contract.
    ICompliance public compliance;

    constructor(address compliance_) {
        __CompliantContract_init(compliance_);
    }
    function __CompliantContract_init(address compliance_) internal {
        require(address(compliance) == address(0), "Already initialized");
        compliance = ICompliance(compliance_);
    }

    /// @notice Requires compliance for a generic call
    /// @param value The value parameter associated to the transaction
    /// @param data An optional data parameter associated to the transaction
    function requireGenericCallCompliance(uint256 value, bytes memory data) internal returns (bytes32) {
        return compliance.consumeCompliance(compliance.computeGenericCallPartialHash(block.chainid, msg.sig, msg.sender, value, data));
    }

    /// @notice Requires compliance for a native Eth transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    function requireEthTransferCompliance(address from, address to, uint256 value) internal returns (bytes32) {
        payFees(from, address(0), value);
        return compliance.consumeCompliance(compliance.computeEthTransferPartialHash(block.chainid, msg.sig, from, to, value));
    }

    /// @notice Requires compliance for a native Eth transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the transaction. e.g. an invoice ID
    function requireEthTransferWithDataCompliance(address from, address to, uint256 value, bytes memory data) internal returns (bytes32) {
        payFees(from, address(0), value);
        return compliance.consumeCompliance(compliance.computeEthTransferWithDataPartialHash(block.chainid, msg.sig, from, to, value, data));
    }

    /// @notice Requires compliance for an ERC20 transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param token The ERC20 token address
    /// @param value The value parameter associated to the transaction
    function requireErc20TransferCompliance(address from, address to, address token, uint256 value) internal returns (bytes32) {
        payFees(from, token, value);
        compliance.consumeCompliance(compliance.computeErc20TransferPartialHash(block.chainid, msg.sig, from, to, token, value));
    }

    /// @notice Requires compliance for an ERC20 transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param token The ERC20 token address
    /// @param value The value parameter associated to the transaction
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the transaction. e.g. an invoice ID
    function requireErc20TransferAndDataCompliance(address from, address to, address token, uint256 value, bytes memory data) internal returns (bytes32) {
        payFees(from, token, value);
        return compliance.consumeCompliance(compliance.computeErc20TransferWithDataPartialHash(block.chainid, msg.sig, from, to, token, value, data));
    }

    function payFees(address from, address currency, uint256 value) private {
        uint256 fee = value - compliance.getNetAmount(value);
        if (currency == address(0)) {
            compliance.payFees{value: fee}(currency, fee);
        } else {
            bool sent = IERC20(currency).transferFrom(from, address(compliance), fee);
            require(sent, "Unable to transfer tokens");
            compliance.payFees(currency, fee);
        }
    }
}
