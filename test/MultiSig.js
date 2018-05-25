import {advanceBlock} from 'zeppelin-solidity/test/helpers/advanceToBlock'
import {increaseTimeTo} from 'zeppelin-solidity/test/helpers/increaseTime'
import latestTime from 'zeppelin-solidity/test/helpers/latestTime'
import EVMRevert from 'zeppelin-solidity/test/helpers/EVMRevert'
import BigNumber from 'bignumber.js'


require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const YTN = artifacts.require('YTN')
const utils = require('./utils');

const Factory = artifacts.require('MultiSigWalletFactory')
const MultiSigWallet = artifacts.require('MultiSigWallet')

contract('MultiSigWallet', accounts => {

  const requiredConfirmations = 1

  before(async function () {
    await advanceBlock()
    this.Factory = await Factory.new()
    let tx = await this.Factory.create([accounts[0], accounts[1]], requiredConfirmations)
    let walletAddress = utils.getParamFromTxEvent(tx, 'instantiation', null, 'ContractInstantiation')
    this.MultiSigWallet = MultiSigWallet.at(walletAddress)
  })

  beforeEach(async function () {

  })

  describe('Owner', async function () {

    it('add', async function () {
      let owners = await this.MultiSigWallet.getOwners()
      owners.length.should.bignumber.equal(3)
    })

    it('remove', async function () {
      let owners = await this.MultiSigWallet.getOwners()
      owners.length.should.bignumber.equal(3)
    })
  })

  describe('Cold', async function () {

    it('change', async function () {
    })

    it('payable transfer', async function () {
    })
  })

  describe('Flush', async function () {

    it('tokens', async function () {
      let token = await YTN.new(
        new BigNumber(10 ** 26),
        new BigNumber(10 ** 27)
      )

      let balance = new BigNumber(10 ** 20)
      let wallet = this.MultiSigWallet.address
      await token.mint(wallet, balance)

      let walletBalance = await token.balanceOf(wallet)
      walletBalance.should.be.bignumber.equal(balance)

      let cold = accounts[0]
      await this.Factory.flushTokens(token.address, cold)

      walletBalance = await token.balanceOf(wallet)
      walletBalance.should.be.bignumber.equal(0)

      let coldBalance = await token.balanceOf(cold)
      coldBalance.should.be.bignumber.equal(balance)
    })
  })
})