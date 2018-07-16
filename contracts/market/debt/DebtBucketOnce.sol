pragma solidity ^0.4.23;

import '../bucket/Bucket.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract DebtBucketOnce is Bucket {
    using SafeMath for uint256;

    enum States {None, Filling, Rewarding}
    States public state;

    mapping(address => uint256) public holderBalances;

    bool public openFilling;
    uint256 public goal;

    constructor(address _token) public Bucket(_token) {
    }

    function refill() public payable isFilling {
        super.refill();
        if (isReached()) {
            changeState(States.Rewarding);
        }
    }

    function isReached() internal view returns (bool) {
        return this.balance >= goal;
    }

    function startFilling(uint256 _goal) public onlyOwner {
        changeState(States.Filling);
        goal = _goal;
    }

    function stopFilling() public onlyOwner {
        changeState(States.Rewarding);
    }

    function changeState(States _state) internal {
        require(state < _state);

        if (_state == States.Rewarding) {
            require(isReached());
            calculateReward();
        }

        state = _state;
    }

    modifier isFilling() {
        require(state == States.Filling);
        _;
    }

    modifier isRewarding() {
        require(state == States.Rewarding);
        _;
    }

    function calculateReward() internal {
        uint256 totalBalance = this.balance;
        uint256 totalSupply = token.totalSupply();

        for (uint256 i; i < holders.length; i++) {
            address holder = holders[i];
            uint256 holderTokens = token.balanceOf(holder);

            holderBalances[holder] = totalBalance.mul(holderTokens).div(totalSupply);
        }
    }

    function getReward(address holder) external isRewarding onlyOwner {
        uint256 holderBalance = holderBalances[holder];

        //double spending
        require(holderBalance > 0);

        holderBalances[holder] = 0;
        holder.transfer(holderBalance);
        emit Reward(holder, holderBalance);
    }
}
