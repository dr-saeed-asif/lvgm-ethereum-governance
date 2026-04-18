// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceModules {
    function executeGovernanceAction(
        bytes32 actionId,
        bytes32 policyKey,
        uint256 value,
        bytes calldata payload
    ) external;
}
