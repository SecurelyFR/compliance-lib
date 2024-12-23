// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {ICompliance} from "./interfaces/ICompliance.sol";

/// @title Securely's Compliance Library
/// @author Securely.id
/// @notice This contract provides tools to enforce compliance rules
/// @dev Either use checkComplianceStatus->requireCompliance or directly requireCompliance
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
    function checkComplianceStatus(address[] memory wallets, ICompliance.Amount[] memory amounts) internal view returns (bool) {
        return compliance.checkComplianceStatus(msg.sender, msg.value, msg.data, wallets, amounts);
    }

    /// @notice Checks compliance for a transaction
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function checkComplianceStatus(ICompliance.Amount[] memory amounts) internal view returns (bool) {
        return compliance.checkComplianceStatus(msg.sender, msg.value, msg.data, amounts);
    }

    /// @notice Checks compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    function checkComplianceStatus(address[] memory wallets) internal view returns (bool) {
        return compliance.checkComplianceStatus(msg.sender, msg.value, msg.data, wallets);
    }

    /// @notice Checks compliance for a transaction
    function checkComplianceStatus() internal view returns (bool) {
        return compliance.checkComplianceStatus(msg.sender, msg.value, msg.data);
    }

    /// @notice Requires compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function requireCompliance(address[] memory wallets, ICompliance.Amount[] memory amounts) internal {
        compliance.requireCompliance(msg.sender, msg.value, msg.data, wallets, amounts);
    }

    /// @notice Requires compliance for a transaction
    /// @param amounts An array of token/amount that will be verified by the policy
    /// @dev Use 0x0 as a token address for native ETH
    function requireCompliance(ICompliance.Amount[] memory amounts) internal {
        compliance.requireCompliance(msg.sender, msg.value, msg.data, amounts);
    }

    /// @notice Requires compliance for a transaction
    /// @param wallets An array of addresses that will be verified by the policy
    function requireCompliance(address[] memory wallets) internal {
        compliance.requireCompliance(msg.sender, msg.value, msg.data, wallets);
    }

    /// @notice Requires compliance for a transaction
    function requireCompliance() internal {
        compliance.requireCompliance(msg.sender, msg.value, msg.data);
    }
}
