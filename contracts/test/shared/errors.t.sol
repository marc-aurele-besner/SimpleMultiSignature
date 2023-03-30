// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Vm } from 'foundry-test-utility/contracts/utils/vm.sol';
import { DSTest } from 'foundry-test-utility/contracts/utils/test.sol';

contract Errors is DSTest {
  Vm public constant vm = Vm(address(uint160(uint256(keccak256('hevm cheat code')))));

  mapping(RevertStatus => string) private _errors;

  // Add a revert error to the enum of errors.
  enum RevertStatus {
    OnlyPossibleMultisigReq,
    NonceAlreadyUsed,
    NotEnoughtOwner,
    OwnerAlreadySign,
    SignatureNotValide,
    MulticallFail,
    AddressAlreadyOwner,
    AddressNotOwner,
    OldOwnerMustBeOwner,
    NewOwnerMustNotBeOwner,
    NewOwnerMustNotBeZeroAddress
  }

  // Associate your error with a revert message and add it to the mapping.
  constructor() {
    _errors[RevertStatus.OnlyPossibleMultisigReq] = 'SimpleMultiSignature: Only possible via multisig request';
    _errors[RevertStatus.NonceAlreadyUsed] = 'SimpleMultiSignature: Nonce already used';
    _errors[RevertStatus.NotEnoughtOwner] = 'SimpleMultiSignature: Not enought owner to execute';
    _errors[RevertStatus.OwnerAlreadySign] = 'SimpleMultiSignature: Owner already sign this tx';
    _errors[RevertStatus.SignatureNotValide] = 'SimpleMultiSignature: Signature is not valide';
    _errors[RevertStatus.MulticallFail] = 'SimpleMultiSignature: One of the multicall request has fail';
    _errors[RevertStatus.AddressAlreadyOwner] = 'SimpleMultiSignature: Address is already an owner';
    _errors[RevertStatus.AddressNotOwner] = 'SimpleMultiSignature: Address is not an owner';
    _errors[RevertStatus.OldOwnerMustBeOwner] = 'SimpleMultiSignature: Old owner must be an owner';
    _errors[RevertStatus.NewOwnerMustNotBeOwner] = 'SimpleMultiSignature: New owner must not be an owner';
    _errors[RevertStatus.NewOwnerMustNotBeZeroAddress] = 'SimpleMultiSignature: New owner must not be the zero address';
  }

  // Return the error message associated with the error.
  function _verify_revertCall(RevertStatus revertType_) internal view returns (string storage) {
    return _errors[revertType_];
  }

  // Expect a revert error if the revert type is not success.
  function verify_revertCall(RevertStatus revertType_) public {
    if (revertType_ != RevertStatus.Success && revertType_ != RevertStatus.SkipValidation) vm.expectRevert(bytes(_verify_revertCall(revertType_)));
  }
}
