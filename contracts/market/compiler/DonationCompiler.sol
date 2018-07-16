pragma solidity ^0.4.23;

import "./IDonation.sol";
import "../../Donation.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract DonationCompiler is IDonation {
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
        string _name,
        uint256 _rate,
        address _wallet,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal
    )
    onlyRoot
    external
    returns (address)
    {
        Donation project = new Donation(
            _name,
            _rate,
            _wallet,
            ERC20(_token),
            _openingTime,
            _closingTime,
            _goal
        );

        project.transferOwnership(_owner);

        return address(project);
    }
}
