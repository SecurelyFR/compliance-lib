// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC20Securely} from "contracts/interfaces/IERC20Securely.sol";
import {CompliantFunds} from "./CompliantFunds.sol";

/// @title ComplianceFirewall
/// @author Securely.id
/// @notice This contract is a firewall ensuring all funds going in and out are compliant
contract ComplianceFirewall is CompliantFunds {
    constructor(address compliance) CompliantFunds(compliance) {}

    /// @dev Sends orphan ethers to the default destination
    receive() external payable {
        payEthers(payable(address(0)));
    }

    /// @notice Pay native ethers to a recipient
    /// @param destination The recipient address
    function payEthers(
        address payable destination
    ) public payable {
        requireEthTransferCompliance(msg.sender, destination, msg.value);
        if (destination == address(0))
            destination = defaultDestination;
        (bool sent, ) = destination.call{value: msg.value}("");
        require(sent, "Unable to pay ethers");
        _payed(destination, address(0), msg.value);
    }

    /// @notice Pay ERC20 tokens to a recipient
    /// @param destination The recipient address
    /// @param token The ERC20 token address
    /// @param amount The amount of tokens to pay
    function payTokens(
        address destination,
        address token,
        uint256 amount
    ) external {
        requireErc20TransferCompliance(tx.origin, destination, token, amount);
        if (destination == address(0))
            destination = defaultDestination;
        bool sent = IERC20Securely(token).transferFrom(msg.sender, destination, amount);
        require(sent, "Unable to pay tokens");
        _payed(destination, token, amount);
    }
}
