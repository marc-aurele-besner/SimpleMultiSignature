// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract SimpleMultiSignature {
  string public constant NAME = 'SimpleMultiSignature';
  string public constant VERSION = '0.0.1';

  function isOwner(address userAddress) public view returns (bool) {}

  function threshold() public view returns (uint256) {}

  function addOwner(address userAddress) internal returns (bool) {}

  function removeOwner(address userAddress) internal returns (bool) {}

  function changeOwner(address newOwner, address lastOwner) internal returns (bool) {}

  function changeThreshold(uint256 newThreshold) internal returns (bool) {}

  function reveive() external payable {}

  function execTransaction(
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    bytes memory signatures
  ) returns (bool)
}
