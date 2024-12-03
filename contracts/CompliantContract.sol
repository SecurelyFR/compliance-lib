// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {ICompliance} from "./interfaces/ICompliance.sol";

/// @title Securely's Compliance Library
/// @author Securely.id
/// @notice This contract provides tools to enforce compliance rules
/// @dev This abstract contract provides five functions to enforce compliance rules
abstract contract CompliantContract {
    /// @notice The Securely compliance contract address. It must be set before using the require functions.
    /// @dev This contract is set by the owner and must implement the ICompliance interface.
    /// @dev Multiple dapps can share the same compliance contract.
    ICompliance public compliance;

    /// @dev Both a constructor and init functions are defined, so that this contract can be easily upgradeable or not
    constructor(address compliance_) {
        __CompliantContract_init(compliance_);
    }

    function __CompliantContract_init(address compliance_) internal {
        __CompliantContract_init_unchained(compliance_);
    }

    function __CompliantContract_init_unchained(address compliance_) internal {
        require(address(compliance) == address(0), "Already initialized");
        compliance = ICompliance(compliance_);
    }

    /// @notice Requires compliance for a generic call
    /// @param value The value parameter associated to the transaction
    /// @param data An optional data parameter associated to the transaction
    function requireGenericCallCompliance(uint256 value, bytes memory data) internal {
        compliance.requireGenericCallCompliance(msg.sig, msg.sender, value, data);
    }

    /// @notice Requires compliance for a native Eth transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    function requireEthTransferCompliance(address from, address to, uint256 value) internal {
        compliance.requireEthTransferCompliance(msg.sig, from, to, value);
    }

    /// @notice Requires compliance for a native Eth transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the
    ///             transaction. e.g. an invoice ID
    function requireEthTransferWithDataCompliance(address from, address to, uint256 value, bytes memory data) internal {
        compliance.requireEthTransferWithDataCompliance(msg.sig, from, to, value, data);
    }

    /// @notice Requires compliance for an ERC20 transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param token The ERC20 token address
    /// @param value The value parameter associated to the transaction
    function requireErc20TransferCompliance(address from, address to, address token, uint256 value) internal {
        compliance.requireErc20TransferCompliance(msg.sig, from, to, token, value);
    }

    /// @notice Requires compliance for an ERC20 transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param token The ERC20 token address
    /// @param value The value parameter associated to the transaction
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the
    ///             transaction. e.g. an invoice ID
    function requireErc20TransferWithDataCompliance(
        address from,
        address to,
        address token,
        uint256 value,
        bytes memory data
    ) internal {
        compliance.requireErc20TransferWithDataCompliance(msg.sig, from, to, token, value, data);
    }
}
