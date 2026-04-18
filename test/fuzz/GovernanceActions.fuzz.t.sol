// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovernanceKernel} from "../../src/infrastructure/contracts/GovernanceKernel.sol";
import {ConstraintEngine} from "../../src/infrastructure/contracts/ConstraintEngine.sol";
import {PolicyRegistry} from "../../src/infrastructure/contracts/PolicyRegistry.sol";
import {AuthorityController} from "../../src/infrastructure/contracts/AuthorityController.sol";

contract GovernanceActionsFuzzTest is Test {
    bytes32 internal constant POLICY_QUORUM_BPS = keccak256("POLICY_QUORUM_BPS");

    GovernanceKernel internal kernel;
    PolicyRegistry internal policy;
    AuthorityController internal authority;
    address internal operator = address(0xBEEF);
    address internal randomUser = address(0xA11CE);

    function setUp() public {
        authority = new AuthorityController(address(this));
        ConstraintEngine constraints = new ConstraintEngine();
        policy = new PolicyRegistry(address(0));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));
        policy = new PolicyRegistry(address(kernel));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));
        authority.setOperator(operator, true);
    }

    /// @notice Fuzz: unauthorized users should never update policy.
    function testFuzz_UnauthorizedPolicyUpdateAlwaysFails(address caller, uint256 value) public {
        vm.assume(caller != operator && caller != address(this));
        vm.prank(caller);
        vm.expectRevert(GovernanceKernel.Unauthorized.selector);
        kernel.updatePolicy(POLICY_QUORUM_BPS, value);
    }

    /// @notice Fuzz: authorized operator can only set quorum within invariant bounds.
    function testFuzz_OperatorUpdatesRespectConstraint(uint256 value) public {
        vm.prank(operator);
        if (value < 500 || value > 10_000) {
            vm.expectRevert(GovernanceKernel.ConstraintViolation.selector);
            kernel.updatePolicy(POLICY_QUORUM_BPS, value);
        } else {
            kernel.updatePolicy(POLICY_QUORUM_BPS, value);
            assertEq(policy.getPolicy(POLICY_QUORUM_BPS), value);
        }
    }

    /// @notice Fuzz: arbitrary payload from unauthorized actor cannot bypass action gate.
    function testFuzz_ArbitraryActionPayloadUnauthorizedFails(bytes32 actionId, bytes calldata payload) public {
        vm.prank(randomUser);
        vm.expectRevert(GovernanceKernel.Unauthorized.selector);
        kernel.executeGovernanceAction(actionId, payload);
    }
}
