// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/utils/cryptography/EIP712.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol';

contract SimpleMultiSignature is EIP712, IERC721ReceiverUpgradeable {
  uint16 private _threshold;
  uint16 private _ownerCount;

  bytes32 private constant _EXECUTE_TRANSACTION_TYPEHASH = keccak256('ExecuteTransaction(address to,uint256 value,bytes data,uint256 txnGas,uint256 nonce)');

  mapping(address => bool) private _owners;
  mapping(uint256 => bool) private _nonceUsed;
  mapping(uint256 => mapping(address => bool)) private _nonceOwnerUsed;

  bool private _paused;

  event OwnerAdded(address indexed owner);
  event OwnerRemoved(address indexed owner);
  event ReveiveEther();
  event TransactionExecuted(address indexed to, bytes indexed data, uint256 value, uint256 txnGas, uint256 gasConsumed);
  event TransactionFailled(address indexed to, bytes indexed data, uint256 value, uint256 txnGas, uint256 gasConsumed);
  event TransactionCancelled(uint256 nonce);
  event ContractPaused();
  event ContractUnpaused();

  modifier isMultiSig() {
    require(msg.sender == address(this), 'SimpleMultiSignature: Only possible via multisig request');
    _;
  }

  constructor(address[] memory owners_, uint16 threshold_) EIP712(name(), version()) {
    for (uint16 i; i < owners_.length; i++) {
      _addOwner(owners_[i]);
    }
    _ownerCount = uint16(owners_.length);
    _changeThreshold(threshold_);
    _paused = false;
  }

  // Return the name as a string
  function name() public pure returns (string memory) {
    return 'SimpleMultiSignature';
  }

  // Return the version as a string
  function version() public pure returns (string memory) {
    return '0.0.1';
  }

  function threshold() public view returns (uint16) {
    return _threshold;
  }

  function ownerCount() public view returns (uint16) {
    return _ownerCount;
  }

  function isOwner(address userAddress) public view returns (bool) {
    return _owners[userAddress];
  }

  function isNonceUsed(uint256 nonce) public view returns (bool) {
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
    uint256 nonce,
    bytes memory signatures
  ) external returns (bool success) {
    // Check that the contract is not paused
    require(!_paused, 'SimpleMultiSignature: Contract is paused');

    // Verify that nonce has not been used
    require(!_nonceUsed[nonce], 'SimpleMultiSignature: Nonce already used');

    bytes32 hash = _generateHash(to, value, data, txnGas, nonce);

    uint16 threshold_ = _threshold;

    // Verify that there is at least the amount of owner signatures to meet treshold
    require(signatures.length >= 65 * threshold_, 'SimpleMultiSignature: Not enought owner to execute');

    for (uint16 i; i < threshold_; ) {
      address owner = _getOwnerFromSignature(hash, signatures, i);

      // Verify if owner already sign this specific transaction
      require(!_nonceOwnerUsed[nonce][owner], 'SimpleMultiSignature: Owner already sign this tx');
      // Assign to storage mapping that the owner signed this transaction
      _nonceOwnerUsed[nonce][owner] = true;

      require(isOwner(owner), 'SimpleMultiSignature: Signature is not valide');
      unchecked {
        ++i;
      }
    }

    // Assign to storage that nonce has been use for this transaction
    _nonceUsed[nonce] = true;

    uint256 gas = gasleft();
    // Execute the transaction after all verification
    success = _executeCall(to, value, data, txnGas);

    uint256 gasLeft = gasleft();
    uint256 gasConsumed = gas - gasLeft;

    if (gasConsumed <= txnGas && success) {
      emit TransactionExecuted(to, data, value, txnGas, gasConsumed);
    } else {
      emit TransactionFailled(to, data, value, txnGas, gasConsumed);
    }
  }

  function isSignaturesValid(
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    uint256 nonce,
    bytes memory signatures
  ) external view returns (bool) {
    // Verify that nonce has not been used
    require(!_nonceUsed[nonce], 'SimpleMultiSignature: Nonce already used');

    bytes32 hash = _generateHash(to, value, data, txnGas, nonce);

    uint16 threshold_ = _threshold;

    // Verify that there is at least the amount of owner signatures to meet treshold
    require(signatures.length >= 65 * threshold_, 'SimpleMultiSignature: Not enought owner to execute');

    for (uint16 i; i < threshold_; ) {
      address owner = _getOwnerFromSignature(hash, signatures, i);

      // Verify if owner already sign this specific transaction
      require(!_nonceOwnerUsed[nonce][owner], 'SimpleMultiSignature: Owner already sign this tx');

      require(isOwner(owner), 'SimpleMultiSignature: Signature is not valide');
      unchecked {
        ++i;
      }
    }
    return true;
  }

  function _generateHash(address to, uint256 value, bytes memory data, uint256 txnGas, uint256 nonce) private view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(_EXECUTE_TRANSACTION_TYPEHASH, to, value, keccak256(data), txnGas, nonce))); //, to, value, data, txnGas, nonce
  }

  function _executeCall(address to, uint256 value, bytes memory data, uint256 txnGas) private returns (bool success) {
    assembly {
      success := call(
        txnGas, // Gas for the transaction
        to, // Address we are calling
        value, // Ethereum value sent with the transaction
        add(data, 0x20), // Inputs
        mload(data), // Inputs length
        0, // Output location in storage
        0 // Outputs lenght
      )
    }
  }

  function _getOwnerFromSignature(bytes32 hash, bytes memory signatures, uint256 index) private pure returns (address owner) {
    uint8 v;
    bytes32 r;
    bytes32 s;
    assembly {
      let signature := mul(0x41, index)
      r := mload(add(signatures, add(signature, 32)))
      s := mload(add(signatures, add(signature, 64)))
      v := and(mload(add(signatures, add(signature, 65))), 255)
    }
    owner = ecrecover(hash, v, r, s);
  }

  function multipleRequests(
    address[] memory tos,
    uint256[] memory values,
    bytes[] memory datas,
    uint256[] memory txnGas,
    bool stopIfFail
  ) public isMultiSig returns (bool success) {
    uint256 length = tos.length;
    for (uint256 i; i < length; ) {
      success = _executeCall(tos[i], values[i], datas[i], txnGas[i]);
      if (stopIfFail && !success) revert('SimpleMultiSignature: One of the multicall request has fail');
      unchecked {
        ++i;
      }
    }
  }

  function _addOwner(address userAddress) internal returns (bool) {
    require(!_owners[userAddress], 'SimpleMultiSignature: Address is already an owner');

    _owners[userAddress] = true;
    _ownerCount++;

    emit OwnerAdded(userAddress);
    return true;
  }

  function addOwner(address userAddress) public isMultiSig returns (bool) {
    return _addOwner(userAddress);
  }

  function removeOwner(address userAddress) public isMultiSig returns (bool) {
    require(_owners[userAddress], 'SimpleMultiSignature: Address is not an owner');
    _owners[userAddress] = false;
    _ownerCount--;
    emit OwnerRemoved(userAddress);
    return true;
  }

  function changeOwner(address oldOwner, address newOwner) public isMultiSig returns (bool) {
    require(_owners[oldOwner], 'SimpleMultiSignature: Old owner must be an owner');
    require(!_owners[newOwner], 'SimpleMultiSignature: New owner must not be an owner');
    require(newOwner != address(0), 'SimpleMultiSignature: New owner must not be the zero address');

    _owners[oldOwner] = false;
    _owners[newOwner] = true;

    emit OwnerRemoved(oldOwner);
    emit OwnerAdded(newOwner);
    return true;
  }

  function _changeThreshold(uint16 newThreshold) internal returns (bool) {
    require(newThreshold > 0);
    require(newThreshold <= _ownerCount);

    _threshold = newThreshold;

    return true;
  }

  function changeThreshold(uint16 newThreshold) public isMultiSig returns (bool) {
    return _changeThreshold(newThreshold);
  }

  function cancelTransaction(uint256 nonce) external isMultiSig {
    require(!_paused, 'SimpleMultiSignature: Contract is paused');
    require(_nonceUsed[nonce] == false, 'SimpleMultiSignature: Nonce already used');
    _nonceUsed[nonce] = true;
    emit TransactionCancelled(nonce);
  }

  function pauseContract() external isMultiSig {
    _paused = true;
    emit ContractPaused();
  }

  function unpauseContract() external isMultiSig {
    _paused = false;
    emit ContractUnpaused();
  }

  function isPaused() external view returns (bool) {
    return _paused;
  }

  function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
    return this.onERC721Received.selector;
  }

  receive() external payable {}
}
