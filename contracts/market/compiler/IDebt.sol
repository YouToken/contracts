pragma solidity ^0.4.18;

interface IDebt {
    function generate(
        address _owner,
        address _token,
        string _name,
        uint256 _rate,
        address _wallet,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        uint256 _debtRewardPercent,
        bool _isDebtTokenTransfer
    )
    external
    returns (address);
}
