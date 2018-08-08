pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import "./market/compiler/TokenOwner.sol";
import "./market/compiler/IDebt.sol";
import "./market/compiler/IDonation.sol";
import "./market/compiler/IRevShare.sol";

import "./YTN_cn.sol";

contract Compiler is Ownable {
    using SafeMath for uint256;

    string public version = 'v1.0';

    uint256 public TOKEN_CAP = 10 ** 27;
    uint256 public GEN_FEE = 0.3 ether;

    address public bucket;

    TokenOwner tokenOwner;
    mapping(string => address) projectCompilers;

    event GenerateContract(address _creator, address _contract, string _type);

    constructor(address _tokenOwner, address _bucket) public {
        tokenOwner = TokenOwner(_tokenOwner);
        bucket = _bucket;
    }

    function changeVersion(address newCompiler) public onlyOwner {
        tokenOwner.transferOwnership(newCompiler);
    }

    function setProjectCompiler(string _name, address _compilerAddress)
    public onlyOwner
    {
        projectCompilers[_name] = _compilerAddress;
    }

    modifier validAmount() {
        require(msg.value >= GEN_FEE);
        _;
    }

    modifier onlyCreator() {
        require(tokenOwner.creatorTokens(msg.sender) != 0);
        _;
    }

    function setBucket(address _bucket) public onlyOwner {
        bucket = _bucket;
    }

    function _forwardFunds() internal {
        bucket.transfer(msg.value);
    }

    function generateToken(string _name, string _symbol)
    validAmount
    payable public
    returns (address token)
    {
        address creator = msg.sender;
        require(tokenOwner.creatorTokens(creator) == 0x0);

        token = tokenOwner.generateToken(creator, _name, _symbol, TOKEN_CAP);

        emit GenerateContract(creator, token, 'Token');
        _forwardFunds();
    }

    function generateDebt(
        string _name,
        uint256 _rate,
        address _wallet,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        uint256 _debtRewardPercent,
        bool _isDebtTokenTransfer
    )
    validAmount onlyCreator
    payable public
    {
        address creator = msg.sender;
        address token = tokenOwner.creatorTokens(creator);

        address project = IDebt(projectCompilers['Debt']).generate(
            creator,
            token,
            tokenOwner,
            _name,
            _rate,
            _wallet,
            _openingTime,
            _closingTime,
            _goal,
            _debtRewardPercent
        );

        tokenOwner.addProject(creator, project);
        emit GenerateContract(creator, project, 'Debt');
        _forwardFunds();
    }

    function generateDonation(
        string _name,
        uint256 _rate,
        address _wallet,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal
    )
    validAmount onlyCreator
    payable public
    {
        address creator = msg.sender;
        address token = tokenOwner.creatorTokens(creator);

        address project = IDonation(projectCompilers['Donation']).generate(
            creator,
            token,
            address(tokenOwner),
            _name,
            _rate,
            _wallet,
            _openingTime,
            _closingTime,
            _goal
        );

        tokenOwner.addProject(creator, project);
        emit GenerateContract(creator, project, 'Donation');
        _forwardFunds();
    }

    function generateRevShare(
        string _name,
        uint256 _rate,
        address _wallet,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        uint256 _roundDuration
    )
    validAmount onlyCreator
    payable public
    {
        address creator = msg.sender;
        address token = tokenOwner.creatorTokens(creator);

        address project = IRevShare(projectCompilers['RevShare']).generate(
            creator,
            token,
            address(tokenOwner),
            _name,
            _rate,
            _wallet,
            _openingTime,
            _closingTime,
            _goal,
            _roundDuration
        );

        tokenOwner.addProject(creator, project);
        emit GenerateContract(creator, project, 'RevShare');
        _forwardFunds();
    }
}
