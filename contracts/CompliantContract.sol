// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
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

    /// @notice The compliance full hash of the current transaction
    /// @dev It is reset at the end of each transaction
    bytes32 internal complianceFullHash;

    constructor(address compliance_) { __CompliantContract_init(compliance_); }
    function __CompliantContract_init(address compliance_) internal {
        require(address(compliance) == address(0), "Already initialized");
        compliance = ICompliance(compliance_);
    }

    /// @notice A modifier to require compliance for a generic call
    /// @param value The value parameter associated to the transaction
    /// @param data An optional data parameter associated to the transaction
    /// @param enable A boolean to enable or disable the compliance check. Useful for dynamic compliance checking
    modifier requiresGenericCallCompliance         (                                         uint256 value, bytes memory data, bool enable) { if (enable) { requireCompliance(compliance.computeGenericCallPartialHash          (block.chainid, msg.sig, msg.sender,      value, data));                                   } _; complianceFullHash = 0; }

    /// @notice A modifier to require compliance for a native Eth transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    /// @param enable A boolean to enable or disable the compliance check. Useful for dynamic compliance checking
    modifier requiresEthTransferCompliance         (address from, address to,                uint256 value,                    bool enable) { if (enable) { requireCompliance(compliance.computeEthTransferPartialHash          (block.chainid, msg.sig, from, to,        value      )); payFees(from, address(0), value); } _; complianceFullHash = 0; }

    /// @notice A modifier to require compliance for a native Eth transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param value The value parameter associated to the transaction
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the transaction. e.g. an invoice ID
    /// @param enable A boolean to enable or disable the compliance check. Useful for dynamic compliance checking
    modifier requiresEthTransferWithDataCompliance (address from, address to,                uint256 value, bytes memory data, bool enable) { if (enable) { requireCompliance(compliance.computeEthTransferWithDataPartialHash  (block.chainid, msg.sig, from, to,        value, data)); payFees(from, address(0), value); } _; complianceFullHash = 0; }

    /// @notice A modifier to require compliance for an ERC20 transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param token The ERC20 token address
    /// @param value The value parameter associated to the transaction
    /// @param enable A boolean to enable or disable the compliance check. Useful for dynamic compliance checking
    modifier requiresErc20TransferCompliance       (address from, address to, address token, uint256 value,                    bool enable) { if (enable) { requireCompliance(compliance.computeErc20TransferPartialHash        (block.chainid, msg.sig, from, to, token, value      )); payFees(from, token,      value); } _; complianceFullHash = 0; }

    /// @notice A modifier to require compliance for an ERC20 transfer
    /// @param from The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param to The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param token The ERC20 token address
    /// @param value The value parameter associated to the transaction
    /// @param data Any data associated to the transaction that isn't already included, but uniquely identifies the transaction. e.g. an invoice ID
    /// @param enable A boolean to enable or disable the compliance check. Useful for dynamic compliance checking
    modifier requiresErc20TransferAndDataCompliance(address from, address to, address token, uint256 value, bytes memory data, bool enable) { if (enable) { requireCompliance(compliance.computeErc20TransferWithDataPartialHash(block.chainid, msg.sig, from, to, token, value, data)); payFees(from, token,      value); } _; complianceFullHash = 0; }

    /// @notice Checks if the compliance is activated
    /// @dev Use this function to check if the compliance is currently activated
    /// @return activated true if the compliance is activated
    function complianceActivated() internal view returns (bool activated) {
        activated = complianceFullHash != 0;
    }

    /// @notice A modifier to require the compliance to be activated
    /// @dev Use this modifier to make sure the compliance is activated in the current context
    /// @param enable A boolean to enable or disable the compliance check. Useful for dynamic compliance checking
    modifier requiresComplianceActivated(bool enable) {
        require(!enable || complianceActivated());
        _;
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

    function requireCompliance(bytes32 partialHash) private {
        complianceFullHash = compliance.consumeCompliance(partialHash);
    }
}
