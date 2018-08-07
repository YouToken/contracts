pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Vault.sol';

interface TokenOwner {
    function mint(address project, uint _amount) public;
}

contract Project is Ownable, TimedCrowdsale {
    string public version;

    enum States {Funding, Production, Existence, Refunding}
    States public state;

    event StateChanged(States previos, States current);

    // minimum amount of funds to be raised in wei
    uint256 public goal;

    string public name;

    mapping(address => uint256) public balances;
    uint256 public backersCount;
    uint256 public tokenSold;

    TokenOwner tokenOwner;

    Vault vault;

    constructor(string _name, address _wallet, uint256 _goal, address _tokenOwner) public {
        require(_goal > 0);

        name = _name;
        vault = new Vault(_wallet);
        goal = _goal;
        state = States.Funding;
        tokenOwner = TokenOwner(_tokenOwner);
    }

    /**
     * @dev Withdraw tokens only after crowdsale ends.
     */
    function withdrawTokens() public {
        require(state == States.Production);
        uint256 amount = balances[msg.sender];
        require(amount > 0);
        balances[msg.sender] = 0;
        _deliverTokens(msg.sender, amount);
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        if (balances[_beneficiary] == 0) {
            backersCount = backersCount.add(1);
        }
        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
        vault.deposit.value(msg.value)(_beneficiary);
        tokenSold = tokenSold.add(_tokenAmount);
    }

    function _forwardFunds() internal {
        //Store beneficiary for refund
        return;
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

        if (_state == States.Production) {
            tokenOwner.mint(address(this), tokenSold);
        }

        if (_state == States.Refunding) {
            vault.enableRefunds();
        }

        emit StateChanged(state, _state);
        state = _state;
    }
}
