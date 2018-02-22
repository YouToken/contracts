pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract MultiOwnable is Ownable {
    mapping(address => bool) owners;

    function MultiOwnable() public {
        owners[msg.sender] = true;
    }

    modifier onlyCreator() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev add ownership for ICO contracts
    */
    function addOwner(address _newOwner) public onlyOwner {
        owners[_newOwner] = true;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(owners[msg.sender]);
        _;
    }
}
