const { ethers, network, addressBook } = require('hardhat');

async function deployContract() {
  const [deployer] = await ethers.getSigners();

  const THRESHOLD = 1;

  const OWNER1 = process.env.OWNER1;
  const OWNER2 = process.env.OWNER2;
  const OWNER3 = process.env.OWNER3;
  const OWNER4 = process.env.OWNER4;
  const OWNER5 = process.env.OWNER5;

  if (!OWNER1 || !OWNER2 || !OWNER3 || !OWNER4 || !OWNER5) {
    throw new Error('Please set OWNER1, OWNER2, OWNER3, OWNER4, OWNER5 in .env file');
  }

  const SimpleMultiSignature = await ethers.getContractFactory('SimpleMultiSignature');
  const simpleMultiSignature = await SimpleMultiSignature.connect(deployer).deploy([OWNER1, OWNER2, OWNER3, OWNER4, OWNER5], THRESHOLD);

  await simpleMultiSignature.deployed();

  await addressBook.saveContract(
    'SimpleMultiSignature',
    simpleMultiSignature.address,
    network.name,
    deployer.address,
    network.config.chainId,
    simpleMultiSignature.deployTransaction.blockHash,
    simpleMultiSignature.deployTransaction.blockNumber,
    'Simple Multi Signature',
    {
      owners: [OWNER1, OWNER2, OWNER3, OWNER4, OWNER5],
      threshold: THRESHOLD
    },
    false
  );

  return { simpleMultiSignature };
}

async function main() {
  const { simpleMultiSignature } = await deployContract();

  console.log(`Contract deployed at ${simpleMultiSignature.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
