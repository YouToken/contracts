pragma solidity ^0.4.23;

import "./IRevShare.sol";
import "../../RevShare.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract RevShareCompiler is IRevShare {
    address public rootCompiler;

    constructor(address _rootCompiler){
        rootCompiler = _rootCompiler;
    }

    modifier onlyRoot() {
        require(msg.sender == rootCompiler);
        _;
    }

    function generate(
        address _owner,
        address _token,
        address _tokenOwner,
        string _name,
        uint256 _rate,
        address _wallet,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        uint256 _roundDuration
    )
    onlyRoot
    external
    returns (address)
    {
        RevShare project = new RevShare(
            _name,
            _rate,
            _wallet,
            ERC20(_token),
            _tokenOwner,
            _openingTime,
            _closingTime,
            _goal,
            _roundDuration
        );

        project.transferOwnership(_owner);

        return address(project);
    }
}
