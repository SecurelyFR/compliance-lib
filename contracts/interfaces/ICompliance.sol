// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/// @title Securely's Compliance interface
/// @author Securely.id
/// @notice Simplified Compliance interface for compliance checks
/// @dev This interface is used by the CompliantContract to interact with Securely's Compliance contract
interface ICompliance {
    /// @notice Requires compliance for a generic call
    /// @param sig The msg.sig of the transaction
    /// @param from The msg.sender of the transaction
    /// @param value The value parameter associated to the transaction
    /// @param data An optional data parameter associated to the transaction
    function requireGenericCallCompliance(bytes4 sig, address from, uint256 value, bytes memory data) external;

    /// @notice Requires compliance for a native Eth transfer
    /// @param sig The msg.sig of the transaction
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    function requireEthTransferCompliance(bytes4 sig, address from, address to, uint256 value) external;

    /// @notice Requires compliance for a native Eth transfer
    /// @param sig The msg.sig of the transaction
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the
    ///             transaction. e.g. an invoice ID
    function requireEthTransferWithDataCompliance(
        bytes4 sig,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) external;

    /// @notice Requires compliance for an ERC20 transfer
    /// @param sig The msg.sig of the transaction
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param token The ERC20 token address
    /// @param value The value parameter associated to the transaction
    function requireErc20TransferCompliance(
        bytes4 sig,
        address from,
        address to,
        address token,
        uint256 value
    ) external;

    /// @notice Requires compliance for an ERC20 transfer
    /// @param sig The msg.sig of the transaction
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param token The ERC20 token address
    /// @param value The value parameter associated to the transaction
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the
    ///             transaction. e.g. an invoice ID
    function requireErc20TransferWithDataCompliance(
        bytes4 sig,
        address from,
        address to,
        address token,
        uint256 value,
        bytes memory data
    ) external;
}
