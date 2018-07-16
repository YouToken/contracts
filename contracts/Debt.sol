pragma solidity ^0.4.23;

import './market/Stepable.sol';
import './market/debt/DebtBucketOnce.sol';
import './market/debt/DebtToken.sol';

contract Debt is Stepable {

    DebtBucketOnce public bucket;
    DebtToken public debtToken;

    uint256 debtRewardPercent;

    constructor(
        string _name,
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        uint256 _debtRewardPercent,
        bool _isDebtTokenTransfer
    ) public
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    Project(_name, _wallet, _goal) {
        debtToken = new DebtToken(_isDebtTokenTransfer);
        bucket = new DebtBucketOnce(debtToken);
        debtRewardPercent = _debtRewardPercent;
    }

    function setState(States _state) internal {
        if (_state == States.Production) {
            uint256 rewardAmount = weiRaised.mul(debtRewardPercent).div(100);
            bucket.startFilling(rewardAmount);
        }

        if (_state == States.Existence) {
            startExistence();
        }

        super.setState(_state);
    }

    function startExistence() internal {
        debtToken.finishMinting();
    }

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        super._deliverTokens(_beneficiary, _tokenAmount);
        debtToken.mint(_beneficiary, _tokenAmount);
        bucket.addBeneficiary(_beneficiary);
    }

    function getReward() external {
        bucket.getReward(msg.sender);
        debtToken.burn(msg.sender);
    }
}
