const { ethers, network, addressBook } = require('hardhat');
const fs = require('fs');

async function main() {
  const REQUESTS_FOLDER_PATH = './transactionRequests';
  // const MULTISIG_ADDRESS = '0x10C3e6FbdFBb43459B13B6957f77097EE5aC7931'; // (1st contract with 3 threshold)
  const MULTISIG_ADDRESS = '0x8FcB9b721a19111B9486D57B4fb3131218c1e784'; // (2nd contract with 2 threshold)

  const OWNER1 = process.env.OWNER1;
  const OWNER2 = process.env.OWNER2;
  const OWNER3 = process.env.OWNER3;
  const OWNER4 = process.env.OWNER4;
  const OWNER5 = process.env.OWNER5;

  // Prepare a transaction in a way that anyone can read it and use the data to sign the transaction and produce a signature

  const MockERC20 = await ethers.getContractFactory('MockERC20');
  const MockERC20_ADDRESS = '0xF80c6aa0E21D32D89BaF72F39a0128A7527FB0C5';

  const SimpleMultiSignature = await ethers.getContractFactory('SimpleMultiSignature');

  // const newOwnerAddress = ethers.constants.AddressZero;
  const call1 = MockERC20.interface.encodeFunctionData('mint(address,uint256)', [MULTISIG_ADDRESS, ethers.utils.parseEther('1000')]);
  const call2 = MockERC20.interface.encodeFunctionData('mint(address,uint256)', [OWNER1, ethers.utils.parseEther('100')]);
  const call3 = MockERC20.interface.encodeFunctionData('mint(address,uint256)', [OWNER2, ethers.utils.parseEther('100')]);
  const call4 = MockERC20.interface.encodeFunctionData('mint(address,uint256)', [OWNER3, ethers.utils.parseEther('100')]);
  const call5 = MockERC20.interface.encodeFunctionData('mint(address,uint256)', [OWNER4, ethers.utils.parseEther('100')]);
  const call6 = MockERC20.interface.encodeFunctionData('mint(address,uint256)', [OWNER5, ethers.utils.parseEther('100')]);

  const data = SimpleMultiSignature.interface.encodeFunctionData('multipleRequests(address[],uint256[],bytes[],uint256[],bool)', [
    [MockERC20_ADDRESS, MockERC20_ADDRESS, MockERC20_ADDRESS, MockERC20_ADDRESS, MockERC20_ADDRESS, MockERC20_ADDRESS], // to
    [0, 0, 0, 0, 0, 0], // value
    [call1, call2, call3, call4, call5, call6], // data
    [150000, 150000, 150000, 150000, 150000, 150000], // gas
    false // execute
  ]);

  const NEW_REQUEST = {
    multiSignature: MULTISIG_ADDRESS, // Multi signature address
    targetAddress: MULTISIG_ADDRESS, // to, target contract or receiver
    transactionValue: '0', // ethereum to be sent (if any)
    transactionData: data, // Data (empty if sending ethereum)
    txnGas: 900000, // Total gas to be use by the request
    txNonce: 109, // Nonce to use (need to be unique)
    ownersSigners: [], // List of owners that signed the request
    signatures: [], // List of signatures
    signaturesConcatenated: '' // Signature concatenated (to be use to execute transaction)
  };

  // package the transaction in a object and save it as a json file in this repo
  if (fs.existsSync(REQUESTS_FOLDER_PATH + '/' + NEW_REQUEST.txNonce + '.json'))
    console.log('\x1b[33m', 'Request with same nonce already exist in ' + REQUESTS_FOLDER_PATH + ', please change the txNonce', '\x1b[0m');
  else {
    await fs.writeFileSync(REQUESTS_FOLDER_PATH + '/' + NEW_REQUEST.txNonce + '.json', JSON.stringify(NEW_REQUEST, null, 2));
    console.log('\x1b[32m', 'Multisig request saved in ' + REQUESTS_FOLDER_PATH + ', please commit to GitHub this request', '\x1b[0m');
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
