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
    /// @param amount The amount of eth/tokens to pay
    function pay(address destination, address currency, uint256 amount) virtual public payable override {
        require(!hasRole(WHITELISTED_ROLE, msg.sender));
        super.pay(destination, currency, amount);
    }

    /// @notice Withdraw funds from the treasury
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of eth/tokens to deposit
    function withdraw(address currency, uint256 amount) virtual public override {
        require(!hasRole(WHITELISTED_ROLE, msg.sender));
        super.withdraw(currency, amount);
    }

    /// @notice Transfer funds from the treasury to a recipient
    /// @param destination The recipient address
    /// @param amount The amount of tokens to transfer. Use 0 to transfer all
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    function transfer(address destination, address currency, uint256 amount) virtual public override {
        if (!hasRole(WHITELISTED_ROLE, msg.sender))
            _requireTransferCompliance(msg.sender, destination, currency, amount);
        _move(msg.sender, destination, currency, amount);
        emit Transfer(msg.sender, destination, currency, amount);
    }

    /// @notice Move funds from an internal account to another internal account
    /// @param source The internal account sending the funds
    /// @param destination The internal account receiving the funds
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of eth/tokens transferred
    function _move(address source, address destination, address currency, uint256 amount) virtual internal override {
        if (hasRole(WHITELISTED_ROLE, source))
            _receive(currency, amount);
        super._move(source, destination, currency, amount);
        if (hasRole(WHITELISTED_ROLE, destination))
            _send(destination, currency, amount);
    }
}
