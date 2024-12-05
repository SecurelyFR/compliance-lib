// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/// @title Securely's Compliance interface
/// @author Securely.id
/// @notice Simplified Compliance interface for compliance checks
/// @dev This interface is used by the CompliantContract to interact with Securely's Compliance contract
interface ICompliance {
    /// @member token The ERC20 token used. Use 0x0 for native ethers
    /// @member value The amount of tokens/wei
    struct Value {
        address token;
        uint256 value;
    }

    /// @notice Requires compliance for a transaction
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param screening A list of addresses to screen
    /// @dev The first screening address is a source address
    /// @dev The optional second screening address is a destination address
    /// @dev There might be more addresses, labeled in the policy as SCREENING3, SCREENING4, ...
    /// @param values An array of token/value to check in the policy
    function requireCompliance(
        address sender,
        uint256 value,
        bytes calldata data,
        address[] memory screening,
        Value[] memory values
    ) external;

    /// @notice Requires compliance for a transaction
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param screening A list of addresses to screen
    /// @dev The first screening address is a source address
    /// @dev The optional second screening address is a destination address
    /// @dev There might be more addresses, labeled in the policy as SCREENING3, SCREENING4, ...
    function requireCompliance(address sender, uint256 value, bytes calldata data, address[] memory screening) external;

    /// @notice Requires compliance for a transaction
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param values An array of token/value to check in the policy
    function requireCompliance(address sender, uint256 value, bytes calldata data, Value[] memory values) external;

    /// @notice Requires compliance for a transaction
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    function requireCompliance(address sender, uint256 value, bytes calldata data) external;
}
