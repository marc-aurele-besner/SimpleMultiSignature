const { ethers, network } = require('hardhat');

async function main() {
  // Prepare a transaction in a way that anyone can read it and use the data to sign the transaction and produce a signature

  // contractAddress, to, value, data, txnGas, nonce

  const NEW_REQUEST = {
    multiSignature: ''
  };

  // package the transacton in a object and save it as a json file in this repo
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
