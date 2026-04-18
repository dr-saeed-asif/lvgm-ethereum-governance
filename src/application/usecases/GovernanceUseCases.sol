// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library GovernanceUseCases {
    bytes32 internal constant UC_EXECUTE_GOVERNANCE_ACTION = keccak256("UC_EXECUTE_GOVERNANCE_ACTION");
    bytes32 internal constant UC_UPDATE_POLICY = keccak256("UC_UPDATE_POLICY");
    bytes32 internal constant UC_REQUEST_OVERRIDE = keccak256("UC_REQUEST_OVERRIDE");
}
