// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract SimpleMultiSignature {
  
  uint16 private _threshold;
  uint16 private _ownerCount;

  mapping(address => bool) private _owners;
  mapping(uint256 => bool) private _nonceUsed;
  mapping(uint256 => mapping(address => bool)) private _nonceOwnerUsed;

  event OwnerAdded(address indexed owner);
  event OwnerRemoved(address indexed owner);
  event ReveiveEther();
  event TransactionExecuted();
  event TransactionFailled();

  modifer isMultiSig() {
      require(msg.sender == address(this), 'SimpleMultiSignature: Only possible via multisig request');
      _;
  }

  function isOwner(address userAddress) public view returns (bool) {
    return _owners[userAddress];
  }
 
  // Return the name as a string
  function name() public pure returns (string memory) {
    return 'SimpleMultiSignature';
  }

  // Return the version as a string
  function version() public pure returns (string memory) {
    return '0.0.1';
  }


  function threshold() public view returns (uint256) {
    return _threshold;
  }

  function addOwner(address userAddress) internal isMultiSig returns (bool) {
    require(!_owners[userAddress], "SimpleMultiSignature: Address is already an owner");
    _owners[userAddress] = true;
    _ownerCount++;
    emit OwnerAdded(userAddress);
    return true;
  }

  function removeOwner(address userAddress) internal isMultiSig returns (bool) {
    require(_owners[userAddress], "SimpleMultiSignature: Address is not an owner");
    _owners[userAddress] = false;
    _ownerCount--;
    emit OwnerRemoved(userAddress);
    return true;
  }

  function changeOwner(address oldOwner, address newOwner) internal returns (bool) {
    require(_owners[oldOwner], 'SimpleMultiSignature: Old owner must be an owner');
    require(!_owners[newOwner], 'SimpleMultiSignature: New owner must not be an owner');
    require(newOwner != address(0), 'SimpleMultiSignature: New owner must not be the zero address');
    _owners[oldOwner] = false;
    emit OwnerRemoved(oldOwner);
    _owners[newOwner] = true;
    emit OwnerAdded(newOwner);
    return true;
  }

  function changeThreshold(uint16 newThreshold) internal isMultiSig returns (bool) {
    require(newThreshold > 0);
    require(newThreshold <= _ownerCount);
    _threshold = newThreshold;
    return true;
  }

  receive() external payable {}

  function ownerCount() public view returns (uint16) {
    return _ownerCount;
  }

  function isNonceUsed(uint256 nonce) punlic view returns (bool) {
    return _nonceUsed[nonce];
  }

  function isNonceUsedByUser(uint256 nonce, address userAddress) public view returns (bool) {
    return _nonceOwnerUsed[nonce][userAddress];
  }

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
