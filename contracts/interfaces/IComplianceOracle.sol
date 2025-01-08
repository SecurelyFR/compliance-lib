// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {ICompliance} from "./ICompliance.sol";

/// @title Securely's Compliance Oracle interface
/// @author Securely.id
/// @notice Simplified Compliance interface for compliance checks
/// @dev This interface is used by the CompliantContract to interact with Securely's Compliance contract
/// @dev A partial hash is a hash of all the different parameters of a compliant transaction. Hash is replayable.
/// @dev A full hash is a truly unique hash, that combines the partial hash and the timestamp at which the compliance
///      was registered. Used in events only, for easy compliance history tracking.
interface IComplianceOracle {
    /// @notice The different statuses of a transaction
    enum Status {Approved, Expired, NotFound, Pending, Rejected}

    /// @notice The compliance timestamps of a transaction
    /// @dev The registry timestamp is the timestamp at which the compliance was registered
    /// @dev The expiry timestamp is the timestamp at which the compliance expires
    struct ComplianceTimestamps {
        uint256 registry;
        uint256 expiry;
    }

    event ApprovalRequired(address indexed dapp, bytes32 indexed fullHash, bytes32 indexed partialHash);
    event ComplianceRegistered(address indexed dapp, bytes32 indexed fullHash, string complianceDetails);
    event ComplianceVerdict(address indexed dapp, bytes32 indexed fullHash, bool approved);
    event ComplianceConsumed(address indexed dapp, bytes32 indexed fullHash, string complianceDetails);

    /// @notice Registers a compliance
    /// @param dapp The dapp address
    /// @param partialHash The partial hash of the transaction
    /// @param requiresApproval Whether the transaction requires manual approval from the dapp or not
    /// @param complianceDetails The compliance details
    function registerHash(
        address dapp,
        bytes32 partialHash,
        bool requiresApproval,
        string calldata complianceDetails
    ) external;

    /// @notice Issues a verdict on a compliance
    /// @dev Used by the controller only
    /// @dev Emits a ComplianceVerdict event
    /// @param dapp The dapp address
    /// @param partialHash The partial hash of the transaction
    /// @param approved The verdict
    function issueVerdict(address dapp, bytes32 partialHash, bool approved) external;

    /// @notice Gets the compliance status of a transaction
    /// @param sender The msg.sender of the transaction
    /// @param dapp The dapp address
    /// @param partialHash The partial hash of the transaction
    /// @param wallets The list of addresses used in ICompliance.requireCompliance
    /// @return status the status of the transaction
    function getStatus(
        address sender,
        address dapp,
        bytes32 partialHash,
        address[] memory wallets
    ) external view returns (Status);

    /// @notice Computes a partial hash based on a transaction's parameters
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param wallets The list of addresses used in ICompliance.requireCompliance
    /// @param amounts The list of amounts used in ICompliance.requireCompliance
    /// @dev Use 0x0 as a token address for native ETH
    /// @return partialHash The partial hash of the transaction
    function computePartialHash(
        address sender,
        uint256 value,
        bytes calldata data,
        address[] memory wallets,
        ICompliance.Amount[] memory amounts
    ) external view returns (bytes32 partialHash);

    /// @notice Computes a partial hash based on a transaction's parameters
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param wallets The list of addresses used in ICompliance.requireCompliance
    /// @return partialHash The partial hash of the transaction
    function computePartialHash(
        address sender,
        uint256 value,
        bytes calldata data,
        address[] memory wallets
    ) external view returns (bytes32 partialHash);

    /// @notice Computes a partial hash based on a transaction's parameters
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @param amounts The list of amounts used in ICompliance.requireCompliance
    /// @return partialHash The partial hash of the transaction
    function computePartialHash(
        address sender,
        uint256 value,
        bytes calldata data,
        ICompliance.Amount[] memory amounts
    ) external view returns (bytes32 partialHash);

    /// @notice Computes a partial hash based on a transaction's parameters
    /// @param sender The msg.sender of the transaction
    /// @param value The msg.value of the transaction
    /// @param data The msg.data of the transaction
    /// @return partialHash The partial hash of the transaction
    function computePartialHash(
        address sender,
        uint256 value,
        bytes calldata data
    ) external view returns (bytes32 partialHash);
}
