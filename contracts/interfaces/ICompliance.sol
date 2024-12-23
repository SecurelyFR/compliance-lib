// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/// @title Securely's Compliance interface
/// @author Securely.id
/// @notice Simplified Compliance interface for compliance checks
/// @dev This interface is used by the CompliantContract to interact with Securely's Compliance contract
interface ICompliance {
    /// @member token The ERC20 token used. Use 0x0 for native ethers
    /// @member value The amount of tokens/wei
    struct Amount {
        address token;
        uint256 value;
    }

    /// @notice Checks compliance for a transaction
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param wallets An array of addresses that will be verified by the policy
    /// @dev The first screening address is a source address
    /// @dev The optional second screening address is a destination address
    /// @dev There might be more addresses, labeled in the policy as WALLET3, WALLET4, ...
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function checkComplianceStatus(
        address sender,
        uint256 value,
        bytes calldata data,
        address[] memory wallets,
        Amount[] memory amounts
    ) external view returns (bool isCompliant);

    /// @notice Checks compliance for a transaction
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param wallets An array of addresses that will be verified by the policy
    /// @dev The first screening address is a source address
    /// @dev The optional second screening address is a destination address
    /// @dev There might be more addresses, labeled in the policy as WALLET3, WALLET4, ...
    function checkComplianceStatus(
        address sender,
        uint256 value,
        bytes calldata data,
        address[] memory wallets
    ) external view returns (bool isCompliant);

    /// @notice Checks compliance for a transaction
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function checkComplianceStatus(
        address sender,
        uint256 value,
        bytes calldata data,
        Amount[] memory amounts
    ) external view returns (bool isCompliant);

    /// @notice Checks compliance for a transaction
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    function checkComplianceStatus(
        address sender,
        uint256 value,
        bytes calldata data
    ) external view returns (bool isCompliant);

    /// @notice Requires compliance for a transaction
    /// @dev reverts if the transaction is not compliant
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param wallets An array of addresses that will be verified by the policy
    /// @dev The first screening address is a source address
    /// @dev The optional second screening address is a destination address
    /// @dev There might be more addresses, labeled in the policy as WALLET3, WALLET4, ...
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function requireCompliance(
        address sender,
        uint256 value,
        bytes calldata data,
        address[] memory wallets,
        Amount[] memory amounts
    ) external;

    /// @notice Requires compliance for a transaction
    /// @dev reverts if the transaction is not compliant
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param wallets An array of addresses that will be verified by the policy
    /// @dev The first screening address is a source address
    /// @dev The optional second screening address is a destination address
    /// @dev There might be more addresses, labeled in the policy as WALLET3, WALLET4, ...
    function requireCompliance(address sender, uint256 value, bytes calldata data, address[] memory wallets) external;

    /// @notice Requires compliance for a transaction
    /// @dev reverts if the transaction is not compliant
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function requireCompliance(address sender, uint256 value, bytes calldata data, Amount[] memory amounts) external;

    /// @notice Requires compliance for a transaction
    /// @dev reverts if the transaction is not compliant
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    function requireCompliance(address sender, uint256 value, bytes calldata data) external;
}
