pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';

contract Reward {
    using SafeMath for uint256;

    mapping(address => uint256) internal payoutsTo_;
    uint256 internal profitPerShare_;
    uint256 constant internal magnitude = 2**64;

    ERC20 token;
    address public owner;

    constructor(address _token) public {
        token = ERC20(_token);
        owner = msg.sender;
    }

    function() payable public {
        profitPerShare_ = profitPerShare_.add((msg.value).mul(magnitude).div(token.totalSupply()));
    }

    function dividendsOf(address holder) public view returns (uint256) {
        return token.balanceOf(holder).mul(profitPerShare_).div(magnitude).sub(payoutsTo_[holder]);
    }

    function getReward() public {
        _getReward(msg.sender);
    }

    function getReward(address holder) public {
        _getReward(holder);
    }

    function _getReward(address holder) private {
        uint256 dividends = dividendsOf(holder);

        if (dividends == 0) {
            return;
        }

        payoutsTo_[holder] = payoutsTo_[holder].add(dividends);
        holder.transfer(dividends);
    }

    function onTokenTransfer(address from, address to, uint256 amount) public {
        require(msg.sender == address(token) || msg.sender == owner);

        if (from == 0x0) {
            //Exclude new tokens from dividends pull
            payoutsTo_[to] += profitPerShare_.mul(amount);
        } else {
            _getReward(from);
            payoutsTo_[from] = payoutsTo_[from].sub(profitPerShare_.mul(amount));
            payoutsTo_[to] = payoutsTo_[to].add(profitPerShare_.mul(amount));
        }
    }
}
