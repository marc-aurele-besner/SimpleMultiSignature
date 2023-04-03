// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import { Helper } from './shared/helper.t.sol';

contract Test_Enzo_SimpleMultiSignature is Helper {
  uint8 LOG_LEVEL = 0;
  address public owner1;
  address public owner2;
  address public owner3;
  address public owner4;
  address public owner5;

  address public notOwner1;
  address public notOwner2;
  address public notOwner3;
  address public notOwner4;
  address public notOwner5;

  function setUp() public {
    // Set general test settings
    vm.roll(1);
    vm.warp(100);

    owner1 = vm.addr(1);
    owner2 = vm.addr(2);
    owner3 = vm.addr(3);
    owner4 = vm.addr(4);
    owner5 = vm.addr(5);
    notOwner1 = vm.addr(6);
    notOwner2 = vm.addr(7);
    notOwner3 = vm.addr(8);
    notOwner4 = vm.addr(9);
    notOwner5 = vm.addr(10);

    vm.roll(block.number + 1);
    vm.warp(block.timestamp + 100);
  }

  function test_owner_and_threshold_set() public {
    address[] memory owners = new address[](5);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    owners[3] = owner4;
    owners[4] = owner5;

    createMultiSig(owner1, owners, 3);

    assertTrue(!multiSignature.isOwner(notOwner1));
    assertTrue(!multiSignature.isOwner(notOwner2));
  }

  function test_addOwner_removeOwner_changeOwner() public {
    address[] memory owners = new address[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;

    createMultiSig(owner1, owners, 2);

    addOwner(address(multiSignature), notOwner1);

    removeOwner(address(multiSignature), notOwner1);

    changeOwner(address(multiSignature), owner2, notOwner2);
  }

  function test_same_with_errors() public {
    address[] memory owners = new address[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;

    createMultiSig(owner1, owners, 2);

    addOwner(owner1, notOwner1, RevertStatus.OnlyPossibleMultisigReq);

    addOwner(address(multiSignature), owner1, RevertStatus.AddressAlreadyOwner);

    removeOwner(address(multiSignature), notOwner1, RevertStatus.AddressNotOwner);

    changeOwner(address(multiSignature), owner2, address(0), RevertStatus.NewOwnerMustNotBeZeroAddress);

    changeOwner(address(multiSignature), owner2, owner1, RevertStatus.NewOwnerMustNotBeOwner);

    changeOwner(address(multiSignature), notOwner2, notOwner3, RevertStatus.OldOwnerMustBeOwner);
  }

  function test_changeThreshold_and_pause_unpause_contract() public {
    address[] memory owners = new address[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;

    createMultiSig(owner1, owners, 2);

    changeThreshold(address(multiSignature), 3);

    vm.prank(address(multiSignature));
    multiSignature.pauseContract();

    assertTrue(multiSignature.isPaused());

    vm.prank(address(multiSignature));
    multiSignature.unpauseContract();

    assertTrue(!multiSignature.isPaused());
  }

  // function test_deploy_send_ether_without_funds() public {
  //   address[] memory owners = new address[](5);
  //   owners[0] = owner1;
  //   owners[1] = owner2;
  //   owners[2] = owner3;
  //   owners[3] = owner4;
  //   owners[4] = owner5;

  //   vm.startPrank(owner1);
  //   multiSignature = new SimpleMultiSignature(owners, 3);

  //   uint256 balanceOwner3 = owner3.balance();
  //   multiSignature.execTransaction(owner3, 1 ether, )
  // }
}
