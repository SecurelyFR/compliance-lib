// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ComplianceProxy is ERC1967Proxy {
    constructor(address logic) payable ERC1967Proxy(logic, abi.encodeWithSignature("initialize()")) {}
}
