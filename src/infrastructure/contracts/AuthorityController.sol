// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAuthorityController} from "../interfaces/IAuthorityController.sol";

/// @title AuthorityController
/// @notice Manages privileged governance operators and bounded override delegates.
contract AuthorityController is IAuthorityController {
    mapping(address => bool) public operators;
    mapping(address => bool) public overrideDelegates;
    address public immutable admin;

    event OperatorSet(address indexed account, bool enabled);
    event OverrideDelegateSet(address indexed account, bool enabled);

    error OnlyAdmin();

    constructor(address admin_) {
        admin = admin_;
        operators[admin_] = true;
        emit OperatorSet(admin_, true);
    }

    function setOperator(address account, bool enabled) external {
        if (msg.sender != admin) revert OnlyAdmin();
        operators[account] = enabled;
        emit OperatorSet(account, enabled);
    }

    function setOverrideDelegate(address account, bool enabled) external {
        if (msg.sender != admin) revert OnlyAdmin();
        overrideDelegates[account] = enabled;
        emit OverrideDelegateSet(account, enabled);
    }

    function canExecute(address caller) external view override returns (bool) {
        return operators[caller];
    }

    function canOverride(address caller, bytes32) external view override returns (bool) {
        return overrideDelegates[caller];
    }
}
