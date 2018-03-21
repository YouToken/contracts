pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Vault.sol';

contract Project is Ownable, MintedCrowdsale, TimedCrowdsale {
    enum States {Funding, Production, Existence, Refunding}
    States public state;
    event StateChanged(States previos, States current);

    // minimum amount of funds to be raised in weis
    uint256 public goal;

    Vault vault;

    function Project(address _wallet, uint256 _goal) public {
        require(_goal > 0);

        vault = new Vault(_wallet);
        goal = _goal;
        state = States.Funding;
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
    }

    function setState(States _state) internal {
        require(_state > state);

        if (_state == States.Refunding) {
            vault.enableRefunds();
        }

        StateChanged(state, _state);
        state = _state;
        //TODO change token ownership after end
    }
}
