pragma solidity ^0.4.18;

import './market/Stepable.sol';
import './market/bucket/CircleBucket.sol';
import './token/IEventListener.sol';

contract RevShare is Stepable, IEventListener {

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
    Project(_name, _wallet, _goal) {
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

    function onTokenTransfer(address _from, address _to, uint256 _value) external {
        require(msg.sender == address(token));
        bucket.addBeneficiary(_to);
    }

    function onTokenApproval(address _from, address _to, uint256 _value) external {
        //nope
    }

    function getReward() external {
        bucket.getReward(msg.sender);
    }
}
