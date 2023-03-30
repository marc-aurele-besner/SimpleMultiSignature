const { ethers } = require('hardhat');
const { expect } = require('chai');

const helper = require('./helper/functions');

const threshold = 3;

describe('SimpleMultiSignature', function () {
  async function deployContract() {
    const [owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5] = await ethers.getSigners();

    const SimpleMultiSignature = await ethers.getContractFactory('SimpleMultiSignature');
    const simpleMultiSignature = await SimpleMultiSignature.deploy([owner1.address, owner2.address, owner3.address, owner4.address, owner5.address], threshold);

    return { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 };
  }

  describe('Deployment', function () {
    it('Deploy contract and verify if owner and threshold are set', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      expect(await simpleMultiSignature.isOwner(owner1.address)).to.be.true;
      expect(await simpleMultiSignature.isOwner(owner2.address)).to.be.true;
      expect(await simpleMultiSignature.isOwner(owner3.address)).to.be.true;
      expect(await simpleMultiSignature.isOwner(owner4.address)).to.be.true;
      expect(await simpleMultiSignature.isOwner(owner5.address)).to.be.true;

      expect(await simpleMultiSignature.threshold()).to.be.equal(threshold);

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner2.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner3.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner4.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner5.address)).to.be.false;
    });

    it('Deploy contract and try to send 1 ethers from multisig (without the funds)', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      const owner5Balance = await owner5.getBalance();

      await helper.execTransaction(simpleMultiSignature, owner2, [owner1, owner2, owner3], owner5.address, ethers.utils.parseEther('1'));

      expect(await owner5.getBalance()).to.be.equal(owner5Balance);
    });

    it('Deploy contract and try to send 1 ethers from multisig (after funding the multisig)', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      const owner5Balance = await owner5.getBalance();

      await owner1.sendTransaction({ to: simpleMultiSignature.address, value: ethers.utils.parseEther('1') });

      await helper.execTransaction(simpleMultiSignature, owner2, [owner1, owner2, owner3], owner5.address, ethers.utils.parseEther('1'));

      expect(await owner5.getBalance()).to.be.equal(owner5Balance.add(ethers.utils.parseEther('1')));
    });

    it('Deploy contract and try to add 1 new owner', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.false;

      await helper.addOwner(simpleMultiSignature, owner2, [owner1, owner2, owner3], notOwner1.address);

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.true;
    });

    it('Deploy contract and try to add 3 new owners', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner2.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner3.address)).to.be.false;

      const tos = [simpleMultiSignature.address, simpleMultiSignature.address, simpleMultiSignature.address];
      const values = [0, 0, 0];
      const datas = [
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [notOwner1.address]),
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [notOwner2.address]),
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [notOwner3.address])
      ];
      const txnGass = [35000, 35000, 35000];

      const receipt = await helper.multipleRequests(simpleMultiSignature, owner3, [owner1, owner2, owner3], tos, values, datas, txnGass);

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.true;
      expect(await simpleMultiSignature.isOwner(notOwner2.address)).to.be.true;
      expect(await simpleMultiSignature.isOwner(notOwner3.address)).to.be.true;
    });

    it('Deploy contract and try to add 3 new owners (1 of them is already an owner (multiple request set to fail if 1 tx fail))', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner2.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner3.address)).to.be.false;

      const tos = [simpleMultiSignature.address, simpleMultiSignature.address, simpleMultiSignature.address];
      const values = [0, 0, 0];
      const datas = [
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [notOwner1.address]),
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [owner1.address]),
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [notOwner3.address])
      ];
      const txnGass = [35000, 35000, 35000];

      await helper.multipleRequests(simpleMultiSignature, owner3, [owner1, owner2, owner3], tos, values, datas, txnGass);

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner2.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner3.address)).to.be.false;
    });

    it('Deploy contract and try to add 3 new owners (1 of them is already an owner (multiple request set to not fail if 1 tx fail))', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner2.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner3.address)).to.be.false;

      const tos = [simpleMultiSignature.address, simpleMultiSignature.address, simpleMultiSignature.address];
      const values = [0, 0, 0];
      const datas = [
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [notOwner1.address]),
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [owner1.address]),
        simpleMultiSignature.interface.encodeFunctionData('addOwner(address)', [notOwner3.address])
      ];
      const txnGass = [35000, 35000, 35000];

      const receipt = await helper.multipleRequests(simpleMultiSignature, owner3, [owner1, owner2, owner3], tos, values, datas, txnGass, false);

      expect(receipt.status).to.be.equal(1);
      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.true;
      expect(await simpleMultiSignature.isOwner(owner1.address)).to.be.true;
      expect(await simpleMultiSignature.isOwner(notOwner2.address)).to.be.false;
      expect(await simpleMultiSignature.isOwner(notOwner3.address)).to.be.true;
    });
  });
});
