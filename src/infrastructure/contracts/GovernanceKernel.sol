// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IConstraintEngine} from "../interfaces/IConstraintEngine.sol";
import {IPolicyRegistry} from "../interfaces/IPolicyRegistry.sol";
import {IAuthorityController} from "../interfaces/IAuthorityController.sol";

/// @title GovernanceKernel
/// @notice Coordinates policy updates, governance execution, and bounded overrides.
contract GovernanceKernel {
    IConstraintEngine public immutable constraintEngine;
    IPolicyRegistry public immutable policyRegistry;
    IAuthorityController public immutable authorityController;

    event GovernanceActionExecuted(bytes32 indexed actionId, address indexed actor, bytes payload);
    event PolicyUpdated(bytes32 indexed key, uint256 value, address indexed actor);
    event OverrideExecuted(bytes32 indexed actionId, address indexed actor, bytes payload);

    error Unauthorized();
    error ConstraintViolation();

    constructor(address constraintEngine_, address policyRegistry_, address authorityController_) {
        constraintEngine = IConstraintEngine(constraintEngine_);
        policyRegistry = IPolicyRegistry(policyRegistry_);
        authorityController = IAuthorityController(authorityController_);
    }

    function executeGovernanceAction(bytes32 actionId, bytes calldata payload) external {
        if (!authorityController.canExecute(msg.sender)) revert Unauthorized();
        emit GovernanceActionExecuted(actionId, msg.sender, payload);
    }

    function updatePolicy(bytes32 key, uint256 value) external {
        if (!authorityController.canExecute(msg.sender)) revert Unauthorized();
        if (!constraintEngine.validatePolicyUpdate(key, value)) revert ConstraintViolation();
        policyRegistry.setPolicy(key, value);
        emit PolicyUpdated(key, value, msg.sender);
    }

    function executeOverride(bytes32 actionId, bytes calldata payload) external {
        if (!authorityController.canOverride(msg.sender, actionId)) revert Unauthorized();
        if (!constraintEngine.validateOverride(msg.sender, actionId)) revert ConstraintViolation();
        emit OverrideExecuted(actionId, msg.sender, payload);
    }
}
