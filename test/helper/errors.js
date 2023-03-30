module.exports = {
  ONLY_POSSIBLE_MULTISIG_REQ: 'SimpleMultiSignature: Only possible via multisig request',
  NONCE_ALREADY_USED: 'SimpleMultiSignature: Nonce already used',
  NOT_ENOUGH_OWNER: 'SimpleMultiSignature: Not enough owner to execute',
  OWNER_ALREADY_SIGN: 'SimpleMultiSignature: Owner already sign this tx',
  SIGNATURE_NOT_VALID: 'SimpleMultiSignature: Signature is not valid',
  MULTICALL_FAIL: 'SimpleMultiSignature: One of the multicall request has fail',
  ADDRESS_ALREADY_OWNER: 'SimpleMultiSignature: Address is already an owner',
  ADDRESS_NOT_OWNER: 'SimpleMultiSignature: Address is not an owner',
  OLD_OWNER_MUST_BE_OWNER: 'SimpleMultiSignature: Old owner must be an owner',
  OLD_OWNER_MUST_NOT_BE_OWNER: 'SimpleMultiSignature: New owner must not be an owner',
  NEW_OWNER_MUST_NOT_BE_ZERO_ADDRESS: 'SimpleMultiSignature: New owner must not be the zero address'
};
