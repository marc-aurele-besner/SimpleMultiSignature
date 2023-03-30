const { ethers } = require('hardhat');
const { expect } = require('chai');

const helper = require('./helper/functions');

const threshold = 3;

describe('Guillaume-test', function () {
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

      expect(await owner5.getBalance()).to.be.equal(ethers.utils.parseEther('10000'));

      await helper.execTransaction(simpleMultiSignature, owner2, [owner1, owner2, owner3], owner5.address, ethers.utils.parseEther('1'));

      expect(await owner5.getBalance()).to.be.equal(ethers.utils.parseEther('10000'));
    });

    it('Deploy contract and try to send 1 ethers from multisig (after funding the multisig)', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      await owner1.sendTransaction({ to: simpleMultiSignature.address, value: ethers.utils.parseEther('1') });
      expect(await owner5.getBalance()).to.be.equal(ethers.utils.parseEther('10000'));

      await helper.execTransaction(simpleMultiSignature, owner2, [owner1, owner2, owner3], owner5.address, ethers.utils.parseEther('1'));

      expect(await owner5.getBalance()).to.be.equal(ethers.utils.parseEther('10001'));
    });

    it('Deploy contract and try to add 1 new owner', async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.false;

      await helper.addOwner(simpleMultiSignature, owner2, [owner1, owner2, owner3], notOwner1.address);

      expect(await simpleMultiSignature.isOwner(notOwner1.address)).to.be.true;
    });

    it("Deploy contract and attempt to remove an owner", async function () {
      const { simpleMultiSignature, owner1, owner2, owner3, owner4, owner5, notOwner1, notOwner2, notOwner3, notOwner4, notOwner5 } = await deployContract();

      expect(await simpleMultiSignature.isOwner(owner5.address)).to.be.true;

      await helper.removeOwner(simpleMultiSignature, owner2, [owner1, owner2, owner3], owner5.address);

      expect(await simpleMultiSignature.isOwner(owner5.address)).to.be.false;
    });
  });
});
