pragma solidity ^0.4.18;

import './market/Stepable.sol';
import './market/bucket/CircleBucket.sol';

contract RevShare is Stepable {

    CircleBucket public bucket;

    function RevShare(
        string _name,
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        uint256 _roundDuration
    ) public
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    Project(_wallet, _goal) {
        bucket = new CircleBucket(token, _roundDuration);
    }

    function setState(States _state) internal {
        if (_state == States.Existence) {
            startExistence();
        }

        super.setState(_state);
    }

    function startExistence() internal {
        bucket.startFirstRound();
    }

    function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        super._postValidatePurchase(_beneficiary, _weiAmount);
        bucket.addBeneficiary(_beneficiary);
    }
}
