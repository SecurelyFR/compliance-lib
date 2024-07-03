// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev This is a copy of the openzeppelin OwnableUpgradeable contract with the storage locations and functions renamed
 * to avoid name clashing with other Ownable contracts.
 *
 * Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract SecurelyOwnableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct SecurelyOwnableStorage {
        address _owner;
    }

    // keccak256(abi.encode(uint256(keccak256("securely.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SecurelyOwnableStorageLocation = 0x0de5028ee0ca79d09d46cb7cb2ca974b68bb809de6863c3487d334e50228c500;

    function _getOwnableStorage() private pure returns (SecurelyOwnableStorage storage $) {
        assembly {
            $.slot := SecurelyOwnableStorageLocation
        }
    }

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error SecurelyOwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error SecurelyOwnableInvalidOwner(address owner);

    event SecurelyOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    function __SecurelyOwnable_init(address initialOwner) internal onlyInitializing {
        __SecurelyOwnable_init_unchained(initialOwner);
    }

    function __SecurelyOwnable_init_unchained(address initialOwner) internal onlyInitializing {
        if (initialOwner == address(0)) {
            revert SecurelyOwnableInvalidOwner(address(0));
        }
        _securelyTransferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier securelyOnlyOwner() {
        _securelyCheckOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function securelyOwner() public view virtual returns (address) {
        SecurelyOwnableStorage storage $ = _getOwnableStorage();
        return $._owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _securelyCheckOwner() internal view virtual {
        if (securelyOwner() != _msgSender()) {
            revert SecurelyOwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function securelyRenounceOwnership() public virtual securelyOnlyOwner {
        _securelyTransferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function securelyTransferOwnership(address newOwner) public virtual securelyOnlyOwner {
        if (newOwner == address(0)) {
            revert SecurelyOwnableInvalidOwner(address(0));
        }
        _securelyTransferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _securelyTransferOwnership(address newOwner) internal virtual {
        SecurelyOwnableStorage storage $ = _getOwnableStorage();
        address oldOwner = $._owner;
        $._owner = newOwner;
        emit SecurelyOwnershipTransferred(oldOwner, newOwner);
    }
}
