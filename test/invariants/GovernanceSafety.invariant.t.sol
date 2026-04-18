// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test} from "forge-std/Test.sol";
import {GovernanceKernel} from "../../src/infrastructure/contracts/GovernanceKernel.sol";
import {ConstraintEngine} from "../../src/infrastructure/contracts/ConstraintEngine.sol";
import {PolicyRegistry} from "../../src/infrastructure/contracts/PolicyRegistry.sol";
import {AuthorityController} from "../../src/infrastructure/contracts/AuthorityController.sol";

contract GovernanceHandler is Test {
    bytes32 internal constant POLICY_QUORUM_BPS = keccak256("POLICY_QUORUM_BPS");

    GovernanceKernel internal kernel;
    address internal operator;

    constructor(GovernanceKernel kernel_) {
        kernel = kernel_;
        operator = address(0xBEEF);
    }

    function updateQuorum(uint256 quorumBps) external {
        uint256 bounded = bound(quorumBps, 0, 12_000);
        vm.prank(operator);
        try kernel.updatePolicy(POLICY_QUORUM_BPS, bounded) {} catch {}
    }
}

contract GovernanceSafetyInvariantTest is StdInvariant, Test {
    bytes32 internal constant POLICY_QUORUM_BPS = keccak256("POLICY_QUORUM_BPS");

    GovernanceKernel internal kernel;
    PolicyRegistry internal policy;
    GovernanceHandler internal handler;

    function setUp() public {
        AuthorityController authority = new AuthorityController(address(this));
        ConstraintEngine constraints = new ConstraintEngine();
        policy = new PolicyRegistry(address(0));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));
        policy = new PolicyRegistry(address(kernel));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));

        authority.setOperator(address(0xBEEF), true);
        handler = new GovernanceHandler(kernel);
        targetContract(address(handler));
    }

    /// @notice Invariant: persisted quorum remains in valid bounds when set.
    function invariant_QuorumAlwaysValidWhenNonZero() public view {
        uint256 quorum = policy.getPolicy(POLICY_QUORUM_BPS);
        if (quorum != 0) {
            assertGe(quorum, 500);
            assertLe(quorum, 10_000);
        }
    }
}
