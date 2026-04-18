// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPolicyRegistry {
    function setPolicy(bytes32 key, uint256 value) external;
    function getPolicy(bytes32 key) external view returns (uint256);
}
