// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'foundry-test-utility/contracts/utils/console.sol';
import { CheatCodes } from 'foundry-test-utility/contracts/utils/cheatcodes.sol';
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

  function initialize_tests(uint8 LOG_LEVEL_) public returns (SimpleMultiSignature) {
    // Set general test settings
    // _LOG_LEVEL = LOG_LEVEL_;
    // vm.roll(1);
    // vm.warp(100);
    // vm.startPrank(ADMIN);
    // vm.stopPrank();
    // vm.roll(block.number + 1);
    // vm.warp(block.timestamp + 100);
    // return multiSignature;
  }

  event OwnerAdded(address indexed owner);
  event OwnerRemoved(address indexed owner);
  event ReveiveEther();
  event TransactionExecuted(address indexed to, bytes indexed data, uint256 value, uint256 txnGas, uint256 gasConsumed);
  event TransactionFailled(address indexed to, bytes indexed data, uint256 value, uint256 txnGas, uint256 gasConsumed);
}
