import {advanceBlock} from 'zeppelin-solidity/test/helpers/advanceToBlock'
import {increaseTimeTo} from 'zeppelin-solidity/test/helpers/increaseTime'
import latestTime from 'zeppelin-solidity/test/helpers/latestTime'
import EVMRevert from 'zeppelin-solidity/test/helpers/EVMRevert'
import BigNumber from 'bignumber.js'


require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const Factory = artifacts.require('MultiSigWalletFactory')
const MultiSigWallet = artifacts.require('MultiSigWallet')

contract('MultiSigWallet', accounts => {

  const requiredConfirmations = 1

  before(async function () {
    await advanceBlock()
    this.Factory = await Factory.new()
    this.MultiSigWallet = this.Factory.create([accounts[0], accounts[1]], requiredConfirmations)
  })

  beforeEach(async function () {

  })


})
