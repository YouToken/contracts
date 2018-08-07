pragma solidity ^0.4.23;

import './market/Stepable.sol';
import './market/bucket/Reward.sol';

contract RevShare is Stepable {

    Reward public bucket;

    constructor(
        string _name,
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        address _tokenOwner,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        uint256 _roundDuration
    ) public
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    Project(_name, _wallet, _goal, _tokenOwner) {
        bucket = new Reward(token);
    }

    function setState(States _state) internal {
        if (_state == States.Existence) {
            startExistence();
        }

        super.setState(_state);
    }

    function startExistence() internal {
//        bucket.startFirstRound();
    }

    function onTokenTransfer(address _from, address _to, uint256 _value) external {
        _onTokenTransfer(_from, _to, _value);
        bucket.onTokenTransfer(_from, _to, _value);
    }

    function getReward() external {
        bucket.getReward(msg.sender);
    }
}
