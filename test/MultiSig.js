import {advanceBlock} from 'zeppelin-solidity/test/helpers/advanceToBlock'
import {increaseTimeTo} from 'zeppelin-solidity/test/helpers/increaseTime'
import latestTime from 'zeppelin-solidity/test/helpers/latestTime'
import EVMRevert from 'zeppelin-solidity/test/helpers/EVMRevert'
import BigNumber from 'bignumber.js'


require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

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
      owners.length.should.bignumber.equal(2)
    })

    it('remove', async function () {
      let owners = await this.MultiSigWallet.getOwners()
      owners.length.should.bignumber.equal(2)
    })
  })

  describe('Flush', async function () {

    it('eth', async function () {
    })

    it('tokens', async function () {
    })
  })
})
