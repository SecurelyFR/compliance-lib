// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CompliantContract, ICompliance} from "../CompliantContract.sol";

/// @title ComplianceFirewall
/// @author Securely.id
/// @notice This contract is a firewall ensuring all funds going in and out are compliant
contract ComplianceFirewall is CompliantContract {
    constructor(address compliance) CompliantContract(compliance) {}

    /// @notice Pay native ethers to a recipient
    /// @param destination The recipient address
    function payEthers(address payable destination) public payable {
        address[] memory addresses = new address[](2);
        addresses[0] = msg.sender;
        addresses[1] = destination;
        requireCompliance(addresses);
        (bool sent, ) = destination.call{value: msg.value}("");
        require(sent, "Unable to pay ethers");
    }

    /// @notice Pay ERC20 tokens to a recipient
    /// @param destination The recipient address
    /// @param token The ERC20 token address
    /// @param value The amount of tokens to pay
    function payTokens(address destination, address token, uint256 value) external {
        address[] memory addresses = new address[](2);
        addresses[0] = msg.sender;
        addresses[1] = destination;
        ICompliance.Amount[] memory amounts = new ICompliance.Amount[](1);
        amounts[0] = ICompliance.Amount(token, value);
        requireCompliance(addresses, amounts);
        bool sent = IERC20(token).transferFrom(msg.sender, destination, value);
        require(sent, "Unable to pay tokens");
    }
}
