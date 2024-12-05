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

    /// @notice Requires compliance for a transaction
    /// @param screening An array of addresses that should be available in the policy
    /// @param values An array of token/amount that should be available in the policy
    /// @dev Use 0x0 as a token address for native ETH
    function requireCompliance(address[] memory screening, ICompliance.Value[] memory values) internal {
        compliance.requireCompliance(msg.sender, msg.value, msg.data, screening, values);
    }

    /// @notice Requires compliance for a transaction
    /// @param values An array of token/amount that should be available in the policy
    /// @dev Use 0x0 as a token address for native ETH
    function requireCompliance(ICompliance.Value[] memory values) internal {
        compliance.requireCompliance(msg.sender, msg.value, msg.data, values);
    }

    /// @notice Requires compliance for a transaction
    /// @param screening An array of addresses that should be available in the policy
    function requireCompliance(address[] memory screening) internal {
        compliance.requireCompliance(msg.sender, msg.value, msg.data, screening);
    }

    function requireCompliance() internal {
        compliance.requireCompliance(msg.sender, msg.value, msg.data);
    }
}
