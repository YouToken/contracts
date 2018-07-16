pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import "./market/compiler/Creator.sol";
import "./market/compiler/IDebt.sol";
import "./market/compiler/IDonation.sol";
import "./market/compiler/IRevShare.sol";

import "./YTN_cn.sol";

contract Compiler is Creator, Ownable {
    using SafeMath for uint256;

    string public version = 'v1.0';

    uint256 public TOKEN_CAP = 10 ** 27;
    uint256 public GEN_FEE = 1 ether;

    mapping(string => address) projectCompilers;

    event GenerateContract(address _creator, address _contract, string _type);

    function changeVersion(address newCompiler) public onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            Ownable(tokens[i]).transferOwnership(newCompiler);
        }
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

    function generateToken(string _name, string _symbol)
    validAmount
    payable public
    returns (YTN_cn token)
    {
        address creator = msg.sender;
        require(creatorTokens[creator] == 0x0);

        creators.push(creator);
        token = new YTN_cn(_name, _symbol, TOKEN_CAP);
        creatorTokens[creator] = address(token);
        tokens.push(address(token));

        emit GenerateContract(creator, token, 'Token');
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
        YTN_cn token = YTN_cn(creatorTokens[creator]);

        address project = IDebt(projectCompilers['Debt']).generate(
            creator,
            token,
            _name,
            _rate,
            _wallet,
            _openingTime,
            _closingTime,
            _goal,
            _debtRewardPercent,
            _isDebtTokenTransfer
        );

        addProject(project);

        uint256 tokenMint = _goal.mul(_rate).mul(110).div(100);
        //overhead 10% for last big payment
        require(token.mint(project, tokenMint));

        emit GenerateContract(creator, project, 'Debt');
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
        YTN_cn token = YTN_cn(creatorTokens[creator]);

        address project = IDonation(projectCompilers['Donation']).generate(
            creator,
            token,
            _name,
            _rate,
            _wallet,
            _openingTime,
            _closingTime,
            _goal
        );

        addProject(address(project));

        uint256 tokenMint = _goal.mul(_rate).mul(110).div(100);
        //overhead 10% for last big payment
        require(token.mint(project, tokenMint));

        emit GenerateContract(creator, address(project), 'Donation');
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
        YTN_cn token = YTN_cn(creatorTokens[creator]);

        address project = IRevShare(projectCompilers['RevShare']).generate(
            creator,
            token,
            _name,
            _rate,
            _wallet,
            _openingTime,
            _closingTime,
            _goal,
            _roundDuration
        );

        addProject(address(project));

        uint256 tokenMint = _goal.mul(_rate).mul(110).div(100);
        //overhead 10% for last big payment
        require(token.mint(project, tokenMint));

        emit GenerateContract(creator, address(project), 'RevShare');
    }
}
