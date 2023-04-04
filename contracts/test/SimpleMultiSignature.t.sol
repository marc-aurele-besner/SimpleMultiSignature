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

  function test_addOwner() public {
    address[] memory owners = new address[](3);
    uint256[] memory ownersPk = new uint256[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    createMultiSig(owner1, owners, 2);
    ownersPk[0] = 1;
    ownersPk[1] = 2;
    ownersPk[2] = 3;

    //vm.deal(address(multiSignature), 1 ether);

    generateSignatures_and_execTransaction(
      owner1,
      ownersPk,
      address(multiSignature),
      0,
      buildData_addOwner(notOwner1),
      35000,
      0,
      Errors.RevertStatus.Success,
      true
    );

    assertTrue(multiSignature.isOwner(notOwner1));
  }

  function test_changeThreshold() public {
    address[] memory owners = new address[](3);
    uint256[] memory ownersPk = new uint256[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    createMultiSig(owner1, owners, 2);
    ownersPk[0] = 1;
    ownersPk[1] = 2;
    ownersPk[2] = 3;

    //vm.deal(address(multiSignature), 1 ether);

    generateSignatures_and_execTransaction(
      owner1,
      ownersPk,
      address(multiSignature),
      0,
      buildData_changeThreshold(1),
      35000,
      0,
      Errors.RevertStatus.Success,
      true
    );

    assertEq(multiSignature.threshold(), 1);
  }

  function test_changeThreshold_higher_than_owners_count() public {
    address[] memory owners = new address[](3);
    uint256[] memory ownersPk = new uint256[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    createMultiSig(owner1, owners, 2);
    ownersPk[0] = 1;
    ownersPk[1] = 2;
    ownersPk[2] = 3;

    //vm.deal(address(multiSignature), 1 ether);

    generateSignatures_and_execTransaction(
      owner1,
      ownersPk,
      address(multiSignature),
      0,
      buildData_changeThreshold(4),
      35000,
      0,
      Errors.RevertStatus.Success,
      false
    );

    assertEq(multiSignature.threshold(), 2);
  }

  function test_changeThreshold(uint16 newThreshold) public {
    address[] memory owners = new address[](3);
    uint256[] memory ownersPk = new uint256[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    createMultiSig(owner1, owners, 2);
    ownersPk[0] = 1;
    ownersPk[1] = 2;
    ownersPk[2] = 3;

    generateSignatures_and_execTransaction(
      owner1,
      ownersPk,
      address(multiSignature),
      0,
      buildData_changeThreshold(newThreshold),
      35000,
      0,
      Errors.RevertStatus.Success,
      newThreshold == 0 || newThreshold > multiSignature.ownerCount() ? false : true
    );

    assertEq(multiSignature.threshold(), newThreshold == 0 || newThreshold > multiSignature.ownerCount() ? 2 : newThreshold);
  }

  function test_changeThreshold_with_assume(uint16 newThreshold) public {
    vm.assume(newThreshold > 0 && newThreshold < 4);

    address[] memory owners = new address[](3);
    uint256[] memory ownersPk = new uint256[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    createMultiSig(owner1, owners, 2);
    ownersPk[0] = 1;
    ownersPk[1] = 2;
    ownersPk[2] = 3;

    generateSignatures_and_execTransaction(
      owner1,
      ownersPk,
      address(multiSignature),
      0,
      buildData_changeThreshold(newThreshold),
      35000,
      0,
      Errors.RevertStatus.Success,
      true
    );

    assertEq(multiSignature.threshold(), newThreshold);
  }

  function test_changeThreshold_with_synamicOwners_assume(uint16 ownerCount, uint16 newThreshold) public {
    vm.assume(ownerCount > 0 && ownerCount < 200);
    vm.assume(newThreshold > 0 && newThreshold <= ownerCount);

    address[] memory owners = new address[](ownerCount);
    uint256[] memory ownersPk = new uint256[](ownerCount);

    for (uint16 i = 0; i < ownerCount; i++) {
      owners[i] = vm.addr(i + 1);
      ownersPk[i] = i + 1;
    }
    createMultiSig(owner1, owners, newThreshold);

    generateSignatures_and_execTransaction(
      owner1,
      ownersPk,
      address(multiSignature),
      0,
      buildData_changeThreshold(newThreshold),
      35000,
      0,
      Errors.RevertStatus.Success,
      true
    );

    assertEq(multiSignature.threshold(), newThreshold);
  }

  function test_multipleRequests_addOwner() public {
    address[] memory owners = new address[](3);
    uint256[] memory ownersPk = new uint256[](3);
    owners[0] = owner1;
    owners[1] = owner2;
    owners[2] = owner3;
    createMultiSig(owner1, owners, 2);
    ownersPk[0] = 1;
    ownersPk[1] = 2;
    ownersPk[2] = 3;

    address[] memory tos = new address[](2);
    uint256[] memory values = new uint256[](2);
    bytes[] memory datas = new bytes[](2);
    uint256[] memory txnGas = new uint256[](2);

    tos[0] = address(multiSignature);
    tos[1] = address(multiSignature);

    values[0] = 0;
    values[1] = 0;

    datas[0] = buildData_addOwner(notOwner1);
    datas[1] = buildData_addOwner(notOwner2);

    txnGas[0] = 35000;
    txnGas[1] = 35000;

    bytes memory data = buildData_multipleRequests(tos, values, datas, txnGas, false);

    // generateSignatures_and_execTransaction(owner1, ownersPk, address(multiSignature), 0, data, 70000, 0, Errors.RevertStatus.Success, true);

    // assertTrue(multiSignature.isOwner(notOwner1));
    // assertTrue(multiSignature.isOwner(notOwner2));
  }
}
