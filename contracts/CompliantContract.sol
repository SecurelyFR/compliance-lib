// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {ICompliance} from "./interfaces/ICompliance.sol";

/// @title Securely's Compliance Library
/// @author Securely.id
/// @notice This contract provides tools to enforce compliance rules
/// @dev Either use checkCompliance->finalizeCompliance or directly requireCompliance
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

    /// @notice Checks compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function checkCompliance(address[] memory wallets, ICompliance.Amount[] memory amounts) internal returns (bool) {
        return compliance.checkCompliance(msg.sender, msg.value, msg.data, wallets, amounts);
    }

    /// @notice Checks compliance for a transaction
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function checkCompliance(ICompliance.Amount[] memory amounts) internal returns (bool) {
        return compliance.checkCompliance(msg.sender, msg.value, msg.data, amounts);
    }

    /// @notice Checks compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    function checkCompliance(address[] memory wallets) internal returns (bool) {
        return compliance.checkCompliance(msg.sender, msg.value, msg.data, wallets);
    }

    /// @notice Checks compliance for a transaction
    function checkCompliance() internal returns (bool) {
        return compliance.checkCompliance(msg.sender, msg.value, msg.data);
    }

    /// @notice Finalizes compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function finalizeCompliance(address[] memory wallets, ICompliance.Amount[] memory amounts) internal {
        compliance.finalizeCompliance(msg.sender, msg.value, msg.data, wallets, amounts);
    }

    /// @notice Finalizes compliance for a transaction
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function finalizeCompliance(ICompliance.Amount[] memory amounts) internal {
        compliance.finalizeCompliance(msg.sender, msg.value, msg.data, amounts);
    }

    /// @notice Finalizes compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    function finalizeCompliance(address[] memory wallets) internal {
        compliance.finalizeCompliance(msg.sender, msg.value, msg.data, wallets);
    }

    /// @notice Finalizes compliance for a transaction
    function finalizeCompliance() internal {
        compliance.finalizeCompliance(msg.sender, msg.value, msg.data);
    }

    /// @notice Requires compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function requireCompliance(address[] memory wallets, ICompliance.Amount[] memory amounts) internal {
        finalizeCompliance(wallets, amounts);
    }

    /// @notice Requires compliance for a transaction
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function requireCompliance(ICompliance.Amount[] memory amounts) internal {
        finalizeCompliance(amounts);
    }

    /// @notice Requires compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    function requireCompliance(address[] memory wallets) internal {
        finalizeCompliance(wallets);
    }

    /// @notice Requires compliance for a transaction
    function requireCompliance() internal {
        finalizeCompliance();
    }
}
