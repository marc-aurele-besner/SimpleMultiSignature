// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import 'foundry-test-utility/contracts/utils/console.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import { Helper } from './shared/helper.t.sol';
import { Errors } from './shared/errors.t.sol';

contract SimpleNftMarketplace_test is Helper {
  uint8 LOG_LEVEL = 0;

  function setUp() public {
    initialize_helper(LOG_LEVEL);
  }
}
