// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CompliantTreasury} from "./CompliantTreasury.sol";

/// @title CompliantTreasury
/// @author Securely.id
/// @notice This contract is a vault ensuring all funds moving through it are compliant. Whitelisted addresses bypass
///         the check and are self-custodial.
contract WhitelistedCompliantTreasury is AccessControl, CompliantTreasury {
    /// @notice The whitelisted addresses role
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    constructor(address compliance) CompliantTreasury(compliance) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Pay funds to an account in the treasury
    /// @param destination The account receiving funds in the treasury. Equals to msg.sender when it's a deposit
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens to pay
    function pay(address destination, address currency, uint256 value) virtual public payable override {
        require(!hasRole(WHITELISTED_ROLE, msg.sender), "Whitelisted users need to use transfer instead");
        super.pay(destination, currency, value);
    }

    /// @notice Withdraw funds from the treasury
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens to deposit
    function withdraw(address currency, uint256 value) virtual public override {
        require(!hasRole(WHITELISTED_ROLE, msg.sender), "Whitelisted can't withdraw because they are self-custodial");
        super.withdraw(currency, value);
    }

    /// @notice Transfer funds from the treasury to a recipient
    /// @param destination The recipient address
    /// @param value The amount of tokens to transfer. Use 0 to transfer all
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    function transfer(address destination, address currency, uint256 value) virtual public override {
        if (!hasRole(WHITELISTED_ROLE, msg.sender))
            _requireTransferCompliance(msg.sender, destination, currency, value);
        _move(msg.sender, destination, currency, value);
        emit Transfer(msg.sender, destination, currency, value);
    }

    /// @notice Move funds from an internal account to another internal account
    /// @param source The internal account sending the funds
    /// @param destination The internal account receiving the funds
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens transferred
    function _move(address source, address destination, address currency, uint256 value) virtual internal override {
        if (hasRole(WHITELISTED_ROLE, source))
            _receive(currency, value);
        super._move(source, destination, currency, value);
        if (hasRole(WHITELISTED_ROLE, destination))
            _send(destination, currency, value);
    }
}
