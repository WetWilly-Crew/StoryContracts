const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('RoughWaters', function () {
  let admin;
  let user;
  let adminContract;
  let userContract;
  let sequenceCounter = 0;
  let choiceCounter = 0;

  before(async () => {
    const RoughWaters = await ethers.getContractFactory('RoughWaters');
    const signers = await ethers.getSigners();
    admin = signers[0];
    user = signers[1];
    const contract = await RoughWaters.deploy();
    adminContract = contract.connect(admin);
    userContract = adminContract.connect(user);

    await adminContract.deployed();
  });

  it('Cannot update scenario as a user', async () => {
    await expect(userContract.updateScenario(12, 12)).to.be.revertedWith('Ownable: caller is not the owner');
  });

  it('Cannot finish or skip a sequence before it was created as a user', async () => {
    await expect(userContract.finishSequence(1)).to.be.revertedWith('Game has not started');
    await expect(userContract.skipSequence(1)).to.be.revertedWith('Game has not started');
  });

  it('Cannot make choices before there were created', async () => {
    await expect(userContract.makeChoice(1, 1)).to.be.revertedWith("Inexisting choice");
  })

  it('Can update scenario as an admin', async () => {
    const tx = await adminContract.updateScenario(5, 2);
    const details = await tx.wait();
    const events = details.events.filter(e => e.event === 'ScenarioUpdated');
    await expect(events.length).to.equal(1);
    const { sequenceCount, choiceCount } = events[0].args;
    await expect(sequenceCount).to.equal(sequenceCounter + 5);
    await expect(choiceCount).to.equal(choiceCounter + 2);
    sequenceCounter += 5;
    choiceCounter += 2;
  });

  it('User starts at sequence 1', async () => {
    const sequenceId = await userContract.getNextSequence();
    await expect(sequenceId).to.equal(1);
  });

  it('Cannot finish sequences before their predecessor as a user', async () => {
    await expect(userContract.finishSequence(2)).to.be.revertedWith("You're not there yet");
  });

  it('Can finish sequences as a user', async () => {
    const tx = await userContract.finishSequence(1);
    const details = await tx.wait();
    const events = details.events.filter(e => e.event === 'SequenceFinished');
    await expect(events.length).to.equal(1);
    const { by, sequenceId } = events[0].args;
    await expect(by).to.equal(user.address);
    await expect(sequenceId).to.equal(1);
    const nextSequence = await userContract.getNextSequence();
    await expect(nextSequence).to.equal(2);
  });

  it('Cannot make choices before they are initialized', async () => {
    await expect(userContract.makeChoice(0, 0)).to.be.revertedWith('That choice was not initialized');
  });

  it('Cannot initialize choices as a user', async () => {
    await expect(userContract.setChoicesSequences([0], [1])).to.be.revertedWith('Ownable: caller is not the owner');
  })

  it('Can initialize choices as an admin', async () => {
    const tx = await adminContract.setChoicesSequences([0, 1], [1, 2]);
    const details = await tx.wait();
    const events = details.events.filter(e => e.event === 'ChoiceAssigned');
    await expect(events.length).to.equal(2);
    await expect(events[0].args.choiceId).to.equal(0);
    await expect(events[0].args.sequenceId).to.equal(1);
    await expect(events[1].args.choiceId).to.equal(1);
    await expect(events[1].args.sequenceId).to.equal(2);
  });

  it('Cannot skip sequence before their predecessor as a user', async () => {
    await expect(userContract.skipSequence(3)).to.be.revertedWith("You're not there yet");
  });

  it('Can skip sequences as a user', async () => {
    const tx = await userContract.skipSequence(2);
    const details = await tx.wait();
    const events = details.events.filter(e => e.event === 'SequenceSkipped');
    await expect(events.length).to.equal(1);
    const { by, sequenceId } = events[0].args;
    await expect(by).to.equal(user.address);
    await expect(sequenceId).to.equal(2);
    const nextSequence = await userContract.getNextSequence();
    await expect(nextSequence).to.equal(3);
  });

  it('Cannot delete sequence as a user', async () => {
    await expect(userContract.deleteSequence(2)).to.be.revertedWith('Ownable: caller is not the owner');
  });

  it('Can delete sequence as an admin', async () => {
    const tx = await adminContract.deleteSequence(2);
    const details = await tx.wait();
    const events = details.events.filter(e => e.event === 'SequenceDeleted');
    await expect(events.length).to.equal(1);
    const { sequenceId } = events[0].args;
    await expect(sequenceId).to.equal(2);
    const nextSequence = await userContract.getNextSequence();
    await expect(nextSequence).to.equal(3);
  });

  it('Cannot finish or skip a deleted sequence', async () => {
    await expect(userContract.finishSequence(2)).to.be.revertedWith('Deleted sequence');
    await expect(userContract.skipSequence(2)).to.be.revertedWith('Deleted sequence');
  });

  it('Can skip subsequent sequence', async () => {
    const tx = await userContract.skipSequence(3);
    const details = await tx.wait();
    const events = details.events.filter(e => e.event === 'SequenceSkipped');
    await expect(events.length).to.equal(1);
    const { by, sequenceId } = events[0].args;
    await expect(by).to.equal(user.address);
    await expect(sequenceId).to.equal(3);
    const nextSequence = await userContract.getNextSequence();
    await expect(nextSequence).to.equal(4);
  });

  it('Can finish subsequent sequence', async () => {
    const tx = await userContract.finishSequence(4);
    const details = await tx.wait();
    const events = details.events.filter(e => e.event === 'SequenceFinished');
    await expect(events.length).to.equal(1);
    const { by, sequenceId } = events[0].args;
    await expect(by).to.equal(user.address);
    await expect(sequenceId).to.equal(4);
    const nextSequence = await userContract.getNextSequence();
    await expect(nextSequence).to.equal(5);
  });

  it('Correctly deploys ERC20', async () => {
    const address = await adminContract.getCurrencyAddress();
    await expect(address).to.not.be.equal('0x0000000000000000000000000000000000000000');

    const coinsFactory = await ethers.getContractFactory('RoughWatersCoins');
    const coinsContract = coinsFactory.attach(address);
    const balance = await coinsContract.balanceOf(user.address);
    expect(balance).to.equal(0);
  })
});
