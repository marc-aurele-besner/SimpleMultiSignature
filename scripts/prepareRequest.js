const { ethers, network, addressBook } = require('hardhat');
const fs = require('fs');

async function main() {
  const REQUESTS_FOLDER_PATH = './transactionRequests';
  let MULTISIG_ADDRESS = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0'; // await addressBook.retrieveContract('SimpleMultiSignature', network.name);
  if (!MULTISIG_ADDRESS) MULTISIG_ADDRESS = ethers.constants.AddressZero;

  // Prepare a transaction in a way that anyone can read it and use the data to sign the transaction and produce a signature

  const SimpleMultiSignature = await ethers.getContractFactory('SimpleMultiSignature');

  const newOwnerAddress = ethers.constants.AddressZero;
  const data = SimpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [newOwnerAddress]);

  const NEW_REQUEST = {
    multiSignature: MULTISIG_ADDRESS, // Multi signature address
    targetAddress: MULTISIG_ADDRESS, // to, target contract or receiver
    transactionValue: '0', // ethereum to be sent (if any)
    transactionData: data, // Data (empty if sending ethereum)
    txnGas: 35000, // Total gas to be use by the request
    txNonce: 0, // Nonce to use (need to be unique)
    ownersSigners: [], // List of owners that signed the request
    signatures: [], // List of signatures
    signaturesConcatenated: '' // Signature concatenated (to be use to execute transaction)
  };

  // package the transaction in a object and save it as a json file in this repo
  if (fs.existsSync(REQUESTS_FOLDER_PATH + '/' + NEW_REQUEST.txNonce + '.json'))
    console.log('\x1b[33m', 'Request with same nonce already exist in ' + REQUESTS_FOLDER_PATH + ', please change the txNonce', '\x1b[0m');
  else {
    await fs.writeFileSync(REQUESTS_FOLDER_PATH + '/' + NEW_REQUEST.txNonce + '.json', JSON.stringify(NEW_REQUEST));
    console.log('\x1b[32m', 'Multisig request saved in ' + REQUESTS_FOLDER_PATH + ', please commit to GitHub this request', '\x1b[0m');
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
