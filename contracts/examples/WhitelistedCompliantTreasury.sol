// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CompliantTreasury} from "./CompliantTreasury.sol";

/// @title WhitelistedCompliantTreasury
/// @author Securely.id
/// @notice This contract is a vault ensuring all funds moving through it are compliant. Whitelisted addresses bypass
///         the check and are self-custodial.
contract WhitelistedCompliantTreasury is AccessControl, CompliantTreasury {
    /// @notice The whitelisted addresses role
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    constructor(address compliance) CompliantTreasury(compliance) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @inheritdoc CompliantTreasury
    function pay(address destination, address currency, uint256 value) virtual public payable override {
        require(!hasRole(WHITELISTED_ROLE, msg.sender), "Whitelisted users need to use transfer instead");
        super.pay(destination, currency, value);
    }

    /// @inheritdoc CompliantTreasury
    function withdraw(address currency, uint256 value) virtual public override {
        require(!hasRole(WHITELISTED_ROLE, msg.sender), "Whitelisted can't withdraw because they are self-custodial");
        super.withdraw(currency, value);
    }

    /// @inheritdoc CompliantTreasury
    function transfer(address destination, address currency, uint256 value) virtual public override {
        require(destination != msg.sender, "You can't transfer funds to yourself");
        if (!hasRole(WHITELISTED_ROLE, msg.sender))
            _requireTransferCompliance(destination, currency, value);
        _move(msg.sender, destination, currency, value);
        emit Transfer(msg.sender, destination, currency, value);
    }

    /// @inheritdoc CompliantTreasury
    function _move(address source, address destination, address currency, uint256 value) virtual internal override {
        if (hasRole(WHITELISTED_ROLE, source))
            _receive(currency, value);
        super._move(source, destination, currency, value);
        if (hasRole(WHITELISTED_ROLE, destination))
            _send(destination, currency, value);
    }
}
