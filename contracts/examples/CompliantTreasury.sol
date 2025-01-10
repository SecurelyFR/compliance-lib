// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CompliantContract, ICompliance} from "../CompliantContract.sol";

/// @title CompliantTreasury
/// @author Securely.id
/// @notice This contract is a vault ensuring all funds moving through it are compliant
contract CompliantTreasury is CompliantContract {
    /// @dev mapping(owner => currency => value)
    /// @dev Using currency = 0x0 for native ethers.
    mapping(address => mapping(address => uint256)) internal _treasury;

    /// @dev For easy history tracking
    event Payment(address indexed source, address indexed destination, address indexed currency, uint256 value);
    event Withdrawal(address indexed account, address indexed currency, uint256 value);
    event Transfer(address indexed source, address indexed destination, address indexed currency, uint256 value);

    constructor(address compliance) CompliantContract(compliance) {}

    /// @notice Pay funds to an account in the treasury
    /// @param destination The account receiving funds in the treasury. Equals to msg.sender when it's a deposit
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens to pay
    function pay(address destination, address currency, uint256 value) virtual public payable {
        _requireTransferCompliance(destination, currency, value);
        _receive(currency, value);
        _move(address(this), destination, currency, value);
        emit Payment(msg.sender, destination, currency, value);
    }

    /// @notice Withdraw funds from the treasury
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens to deposit
    function withdraw(address currency, uint256 value) virtual public {
        _requireTransferCompliance(msg.sender, currency, value);
        _move(msg.sender, address(this), currency, value);
        _send(msg.sender, currency, value);
        emit Withdrawal(msg.sender, currency, value);
    }

    /// @notice Transfer funds from the treasury to a recipient
    /// @param destination The recipient address
    /// @param value The value of tokens to transfer. Use 0 to transfer all
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    function transfer(address destination, address currency, uint256 value) virtual public {
        require(destination != msg.sender, "You can't transfer funds to yourself");
        _requireTransferCompliance(destination, currency, value);
        _move(msg.sender, destination, currency, value);
        emit Transfer(msg.sender, destination, currency, value);
    }

    /// @notice Returns the value of compliant eth/tokens owned by an internal account
    /// @param account The account to scan
    /// @param currency The currency to scan
    function balanceOf(address account, address currency) external view returns (uint256 value) {
        value = _treasury[account][currency];
    }

    /// @notice requires compliance for eth or ERC20 transfer, based on the currency argument
    /// @dev The from parameter is used for address screening purposes
    /// @param destination The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens transferred
    function _requireTransferCompliance(
        address destination,
        address currency,
        uint256 value
    ) internal {
        ICompliance.Amount[] memory amounts = new ICompliance.Amount[](1);
        amounts[0] = ICompliance.Amount(currency, value);
        if (msg.sender == destination)
            requireCompliance(amounts);
        else {
            address[] memory addresses = new address[](1);
            addresses[0] = destination;
            requireCompliance(addresses, amounts);
        }
    }

    /// @notice Receive funds from the msg.sender into an internal account
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens transferred
    function _receive(address currency, uint256 value) virtual internal {
        if (currency == address(0))
            require(value == msg.value, "msg.value and value arg must match");
        else
            IERC20(currency).transferFrom(msg.sender, address(this), value);
    }

    /// @notice Send funds from an internal account to the outside
    /// @param destination The external account receiving the funds
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens transferred
    function _send(address destination, address currency, uint256 value) virtual internal {
        bool sent;
        if (currency == address(0))
            (sent, ) = destination.call{value: value}("");
        else
            sent = IERC20(currency).transfer(destination, value);
        require(sent, "Transfer failed");
    }

    /// @notice Move funds from an internal account to another internal account
    /// @param source The internal account sending the funds
    /// @param destination The internal account receiving the funds
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param value The amount of eth/tokens transferred
    function _move(address source, address destination, address currency, uint256 value) virtual internal {
        require(value > 0, "Can't move a 0 value");
        if (source != address(this)) {
            require(_treasury[source][currency] >= value, "Insufficient funds in the treasury");
            _treasury[source][currency] -= value;
        }
        if (destination != address(this))
            _treasury[destination][currency] += value;
    }
}
