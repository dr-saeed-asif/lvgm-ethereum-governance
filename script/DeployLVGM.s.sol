// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {GovernanceKernel} from "../src/infrastructure/contracts/GovernanceKernel.sol";
import {ConstraintEngine} from "../src/infrastructure/contracts/ConstraintEngine.sol";
import {PolicyRegistry} from "../src/infrastructure/contracts/PolicyRegistry.sol";
import {AuthorityController} from "../src/infrastructure/contracts/AuthorityController.sol";

/// @title DeployLVGM
/// @notice Minimal deployment script for the LVGM prototype stack.
contract DeployLVGM is Script {
    function run() external returns (GovernanceKernel kernel, ConstraintEngine constraints, PolicyRegistry policy, AuthorityController authority) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.addr(deployerKey);
        vm.startBroadcast(deployerKey);

        authority = new AuthorityController(admin);
        constraints = new ConstraintEngine();

        // Two-step deployment to wire kernel and policy addresses cleanly.
        PolicyRegistry bootstrapPolicy = new PolicyRegistry(address(0));
        GovernanceKernel bootstrapKernel =
            new GovernanceKernel(address(constraints), address(bootstrapPolicy), address(authority));

        policy = new PolicyRegistry(address(bootstrapKernel));
        kernel = new GovernanceKernel(address(constraints), address(policy), address(authority));

        vm.stopBroadcast();
    }
}
