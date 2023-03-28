const signature = require('./signatures');

const generateSignature = async (contractAddress, owners, to, value, data, txnGas, nonce) => {
  let signatures = '0x';
  for (const i = 0; i < owners.length; i++) {
    const signature = await signature.signTransaction(contractAddress, owners[i], to, value, data, txnGas, nonce);
    signatures += signature.substring(2);
  }
  return signatures;
};

const execTransaction = async (contract, sender, owners, to, value, data = '0x', txnGas = 35000, nonce = 0, error) => {
  const signatures = await generateSignature(contract.address, owners, to, value, data, txnGas, nonce);

  if (error) {
    await expect(await contract.execTransaction(to, value, data, txnGas, nonce, signatures)).to.revert;
  } else {
    await contract.execTransaction(to, value, data, txnGas, nonce, signatures);
  }
};

module.exports = {
  generateSignature,
  execTransaction
};
