const { expect } = require('chai');

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

const changeOwner = async (contract, sender, owners, oldOwner, newOwner, txnGas = 35000, nonce = 0, error) => {
  const data = contract.interface.encodeFunctionData('changeOwner(address,address)', [oldOwner, newOwner]);

  const receipt = await execTransaction(contract, sender, owners, contract.address, undefined, data, txnGas, nonce, error);
  return receipt;
};

const removeOwner = async (contract, sender, owners, ownerAddressToRemove, txnGas = 35000, nonce = 0, error) => {
  const data = contract.interface.encodeFunctionData('removeOwner(address)', [ownerAddressToRemove]);

  const receipt = await execTransaction(contract, sender, owners, contract.address, undefined, data, txnGas, nonce, error);
  return receipt;
};

const multipleRequests = async (contract, sender, owners, tos, values = [0], datas = ['0x'], txnGass = [35000], stopIfFail = true, nonce = [0], error) => {
  let totalGas = 0;
  expect(tos.length).to.be.equal(values.length);
  expect(values.length).to.be.equal(datas.length);
  expect(datas.length).to.be.equal(txnGass.length);
  for (let i = 0; i < txnGass.length; i++) {
    totalGas += txnGass[i];
  }

  const data = contract.interface.encodeFunctionData('multipleRequests(address[],uint256[],bytes[],uint256[],bool)', [tos, values, datas, txnGass, stopIfFail]);

  const receipt = await execTransaction(contract, sender, owners, contract.address, undefined, data, totalGas, nonce, error);
  return receipt;
};

module.exports = {
  generateSignatures,
  execTransaction,
  addOwner,
  changeOwner,
  removeOwner,
  multipleRequests
};
