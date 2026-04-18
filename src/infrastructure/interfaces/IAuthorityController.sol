// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorityController {
    function canExecute(address caller) external view returns (bool);
    function canOverride(address caller, bytes32 actionId) external view returns (bool);
}
