pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/crowdsale/distribution/utils/RefundVault.sol';

contract Vault is RefundVault {
    using SafeMath for uint256;

    event SendPercent(uint256 percent, uint256 amount);

    uint256 constant hundred = 100;
    uint256 partOfFull = 100;

    constructor(address _wallet) public RefundVault(_wallet){
    }

    function sendPercent(uint256 percent) public onlyOwner {
        uint256 full = this.balance.mul(hundred).div(partOfFull);
        uint256 amount = full.mul(percent).div(hundred);

        wallet.transfer(amount);
        partOfFull = partOfFull.sub(percent);

        SendPercent(percent, amount);
    }

    function refund(address investor) public {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];

        depositedValue = depositedValue.mul(partOfFull).div(hundred);//sub getting funds

        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }
}
