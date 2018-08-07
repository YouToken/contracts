pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import './market/Stepable.sol';

contract Donation is Stepable {

    constructor(
        string _name,
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        address _tokenOwner,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal
    ) public
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    Project(_name, _wallet, _goal, _tokenOwner)
    {
    }
}
