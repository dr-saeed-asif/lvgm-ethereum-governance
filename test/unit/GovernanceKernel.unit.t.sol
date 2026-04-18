// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovernanceKernel} from "../../src/infrastructure/contracts/GovernanceKernel.sol";
import {ConstraintEngine} from "../../src/infrastructure/contracts/ConstraintEngine.sol";
import {PolicyRegistry} from "../../src/infrastructure/contracts/PolicyRegistry.sol";
import {AuthorityController} from "../../src/infrastructure/contracts/AuthorityController.sol";

contract GovernanceKernelUnitTest is Test {
    bytes32 internal constant POLICY_QUORUM_BPS = keccak256("POLICY_QUORUM_BPS");

    GovernanceKernel internal kernel;
    ConstraintEngine internal constraints;
    PolicyRegistry internal policy;
    AuthorityController internal authority;

    address internal admin = address(this);
    address internal operator = address(0xBEEF);
    address internal attacker = address(0xBAD);

    function setUp() public {
        authority = new AuthorityController(admin);
        constraints = new ConstraintEngine();
        policy = new PolicyRegistry(address(0));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));
        // Re-deploy with kernel wired in registry.
        policy = new PolicyRegistry(address(kernel));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));
        authority.setOperator(operator, true);
    }

    function testOperatorCanUpdatePolicy() public {
        vm.prank(operator);
        vm.expectEmit(true, true, true, true);
        emit GovernanceKernel.PolicyUpdated(POLICY_QUORUM_BPS, 6_000, operator);
        kernel.updatePolicy(POLICY_QUORUM_BPS, 6_000);
        assertEq(policy.getPolicy(POLICY_QUORUM_BPS), 6_000);
    }

    function testUnauthorizedPolicyUpdateFails() public {
        vm.prank(attacker);
        vm.expectRevert(GovernanceKernel.Unauthorized.selector);
        kernel.updatePolicy(POLICY_QUORUM_BPS, 6_000);
    }

    function testInvalidQuorumFailsInvariantCheck() public {
        vm.prank(operator);
        vm.expectRevert(GovernanceKernel.ConstraintViolation.selector);
        kernel.updatePolicy(POLICY_QUORUM_BPS, 50_000);
    }
}
