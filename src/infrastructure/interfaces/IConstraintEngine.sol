// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IConstraintEngine {
    function validatePolicyUpdate(bytes32 key, uint256 value) external view returns (bool);
    function validateOverride(address caller, bytes32 actionId) external view returns (bool);
}
