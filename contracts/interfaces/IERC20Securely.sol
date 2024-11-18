// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20Securely.sol)

pragma solidity ^0.8;

/// @title IERC20Securely
/// @notice Minimal ERC20 interface for transfers
interface IERC20Securely {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
