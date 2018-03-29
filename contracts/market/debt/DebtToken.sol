pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';

contract DebtToken is MintableToken {

    bool public allowTransfer;

    event Burn(address indexed burner, uint256 value);

    function DebtToken(bool _allowTransfer) public {
        allowTransfer = _allowTransfer;
    }

    modifier isAllowTransfer() {
        require(allowTransfer);
        _;
    }

    function transferFrom(address _from, address _to, uint256 _value) isAllowTransfer public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) isAllowTransfer public returns (bool) {
        return super.transfer(_to, _value);
    }

    function burn(address burner) onlyOwner public {
        require(mintingFinished);

        uint256 value = balances[burner];
        require(value > 0);

        balances[burner] = balances[burner].sub(value);
        totalSupply_ = totalSupply_.sub(value);
        Burn(burner, value);
    }
}
