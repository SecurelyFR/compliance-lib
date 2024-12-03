// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/// @title Securely's Compliance Oracle interface
/// @author Securely.id
/// @notice Simplified Compliance interface for compliance checks
/// @dev This interface is used by the CompliantContract to interact with Securely's Compliance contract
/// @dev A partial hash is a hash of all the different parameters of a compliant transaction. Hash is replayable.
/// @dev A full hash is a truly unique hash, that combines the partial hash and the timestamp at which the compliance
///      was registered. Used in events only, for easy compliance history tracking.
interface IComplianceOracle {
    /// @notice The different pools of transactions
    /// @dev This gives every transaction a unique partial hash even if the parameters collide
    enum Pool {GenericCall, EthTransfer, EthTransferWithData, Erc20Transfer, Erc20TransferWithData}

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

    /// @notice Gets the compliance status of a transaction
    /// @param dapp The dapp address
    /// @param partialHash The partial hash of the transaction
    /// @return status the status of the transaction
    function getStatus(address dapp, bytes32 partialHash) external view returns (Status);

    /// @notice Computes a partial hash based on a compliant generic call transaction's parameters
    /// @param chainid The chain id. This is included so the partial hash is unique across chains
    /// @param functionSelector The function selector of the transaction
    /// @param from The sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    /// @param data The optional data parameter associated to the transaction
    /// @return partialHash The partial hash of the transaction
    function computeGenericCallPartialHash(
        uint256 chainid,
        bytes4 functionSelector,
        address from,
        uint256 value,
        bytes memory data
    ) external pure returns (bytes32 partialHash);

    /// @notice Computes a partial hash based on a compliant Ether transfer transaction's parameters
    /// @param chainid The chain id. This is included so the partial hash is unique across chains
    /// @param functionSelector The function selector of the transaction
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The ether amount to transfer
    /// @return partialHash The partial hash of the transaction
    function computeEthTransferPartialHash(
        uint256 chainid,
        bytes4 functionSelector,
        address from,
        address to,
        uint256 value
    ) external pure returns (bytes32 partialHash);

    /// @notice Computes a partial hash based on a compliant Ether transfer transaction's parameters and a bonus data
    ///         field
    /// @param chainid The chain id. This is included so the partial hash is unique across chains
    /// @param functionSelector The function selector of the transaction
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The ether amount to transfer
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the
    ///             transaction. e.g. an invoice ID
    /// @return partialHash The partial hash of the transaction
    function computeEthTransferWithDataPartialHash(
        uint256 chainid,
        bytes4 functionSelector,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) external pure returns (bytes32 partialHash);

    /// @notice Computes a partial hash based on a compliant Ether transfer transaction's parameters and a bonus data
    ///         field
    /// @param chainid The chain id. This is included so the partial hash is unique across chains
    /// @param functionSelector The function selector of the transaction
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The ether amount to transfer
    /// @return partialHash The partial hash of the transaction
    function computeErc20TransferPartialHash(
        uint256 chainid,
        bytes4 functionSelector,
        address from,
        address to,
        address token,
        uint256 value
    ) external pure returns (bytes32 partialHash);

    /// @notice Computes a partial hash based on a compliant Ether transfer transaction's parameters and a bonus data
    ///         field
    /// @param chainid The chain id. This is included so the partial hash is unique across chains
    /// @param functionSelector The function selector of the transaction
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The ether amount to transfer
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the
    ///             transaction. e.g. an invoice ID
    /// @return partialHash The partial hash of the transaction
    function computeErc20TransferWithDataPartialHash(
        uint256 chainid,
        bytes4 functionSelector,
        address from,
        address to,
        address token,
        uint256 value,
        bytes memory data
    ) external pure returns (bytes32 partialHash);

    /// @notice Issues a verdict on a compliance
    /// @dev Used by the controller only
    /// @dev Emits a ComplianceVerdict event
    /// @param dapp The dapp address
    /// @param partialHash The partial hash of the transaction
    /// @param approved The verdict
    function issueVerdict(address dapp, bytes32 partialHash, bool approved) external;
}
