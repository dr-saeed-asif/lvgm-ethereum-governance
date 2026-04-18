// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPolicyRegistry} from "../interfaces/IPolicyRegistry.sol";

/// @title PolicyRegistry
/// @notice Stores adjustable governance parameters managed by the kernel.
contract PolicyRegistry is IPolicyRegistry {
    mapping(bytes32 => uint256) private _policyValues;
    address public immutable kernel;

    event PolicySet(bytes32 indexed key, uint256 oldValue, uint256 newValue, address indexed actor);

    error OnlyKernel();

    constructor(address kernel_) {
        kernel = kernel_;
    }

    function setPolicy(bytes32 key, uint256 value) external override {
        if (msg.sender != kernel) revert OnlyKernel();
        uint256 oldValue = _policyValues[key];
        _policyValues[key] = value;
        emit PolicySet(key, oldValue, value, msg.sender);
    }

    function getPolicy(bytes32 key) external view override returns (uint256) {
        return _policyValues[key];
    }
}
