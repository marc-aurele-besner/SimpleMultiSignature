// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract SimpleMultiSignature {
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

    function isSignaturesValid(
    address to,
    uint256 value,
    bytes memory data,
    uint256 txnGas,
    bytes memory signatures
    ) external view {};
}
