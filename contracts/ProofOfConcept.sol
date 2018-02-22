pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol';
import './YTN.sol';

contract ProofOfConcept is RefundableCrowdsale, MintedCrowdsale{
    uint ProofOfConceptState = 1;

    function ProofOfConcept(
        YTN _token,
        uint256 _rate,
        uint256 _goal,
        address _wallet,
        uint256 _openingTime,
        uint256 _closingTime
    )
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    RefundableCrowdsale(_goal)
    public
    {
        YTN(token).setState(ProofOfConceptState);
    }

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 bonus = 0;
        //bonus for a big purchase
        if (_weiAmount > 50 ether) bonus = _weiAmount.mul(15).div(100);
        if (_weiAmount > 30 ether) bonus = _weiAmount.mul(10).div(100);
        if (_weiAmount > 10 ether) bonus = _weiAmount.mul(5).div(100);

        return _weiAmount.mul(rate).add(bonus);
    }
}
