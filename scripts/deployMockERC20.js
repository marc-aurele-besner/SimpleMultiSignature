const { ethers, network, addressBook } = require('hardhat');

async function deployContract() {
  const [deployer] = await ethers.getSigners();
  const MockERC20 = await ethers.getContractFactory('MockERC20');
  const mockERC20 = await MockERC20.connect(deployer).deploy();

  await mockERC20.deployed();

  await addressBook.saveContract(
    'MockERC20',
    mockERC20.address,
    network.name,
    deployer.address,
    network.config.chainId,
    mockERC20.deployTransaction.blockHash,
    mockERC20.deployTransaction.blockNumber
  );

  return { mockERC20 };
}

async function main() {
  const { mockERC20 } = await deployContract();

  console.log(`Contract deployed at ${mockERC20.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
