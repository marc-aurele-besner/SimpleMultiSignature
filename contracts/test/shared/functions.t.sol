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
}
