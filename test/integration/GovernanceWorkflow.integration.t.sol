// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovernanceKernel} from "../../src/infrastructure/contracts/GovernanceKernel.sol";
import {ConstraintEngine} from "../../src/infrastructure/contracts/ConstraintEngine.sol";
import {PolicyRegistry} from "../../src/infrastructure/contracts/PolicyRegistry.sol";
import {AuthorityController} from "../../src/infrastructure/contracts/AuthorityController.sol";

contract GovernanceWorkflowIntegrationTest is Test {
    bytes32 internal constant POLICY_QUORUM_BPS = keccak256("POLICY_QUORUM_BPS");
    bytes32 internal constant ACTION_ID = keccak256("ACTION_PROTOCOL_UPGRADE");

    GovernanceKernel internal kernel;
    ConstraintEngine internal constraints;
    PolicyRegistry internal policy;
    AuthorityController internal authority;
    address internal operator = address(0xBEEF);
    address internal overrideDelegate = address(0xCAFE);

    function setUp() public {
        authority = new AuthorityController(address(this));
        constraints = new ConstraintEngine();
        policy = new PolicyRegistry(address(0));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));
        policy = new PolicyRegistry(address(kernel));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));
        authority.setOperator(operator, true);
        authority.setOverrideDelegate(overrideDelegate, true);
    }

    function testGovernanceWorkflowExecution() public {
        // 1) Authorized operator updates governance policy.
        vm.prank(operator);
        kernel.updatePolicy(POLICY_QUORUM_BPS, 6_500);
        assertEq(policy.getPolicy(POLICY_QUORUM_BPS), 6_500);

        // 2) Authorized operator executes regular governance action.
        vm.prank(operator);
        vm.expectEmit(true, true, true, true);
        emit GovernanceKernel.GovernanceActionExecuted(ACTION_ID, operator, abi.encode("proposal executed"));
        kernel.executeGovernanceAction(ACTION_ID, abi.encode("proposal executed"));

        // 3) Authorized delegate executes bounded override.
        vm.prank(overrideDelegate);
        vm.expectEmit(true, true, true, true);
        emit GovernanceKernel.OverrideExecuted(ACTION_ID, overrideDelegate, abi.encode("emergency override"));
        kernel.executeOverride(ACTION_ID, abi.encode("emergency override"));
    }
}
