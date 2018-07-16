pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Bucket is Ownable {

    event AddHolder(address holder);
    event Refill(address from, uint256 amount);
    event Reward(address holder, uint256 amount);

    address[] holders;
    mapping(address => bool) public addedHolder;

    ERC20 public token;

    constructor(address _token) public {
        token = ERC20(_token);
    }

    function() public payable {
        refill();
    }

    function refill() public payable {
        emit Refill(msg.sender, msg.value);
    }

    function _isHolder(address holder) internal view returns (bool) {
        return token.balanceOf(holder) > 0;
    }

    modifier onlyHolder(address holder) {
        require(_isHolder(holder));
        _;
    }

    function addBeneficiary(address _beneficiary) external onlyHolder(_beneficiary) returns (bool) {
        return _addBeneficiary(_beneficiary);
    }

    function _addBeneficiary(address _beneficiary) internal returns (bool) {
        if (addedHolder[_beneficiary]) {
            return false;
        }

        holders.push(_beneficiary);
        addedHolder[_beneficiary] = true;

        emit AddHolder(_beneficiary);
        return true;
    }

    function getReward(address holder) external onlyOwner {
        //Override this method in implementations
    }
}
