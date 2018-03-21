import {advanceBlock} from 'zeppelin-solidity/test/helpers/advanceToBlock'
import {increaseTimeTo, duration} from 'zeppelin-solidity/test/helpers/increaseTime'
import latestTime from 'zeppelin-solidity/test/helpers/latestTime'
import EVMRevert from 'zeppelin-solidity/test/helpers/EVMRevert'
import BigNumber from 'bignumber.js'


require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Donation = artifacts.require('Donation')
const YTN_cn = artifacts.require('YTN_cn')

contract('Donation', accounts => {
  const TokenCap = 10 ** 27
  const Rate = 100000
  const Goal = (10 ** 19)
  const investor1 = accounts[1]
  const investor2 = accounts[2]
  let StartTime, EndTime

  before(async function () {
    // Advance to the next block to correctly read time in the solidity "now" function interpreted by testrpc
    await advanceBlock()
    StartTime = latestTime() + 100
    EndTime = StartTime + duration.days(30)

    this.token = await YTN_cn.new('YTN_petya', 'YTN_PTA', TokenCap)
    this.project = await Donation.new(
      'SpaceX',
      Rate,
      accounts[0],
      // accounts[0],
      this.token.address,
      StartTime,
      EndTime,
      Goal)
    await this.token.transferOwnership(this.project.address)
  })

  beforeEach(async function () {

  })

  it('purchase tokens', async function () {
    await increaseTimeTo(StartTime)
    await this.project.buyTokens(investor1, {value: new BigNumber(10 ** 18)})
    let balance = await this.token.balanceOf(investor1)
    balance.should.be.bignumber.equal(BigNumber(Rate).mul(10 ** 18))
  })

  it('add steps', async function() {
    await this.project.addStep(0, 'prototype', 30, duration.weeks(3))
    await this.project.addStep(1, 'launch app', 60, duration.weeks(2))
    await this.project.addStep(2, 'production', 10, duration.weeks(1))
  })

  it('finalize funding', async function () {
    await this.project.buyTokens(investor2, {value: Goal})
    await increaseTimeTo(EndTime + 100)
    await this.project.finalizeFunding().should.be.fulfilled
  })

  async function voting(id) {
    await advanceBlock();
    await this.project.startStepConfirmation(id)
    await this.project.vote(id, true, {from: investor2})
  }

  async function execute(id) {
    await this.project.executeProposal(id).should.be.rejected
    await increaseTimeTo(latestTime() + duration.days(2))
    await this.project.executeProposal(id).should.be.fulfilled
    return await this.project.currentStepId.call()
  }

  it('voting', async function () {
    await voting.call(this, 0)
  })

  it('execute proposal', async function () {
    let id = 0
    let currentStepId = await execute.call(this, id)
    currentStepId.should.bignumber.equal(id + 1)
  })

  it('step 2', async function () {
    await voting.call(this, 1)
    await execute.call(this, 1)
  })

  it('step 3', async function () {
    let id = 2
    await voting.call(this, id)
    let currentStepId = await execute.call(this, id)
    currentStepId.should.bignumber.equal(id)
    let state = await this.project.state.call()
    state.should.bignumber.equal(2)
  })
})
