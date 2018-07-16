pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Vault.sol';

interface iYTN_CN {
    function burn(uint _amount) public;
}

contract Project is Ownable, TimedCrowdsale {
    string public version;

    enum States {Funding, Production, Existence, Refunding}
    States public state;

    event StateChanged(States previos, States current);

    // minimum amount of funds to be raised in wei
    uint256 public goal;

    string public name;

    uint256 public backersCount;
    uint256 public tokenSold;

    Vault vault;

    constructor(string _name, address _wallet, uint256 _goal) public {
        require(_goal > 0);

        name = _name;
        vault = new Vault(_wallet);
        goal = _goal;
        state = States.Funding;
    }

    /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
    function _forwardFunds() internal {
        vault.deposit.value(msg.value)(msg.sender);
    }

    /**
   * @dev Investors can claim refunds here if crowdsale is unsuccessful
   */
    function claimRefund() public {
        require(state == States.Refunding);

        vault.refund(msg.sender);
    }

    /**
     * @dev Checks whether funding goal was reached.
     * @return Whether funding goal was reached
     */
    function goalReached() public view returns (bool) {
        return weiRaised >= goal;
    }

    function finalizeFunding() external onlyOwner {
        require(hasClosed());

        States _state = States.Production;
        if (!goalReached()) {
            _state = States.Refunding;
        }

        setState(_state);

        iYTN_CN(token).burn(token.balanceOf(this));
    }

    function setState(States _state) internal {
        require(_state > state);

        if (_state == States.Refunding) {
            vault.enableRefunds();
        }

        emit StateChanged(state, _state);
        state = _state;
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
        backersCount = backersCount.add(1);
        tokenSold = tokenSold.add(_tokenAmount);
    }
}
