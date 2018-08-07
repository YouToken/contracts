pragma solidity ^0.4.18;

interface IRevShare {
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
    external
    returns (address);
}
