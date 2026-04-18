// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IConstraintEngine} from "../interfaces/IConstraintEngine.sol";
import {GovernanceInvariants} from "../../domain/invariants/GovernanceInvariants.sol";

/// @title ConstraintEngine
/// @notice Encodes hard invariants that gate governance transitions.
contract ConstraintEngine is IConstraintEngine {
    bytes32 public constant POLICY_QUORUM_BPS = keccak256("POLICY_QUORUM_BPS");

    function validatePolicyUpdate(bytes32 key, uint256 value) external pure override returns (bool) {
        if (key == POLICY_QUORUM_BPS) {
            return GovernanceInvariants.isValidQuorum(value);
        }
        return true;
    }

    function validateOverride(address, bytes32) external pure override returns (bool) {
        // Override constraints can be extended with temporal and scope checks.
        return true;
    }
}
