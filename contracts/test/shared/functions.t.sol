// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'foundry-test-utility/contracts/utils/console.sol';
import { Signatures } from 'foundry-test-utility/contracts/shared/signatures.sol';
import { Constants } from './constants.t.sol';
import { Errors } from './errors.t.sol';
import { TestStorage } from './testStorage.t.sol';
import { SimpleMultiSignature } from '../../SimpleMultiSignature.sol';

contract Functions is Constants, Errors, TestStorage, Signatures {
  SimpleMultiSignature public multiSignature;
  enum TestType {
    Standard
  }

  event OwnerAdded(address indexed owner);
  event OwnerRemoved(address indexed owner);
  event ReveiveEther();
  event TransactionExecuted(address indexed to, bytes indexed data, uint256 value, uint256 txnGas, uint256 gasConsumed);
  event TransactionFailled(address indexed to, bytes indexed data, uint256 value, uint256 txnGas, uint256 gasConsumed);

  function createMultiSig(address sender_, address[] memory owners_, uint16 threshold_, Errors.RevertStatus revertType_) internal {
    vm.prank(sender_);
    verify_revertCall(revertType_);
    multiSignature = new SimpleMultiSignature(owners_, threshold_);

    if (revertType_ == Errors.RevertStatus.Success) {
      assertEq(multiSignature.name(), 'SimpleMultiSignature');
      assertEq(multiSignature.version(), '0.0.1');
      assertEq(multiSignature.threshold(), threshold_);
      uint256 ownersLength = owners_.length;
      assertEq(multiSignature.ownerCount(), ownersLength);
      for (uint256 i = 0; i < ownersLength; ) {
        assertTrue(multiSignature.isOwner(owners_[i]));
        unchecked {
          ++i;
        }
      }
    }
  }

  function createMultiSig(address sender_, address[] memory owners_, uint16 threshold_) internal {
    createMultiSig(sender_, owners_, threshold_, Errors.RevertStatus.Success);
  }

  function execTransaction(
    address sender_,
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    uint256 nonce,
    bytes memory signatures,
    Errors.RevertStatus revertType_,
    bool trasactionSuccess
  ) internal {
    if (revertType_ == Errors.RevertStatus.Success && trasactionSuccess) {
      vm.expectEmit(true, true, true, false);
      emit TransactionExecuted(to, data, value, txnGas, 0);
    }
    if (revertType_ == Errors.RevertStatus.Success && !trasactionSuccess) {
      vm.expectEmit(true, true, true, false);
      emit TransactionFailled(to, data, value, txnGas, 0);
    }
    vm.prank(sender_);
    verify_revertCall(revertType_);
    multiSignature.execTransaction(to, value, data, txnGas, nonce, signatures);
  }

  function execTransaction(
    address sender_,
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    uint256 nonce,
    bytes memory signatures,
    bool trasactionSuccess
  ) internal {
    execTransaction(sender_, to, value, data, txnGas, nonce, signatures, Errors.RevertStatus.Success, trasactionSuccess);
  }

  function execTransaction(address sender_, address to, uint256 value, bytes memory data, uint256 txnGas, uint256 nonce, bytes memory signatures) internal {
    execTransaction(sender_, to, value, data, txnGas, nonce, signatures, Errors.RevertStatus.Success, true);
  }

  function generateHash(address to, uint256 value, bytes memory data, uint256 txnGas, uint256 nonce) private view returns (bytes32) {
    return
      keccak256(
        abi.encode(keccak256('ExecuteTransaction(address to,uint256 value,bytes data,uint256 txnGas,uint256 nonce)'), to, value, keccak256(data), txnGas, nonce)
      );
  }

  function generateSignatures(
    uint256[] memory ownersPk,
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    uint256 nonce
  ) internal returns (bytes memory signatures) {
    bytes32 domainSeparator = keccak256(
      abi.encode(
        keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
        keccak256(bytes(CONTRACT_NAME)),
        keccak256(bytes(CONTRACT_VERSION)),
        block.chainid,
        address(multiSignature)
      )
    );

    bytes32 structHash = generateHash(to, value, data, txnGas, nonce);

    for (uint160 i; i < ownersPk.length; i++) {
      (uint8 v, bytes32 r, bytes32 s) = signature_signHash(ownersPk[i], SignatureType.eip712, domainSeparator, structHash);
      signatures = abi.encodePacked(signatures, abi.encodePacked(r, s, v));
    }
  }

  function generateSignatures_and_execTransaction(
    address sender_,
    uint256[] memory ownersPk,
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    uint256 nonce,
    Errors.RevertStatus revertType_,
    bool trasactionSuccess
  ) internal {
    bytes memory signatures = generateSignatures(ownersPk, to, value, data, txnGas, nonce);

    execTransaction(sender_, to, value, data, txnGas, nonce, signatures, revertType_, trasactionSuccess);
  }

  function generateSignatures_and_execTransaction(
    address sender_,
    uint256[] memory ownersPk,
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    uint256 nonce,
    bool trasactionSuccess
  ) internal {
    generateSignatures_and_execTransaction(sender_, ownersPk, to, value, data, txnGas, nonce, Errors.RevertStatus.Success, trasactionSuccess);
  }

  function addOwner(address sender_, address newOwner, Errors.RevertStatus revertType_) internal {
    uint16 ownerCount = multiSignature.ownerCount();

    if (revertType_ == Errors.RevertStatus.Success) {
      vm.expectEmit(true, true, true, true);
      emit OwnerAdded(newOwner);
    }
    vm.prank(sender_);
    verify_revertCall(revertType_);
    multiSignature.addOwner(newOwner);

    if (revertType_ == Errors.RevertStatus.Success) {
      assertTrue(multiSignature.isOwner(newOwner));
      assertEq(multiSignature.ownerCount(), ownerCount + 1);
    }
  }

  function addOwner(address sender_, address newOwner) internal {
    addOwner(sender_, newOwner, Errors.RevertStatus.Success);
  }

  function removeOwner(address sender_, address noMoreOwner, Errors.RevertStatus revertType_) internal {
    uint16 ownerCount = multiSignature.ownerCount();
    vm.prank(sender_);
    verify_revertCall(revertType_);
    multiSignature.removeOwner(noMoreOwner);

    if (revertType_ == Errors.RevertStatus.Success) {
      assertTrue(!multiSignature.isOwner(noMoreOwner));
      assertEq(multiSignature.ownerCount(), ownerCount - 1);
    }
  }

  function removeOwner(address sender_, address noMoreOwner) internal {
    removeOwner(sender_, noMoreOwner, Errors.RevertStatus.Success);
  }

  function changeOwner(address sender_, address oldOwner, address newOwner, Errors.RevertStatus revertType_) internal {
    uint16 ownerCount = multiSignature.ownerCount();
    vm.prank(sender_);
    verify_revertCall(revertType_);
    multiSignature.changeOwner(oldOwner, newOwner);

    if (revertType_ == Errors.RevertStatus.Success) {
      assertTrue(multiSignature.isOwner(newOwner));
      assertTrue(!multiSignature.isOwner(oldOwner));
      assertEq(multiSignature.ownerCount(), ownerCount);
    }
  }

  function changeOwner(address sender_, address oldOwner, address newOwner) internal {
    changeOwner(sender_, oldOwner, newOwner, Errors.RevertStatus.Success);
  }
}
