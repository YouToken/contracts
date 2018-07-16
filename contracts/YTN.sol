pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/PausableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './token/Holdable.sol';

contract YTN is Holdable, MintableToken, BurnableToken {
    using SafeMath for uint256;

    enum States {PreOrder, ProofOfConcept, DAICO, Final}
    States public state;

    string public symbol = 'YTN';

    string public name = 'YouToken';

    uint256 public decimals = 18;

    uint256 public cap;
    uint256 public proofOfConceptCap;
    uint256 public DAICOCap;

    function YTN(uint256 _proofOfConceptCap, uint256 _DAICOCap) public {
        proofOfConceptCap = _proofOfConceptCap;
        DAICOCap = _DAICOCap;
        setState(uint(States.PreOrder));
    }

    function() public payable {
        revert();
    }

    function setState(uint _state) public onlyOwner {
        require(uint(state) <= _state && uint(States.Final) >= _state);
        state = States(_state);

        if (state == States.PreOrder || state == States.ProofOfConcept) {
            cap = proofOfConceptCap;
        }

        if (state == States.DAICO) {
            cap = DAICOCap + totalSupply_;
            pause();
        }

        if (state == States.Final) {
            finishMinting();
            unpause();
        }
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        require(totalSupply_.add(_amount) <= cap);

        return super.mint(_to, _amount);
    }
}
