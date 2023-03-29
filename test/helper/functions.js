const signature = require('./signatures');

const generateSignatures = async (contractAddress, owners, to, value, data, txnGas, nonce) => {
  let signatures = '0x';
  for (let i = 0; i < owners.length; i++) {
    const ownerSignature = await signature.signTransaction(contractAddress, owners[i], to, value, data, txnGas, nonce);
    signatures += String(ownerSignature).substring(2);
  }
  return signatures;
};

const execTransaction = async (contract, sender, owners, to, value = 0, data = '0x', txnGas = 35000, nonce = 0, error) => {
  const signatures = await generateSignatures(contract.address, owners, to, value, data, txnGas, nonce);

  let tx;
  if (error) {
    tx = await expect(await contract.connect(sender).execTransaction(to, value, data, txnGas, nonce, signatures)).to.revert;
  } else {
    tx = await contract.connect(sender).execTransaction(to, value, data, txnGas, nonce, signatures);
  }
  const receipt = await tx.wait();
  return receipt;
};

const addOwner = async (contract, sender, owners, newOwnerAddress, txnGas = 35000, nonce = 0, error) => {
  const data = contract.interface.encodeFunctionData('addOwner(address)', [newOwnerAddress]);

  const receipt = await execTransaction(contract, sender, owners, contract.address, undefined, data, txnGas, nonce, error);
  return receipt;
};

module.exports = {
  generateSignatures,
  execTransaction,
  addOwner
};
