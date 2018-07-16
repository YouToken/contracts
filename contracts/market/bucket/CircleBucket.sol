pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './Bucket.sol';

contract CircleBucket is Bucket {
    using SafeMath for uint256;

    event NewRewardRound(uint256 balance);

    uint256 public roundDuration;//in sec
    bool public started;

    event OpenRewardRound(uint256 balance, uint256 holderLength);
    event CloseRound(uint256 from, uint256 to, uint256 balance, uint256 weiReward, uint256 holderLength);

    uint256 public roundStartTime;
    uint256 public roundBalance;
    uint256 public roundReward;

    mapping(address => uint256) public roundBalances;

    constructor(address _token, uint256 _roundDuration) public
    Bucket(_token)
    {
        roundDuration = _roundDuration;
    }

    function startFirstRound() external onlyOwner {
        roundStartTime = now;
        started = true;
    }

    modifier isStarted() {
        require(started);
        _;
    }

    function getReward(address holder) external isStarted onlyOwner {
        require(roundBalance > 0);

        uint256 holderBalance = roundBalances[holder];

        //double spending
        require(holderBalance > 0);

        roundBalances[holder] = 0;
        holder.transfer(holderBalance);
        roundReward = roundReward.add(holderBalance);
        emit Reward(holder, holderBalance);
    }

    function nextRound() external isStarted {
        require(now.sub(roundStartTime) >= roundDuration);

        uint256 totalSupply = token.totalSupply();
        roundBalance = this.balance;

        for (uint256 i; i < holders.length; i++) {
            address holder = holders[i];
            uint256 holderTokens = token.balanceOf(holder);

            roundBalances[holder] = holderTokens == 0 ? 0 : roundBalance.mul(holderTokens).div(totalSupply);
        }

        roundStartTime = now;
        roundReward = 0;
    }
}
