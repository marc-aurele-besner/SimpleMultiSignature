const { network } = require('hardhat');

const constants = require('../../constants');

const signTransaction = async (contractAddress, sourceWallet, to, value, data, txnGas, nonce) => {
  var signature = await sourceWallet._signTypedData(
    {
      name: constants.CONTRACT_NAME,
      version: constants.CONTRACT_VERSION,
      chainId: network.config.chainId,
      verifyingContract: contractAddress
    },
    {
      ExecuteTransaction: [
        {
          name: 'to',
          type: 'address'
        },
        {
          name: 'value',
          type: 'uint256'
        },
        {
          name: 'data',
          type: 'bytes'
        },
        {
          name: 'txnGas',
          type: 'uint256'
        },
        {
          name: 'nonce',
          type: 'uint256'
        }
      ]
    },
    {
      to,
      value,
      data,
      txnGas,
      nonce
    }
  );
  return ethers.utils.splitSignature(signature);
};

module.exports = {
  signTransaction
};
