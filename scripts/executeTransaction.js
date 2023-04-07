const { ethers, network } = require('hardhat');

async function main() {
  // Take the transaction request object and the signatures and execute the transaction onchain
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
