import {advanceBlock} from 'zeppelin-solidity/test/helpers/advanceToBlock'
import {duration} from 'zeppelin-solidity/test/helpers/increaseTime'
import latestTime from 'zeppelin-solidity/test/helpers/latestTime'
import ether from 'zeppelin-solidity/test/helpers/ether'
import _ from 'lodash'


require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Compiler = artifacts.require('Compiler')
const DebtCompiler = artifacts.require('DebtCompiler')
const DonationCompiler = artifacts.require('DonationCompiler')
const RevShareCompiler = artifacts.require('RevShareCompiler')
const Ownable = artifacts.require('Ownable')
const YTN_cn = artifacts.require('YTN_cn')

contract('Compiler', accounts => {
  const Rate = 100000
  const Goal = ether(1)
  const DebtRewardPercent = 110
  const creator = accounts[1]
  const investor2 = accounts[2]
  let StartTime, EndTime

  it('gen Compiler', async function () {
    await advanceBlock()

    this.compiler = await Compiler.new()

    this.debtCompiler = await DebtCompiler.new(this.compiler.address)
    this.compiler.setProjectCompiler('Debt', this.debtCompiler.address)

    this.donationCompiler = await DonationCompiler.new(this.compiler.address)
    this.compiler.setProjectCompiler('Donation', this.donationCompiler.address)

    this.revShareCompiler = await RevShareCompiler.new(this.compiler.address)
    this.compiler.setProjectCompiler('RevShare', this.revShareCompiler.address)
  })

  it('gen Token', async function () {
    let {logs} = await this.compiler.generateToken('YTN_petya', 'YTN_PTA', {value: ether(1), from: creator})
    let {args: {_contract}} = logs[0]

    this.token = YTN_cn.at(_contract)
  })

  it('gen Debt', async function () {
    StartTime = latestTime() + 100
    EndTime = StartTime + duration.days(30)

    let {logs} = await this.compiler.generateDebt(
      'SpaceX',
      Rate,
      accounts[0],
      StartTime,
      EndTime,
      Goal,
      DebtRewardPercent,
      false
      , {value: ether(1), from: creator})

    let {args: {_contract}} = _.find(logs, {address: this.compiler.address, event: 'GenerateContract'})
    Goal.mul(Rate).mul(110).div(100).should.bignumber.equal(await this.token.balanceOf.call(_contract))
    creator.should.equal(await Ownable.at(_contract).owner.call())
  })

  it('gen Donation', async function () {
    StartTime = latestTime() + 100
    EndTime = StartTime + duration.days(30)

    let {logs} = await this.compiler.generateDonation(
      'SpaceX',
      Rate,
      accounts[0],
      StartTime,
      EndTime,
      Goal
      , {value: ether(1), from: creator})

    let {args: {_contract}} = _.find(logs, {address: this.compiler.address, event: 'GenerateContract'})
    Goal.mul(Rate).mul(110).div(100).should.bignumber.equal(await this.token.balanceOf.call(_contract))
    creator.should.equal(await Ownable.at(_contract).owner.call())
  })

  it('gen RevShare', async function () {
    StartTime = latestTime() + 100
    EndTime = StartTime + duration.days(30)

    let {logs} = await this.compiler.generateRevShare(
      'SpaceX',
      Rate,
      accounts[0],
      StartTime,
      EndTime,
      Goal,
      60 * 60 * 24 * 30
      , {value: ether(1), from: creator})

    let {args: {_contract}} = _.find(logs, {address: this.compiler.address, event: 'GenerateContract'})
    Goal.mul(Rate).mul(110).div(100).should.bignumber.equal(await this.token.balanceOf.call(_contract))
    creator.should.equal(await Ownable.at(_contract).owner.call())
  })
})