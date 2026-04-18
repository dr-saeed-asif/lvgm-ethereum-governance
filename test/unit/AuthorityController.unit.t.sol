// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AuthorityController} from "../../src/infrastructure/contracts/AuthorityController.sol";

contract AuthorityControllerUnitTest is Test {
    AuthorityController internal authority;
    address internal admin = address(this);
    address internal delegate = address(0xD1);
    address internal attacker = address(0xBAD);

    function setUp() public {
        authority = new AuthorityController(admin);
    }

    function testAdminCanGrantOverrideDelegate() public {
        vm.expectEmit(true, true, true, true);
        emit AuthorityController.OverrideDelegateSet(delegate, true);
        authority.setOverrideDelegate(delegate, true);
        assertTrue(authority.canOverride(delegate, bytes32(0)));
    }

    function testNonAdminCannotGrantOverrideDelegate() public {
        vm.prank(attacker);
        vm.expectRevert(AuthorityController.OnlyAdmin.selector);
        authority.setOverrideDelegate(delegate, true);
    }
}
