const { ethers, network } = require('hardhat');

async function main() {
  // Take a transaction request object and sign it with the current private key in .env and return a signature
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
