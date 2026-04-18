// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library GovernanceInvariants {
    uint256 internal constant MIN_QUORUM_BPS = 500; // 5%
    uint256 internal constant MAX_QUORUM_BPS = 10_000; // 100%
    uint256 internal constant MAX_OVERRIDE_SCOPE = 3;

    function isValidQuorum(uint256 value) internal pure returns (bool) {
        return value >= MIN_QUORUM_BPS && value <= MAX_QUORUM_BPS;
    }
}
