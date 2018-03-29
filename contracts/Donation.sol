pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import './market/Stepable.sol';

contract Donation is Stepable {

    function Donation(
        string _name,
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal
    ) public
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    Project(_name, _wallet, _goal)
    {
    }
}