pragma solidity ^0.4.23;

import "./IDebt.sol";
import "../../Debt.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract DebtCompiler is IDebt {
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
        uint256 _goal,
        uint256 _debtRewardPercent,
        bool _isDebtTokenTransfer
    )
    onlyRoot
    external
    returns (address)
    {
        Debt project = new Debt(
            _name,
            _rate,
            _wallet,
            ERC20(_token),
            _openingTime,
            _closingTime,
            _goal,
            _debtRewardPercent,
            _isDebtTokenTransfer
        );

        project.transferOwnership(_owner);

        return address(project);
    }
}
