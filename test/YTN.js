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

contract('YTN', accounts => {
  const ProofOfConceptCap = new BigNumber(10 ** 26)
  const DAICOCap = new BigNumber(10 ** 27)

  before(async function () {
    // Advance to the next block to correctly read time in the solidity "now" function interpreted by testrpc
    await advanceBlock()
  })

  beforeEach(async function () {
    this.token = await YTN.new(
      ProofOfConceptCap,
      DAICOCap
    )
  })

  it('should be token owner', async function () {
    const creator = await this.token.owner()
    creator.should.equal(accounts[0])
  })

  it('should be PreOrder state and cap', async function () {
    const state = await this.token.state()
    state.should.be.bignumber.equal(0)
    const cap = await this.token.cap()
    cap.should.be.bignumber.equal(ProofOfConceptCap)
  })

  it('hold account', async function () {
    let holder = accounts[1]
    let balance = new BigNumber(10 ** 20)
    let timeToHold = latestTime() + 1
    let timeToUnhold = timeToHold + 1

    await this.token.mint(holder, balance)
    await this.token.hold(holder, timeToHold)

    await this.token.isHold(holder).should.eventually.equal(true)

    await this.token.unhold(holder).should.be.rejectedWith(EVMRevert)

    await increaseTimeTo(timeToUnhold)
    await this.token.unhold(holder).should.be.fulfilled
  })
})
