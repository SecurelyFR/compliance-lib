// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CompliantContract, ICompliance} from "../CompliantContract.sol";

/// @title CompliantTreasury
/// @author Securely.id
/// @notice This contract is a vault ensuring all funds moving through it are compliant
contract CompliantTreasury is CompliantContract {
    /// @dev mapping(owner => currency => amount)
    /// @dev Using currency = 0x0 for native ethers.
    mapping(address => mapping(address => uint256)) internal _treasury;

    /// @dev For easy history tracking
    event Payment(address indexed source, address indexed destination, address indexed currency, uint256 amount);
    event Withdrawal(address indexed account, address indexed currency, uint256 amount);
    event Transfer(address indexed source, address indexed destination, address indexed currency, uint256 amount);

    constructor(address compliance) CompliantContract(compliance) {}

    /// @notice Pay funds to an account in the treasury
    /// @param destination The account receiving funds in the treasury. Equals to msg.sender when it's a deposit
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of eth/tokens to pay
    function pay(address destination, address currency, uint256 amount) virtual public payable {
        _requireTransferCompliance(msg.sender, destination, currency, amount);
        _receive(currency, amount);
        _move(address(this), destination, currency, amount);
        emit Payment(msg.sender, destination, currency, amount);
    }

    /// @notice Withdraw funds from the treasury
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of eth/tokens to deposit
    function withdraw(address currency, uint256 amount) virtual public {
        _requireTransferCompliance(msg.sender, msg.sender, currency, amount);
        _move(msg.sender, address(this), currency, amount);
        _send(msg.sender, currency, amount);
        emit Withdrawal(msg.sender, currency, amount);
    }

    /// @notice Transfer funds from the treasury to a recipient
    /// @param destination The recipient address
    /// @param amount The amount of tokens to transfer. Use 0 to transfer all
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    function transfer(address destination, address currency, uint256 amount) virtual public {
        _requireTransferCompliance(msg.sender, destination, currency, amount);
        _move(msg.sender, destination, currency, amount);
        emit Transfer(msg.sender, destination, currency, amount);
    }

    /// @notice Returns the amount of compliant eth/tokens owned by an internal account
    /// @param account The account to scan
    /// @param currency The currency to scan
    function balanceOf(address account, address currency) external view returns (uint256 amount) {
        amount = _treasury[account][currency];
    }

    /// @notice requires compliance for eth or ERC20 transfer, based on the currency argument
    /// @param source The sender of funds. Not necessarily the msg.sender of the transaction
    /// @dev The from parameter is used for address screening purposes
    /// @param destination The receiver of funds. Not necessarily the dapp / the receiver of the transaction
    /// @dev The to parameter is used for address screening purposes
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of eth/tokens transferred
    function _requireTransferCompliance(
        address source,
        address destination,
        address currency,
        uint256 amount
    ) internal {
        address[] memory addresses = new address[](2);
        addresses[0] = source;
        addresses[1] = destination;
        ICompliance.Value[] memory values = new ICompliance.Value[](1);
        values[0] = ICompliance.Value(currency, amount);
        requireCompliance(addresses, values);
    }

    /// @notice Receive funds from the msg.sender into an internal account
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of eth/tokens transferred
    function _receive(address currency, uint256 amount) virtual internal {
        if (currency == address(0))
            require(amount == msg.value);
        else
            IERC20(currency).transferFrom(msg.sender, address(this), amount);
    }

    /// @notice Send funds from an internal account to the outside
    /// @param destination The external account receiving the funds
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of eth/tokens transferred
    function _send(address destination, address currency, uint256 amount) virtual internal {
        bool sent;
        if (currency == address(0))
            (sent, ) = destination.call{value: amount}("");
        else
            sent = IERC20(currency).transfer(destination, amount);
        require(sent);
    }

    /// @notice Move funds from an internal account to another internal account
    /// @param source The internal account sending the funds
    /// @param destination The internal account receiving the funds
    /// @param currency The ERC20 token address. Use 0x0 for native ethers
    /// @param amount The amount of eth/tokens transferred
    function _move(address source, address destination, address currency, uint256 amount) virtual internal {
        require(amount > 0);
        if (source != address(this)) {
            require(_treasury[source][currency] >= amount);
            _treasury[source][currency] -= amount;
        }
        if (destination != address(this))
            _treasury[destination][currency] += amount;
    }
}
