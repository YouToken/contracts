pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/CappedToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import './token/EventToken.sol';

contract YTN_cn is EventToken, CappedToken, BurnableToken {
    string public name;
    string public symbol;
    uint256 public decimals = 18;

    constructor(string _name, string _symbol, uint256 _cap) public CappedToken(_cap) {
        name = _name;
        symbol = _symbol;
    }
}
