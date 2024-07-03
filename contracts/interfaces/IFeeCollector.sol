// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/// @title IFeeCollector
/// @author Securely.id
/// @notice This contract defines the interface for fee collection
interface IFeeCollector {
    event FeeReceived(address indexed from, address indexed currency, uint256 amount);

    struct Rate {
        uint256 numerator;
        uint256 denominator;
    }

    /// @notice Sets the fee rate
    /// @param rate The new fee rate
    function setFee(Rate calldata rate) external;

    /// @notice Returns the fee rate
    /// @return numerator The fee numerator
    /// @return denominator The fee denominator
    function getFee() external view returns (uint256 numerator, uint256 denominator);

    /// @notice Computes the gross amount based on the fee rate and a net amount
    /// @param netAmount The net amount
    /// @return grossAmount The gross amount
    function getGrossAmount(uint256 netAmount) external view returns (uint256 grossAmount);

    /// @notice Computes the net amount based on the fee rate and a gross amount
    /// @param grossAmount The gross amount
    /// @return netAmount The net amount
    function getNetAmount(uint256 grossAmount) external view returns (uint256 netAmount);

    /// @notice Allows anyone to pay fees
    /// @param currency The currency address. Use 0x0 for native ethers
    /// @param amount The amount to pay
    function payFees(address currency, uint256 amount) external payable;
}
