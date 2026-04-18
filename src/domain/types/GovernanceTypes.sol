// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library GovernanceTypes {
    enum ActionType {
        ExecuteAction,
        UpdatePolicy,
        OverrideAction
    }

    struct GovernanceAction {
        ActionType actionType;
        bytes32 policyKey;
        uint256 newValue;
        bytes payload;
    }
}
