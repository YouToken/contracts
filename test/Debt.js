import {advanceBlock} from 'zeppelin-solidity/test/helpers/advanceToBlock'
import {duration, increaseTimeTo} from 'zeppelin-solidity/test/helpers/increaseTime'
import latestTime from 'zeppelin-solidity/test/helpers/latestTime'
import ether from 'zeppelin-solidity/test/helpers/ether'
import BigNumber from 'bignumber.js'


require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Debt = artifacts.require('Debt')
const YTN_cn = artifacts.require('YTN_cn')
const Bucket = artifacts.require('DebtBucketOnce')
const DebtToken = artifacts.require('DebtToken')

contract('Debt', accounts => {
  const TokenCap = 10 ** 27
  const Rate = 100000
  const Goal = ether(1)
  const DebtRewardPercent = 110;
  const investor1 = accounts[1]
  const investor2 = accounts[2]
  let StartTime, EndTime

  before(async function () {
    await advanceBlock()
    StartTime = latestTime() + 100
    EndTime = StartTime + duration.days(30)

    this.token = await YTN_cn.new('YTN_petya', 'YTN_PTA', TokenCap)
    this.project = await Debt.new(
      'SpaceX',
      Rate,
      accounts[0],
      this.token.address,
      this.token.address,
      StartTime,
      EndTime,
      Goal,
      DebtRewardPercent
    )
    await this.token.transferOwnership(this.project.address)
  })

  describe('Funding', async function () {

    it('purchase tokens', async function () {
      const amount = ether(0.1)
      await increaseTimeTo(StartTime)
      await this.project.buyTokens(investor1, {value: amount})
      let balance = await this.project.balances.call(investor1)
      balance.should.be.bignumber.equal(BigNumber(Rate).mul(amount))
    })

    it('add steps', async function () {
      await this.project.addStep(0, 'prototype', 30, duration.weeks(3))
      await this.project.addStep(1, 'launch app', 60, duration.weeks(2))
      await this.project.addStep(2, 'production', 10, duration.weeks(1))
    })

    it('finalize funding', async function () {
      await this.project.buyTokens(investor2, {value: Goal})
      await increaseTimeTo(EndTime + 100)
      await this.project.finalizeFunding().should.be.fulfilled
    })
  })

  describe('Production', async function () {

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

    it('getTokens', async function () {
      let b1 = await this.project.balances.call(investor1)
      let b2 = await this.project.balances.call(investor2)

      await this.project.withdrawTokens({from: investor1})
      await this.project.withdrawTokens({from: investor2})

      let bb1 = await this.token.balanceOf.call(investor1)
      let bb2 = await this.token.balanceOf.call(investor2)

      bb1.should.be.bignumber.equal(b1)
      bb2.should.be.bignumber.equal(b2)
    })

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

  describe('Existence', async function () {

    const filling = ether(1)

    before(async function () {
      this.bucket = await Bucket.at(await this.project.bucket.call())
      this.debtToken = await DebtToken.at(await this.project.debtToken.call())
    })

    it('fill bucket', async function () {
      await this.bucket.sendTransaction({value: filling})
      let balance = web3.eth.getBalance(this.bucket.address)
      balance.should.bignumber.equal(filling)
    })

    it('get rewards', async function () {
      let balance = web3.eth.getBalance(investor2)
      await this.project.getReward({from: investor2})
      web3.eth.getBalance(investor2).should.bignumber.gt(balance)
    })
  })

})
