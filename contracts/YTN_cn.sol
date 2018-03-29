pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/CappedToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';

contract YTN_cn is CappedToken, BurnableToken {
    string public name;
    string public symbol;
    uint256 public decimals = 18;

    function YTN_cn(string _name, string _symbol, uint256 _cap) public CappedToken(_cap) {
        name = _name;
        symbol = _symbol;
    }
}
