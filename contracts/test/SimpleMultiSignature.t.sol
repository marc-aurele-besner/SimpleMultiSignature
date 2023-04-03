// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import { Helper } from './shared/helper.t.sol';
import { Errors } from './shared/errors.t.sol';

contract SimpleMultiSignature_test is Helper {
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

  function test_basic_tx_without_funds() public {
    address[] memory owners = new address[](3);
    uint256[] memory ownersPk = new uint256[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    createMultiSig(owner1, owners, 2);
    ownersPk[0] = 1;
    ownersPk[1] = 2;
    ownersPk[2] = 3;
    generateSignatures_and_execTransaction(owner1, ownersPk, owner2, 1 ether, '', 35000, 0, Errors.RevertStatus.Success, false);
  }

  function test_basic_tx_with_funds() public {
    address[] memory owners = new address[](3);
    uint256[] memory ownersPk = new uint256[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    createMultiSig(owner1, owners, 2);
    ownersPk[0] = 1;
    ownersPk[1] = 2;
    ownersPk[2] = 3;

    vm.deal(address(multiSignature), 1 ether);

    generateSignatures_and_execTransaction(owner1, ownersPk, owner2, 1 ether, '', 35000, 0, Errors.RevertStatus.Success, true);
  }
}
