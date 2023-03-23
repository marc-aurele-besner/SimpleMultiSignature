// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract SimpleMultiSignature {
  string public constant NAME = 'SimpleMultiSignature';
  string public constant VERSION = '0.0.1';
  
  uint16 private _threshold;
  uint16 private _ownerCount;

  mapping(address => bool) private _owners;
  mapping(uint256 => bool) private _nonceUsed;
  mapping(uint256 => mapping(address => bool)) private _nonceOwnerUsed;

  event OwnerAdded();
  event OwnerRemoved();
  event ReveiveEther();
  event TransactionExecuted();
  event TransactionFailled();

  modifer isMultiSig() {
      require(msg.sender == address(this), 'SimpleMultiSignature: Only possible via multisig request');
      _;
  }

  function isOwner(address userAddress) public view returns (bool) {}

  function threshold() public view returns (uint256) {}

  function addOwner(address userAddress) internal returns (bool) {}

  function removeOwner(address userAddress) internal returns (bool) {}

  function changeOwner(address oldOwner, address newOwner) internal returns (bool) {
    require(_owners[oldOwner], 'SimpleMultiSignature: Old owner must be an owner');
    require(!_owners[newOwner], 'SimpleMultiSignature: New owner must not be an owner');
    require(newOwner != address(0), 'SimpleMultiSignature: New owner must not be the zero address');
    _owners[oldOwner] = false;
    _owners[newOwner] = true;
  }

  function changeThreshold(uint256 newThreshold) internal returns (bool) {}

  reveive() external payable {}

  function execTransaction(
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    bytes memory signatures
  ) returns (bool)

  function isSignaturesValid(
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    bytes memory signatures
    ) external view {};
}
