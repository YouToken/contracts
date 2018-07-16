pragma solidity ^0.4.18;

interface IDonation {
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
    external
    returns (address);
}
