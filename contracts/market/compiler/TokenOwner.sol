pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../../YTN_cn.sol';

contract TokenOwner is Ownable {
    address[] public creators;

    mapping(address => address) public creatorTokens;
    address[] public tokens;

    mapping(address => address[]) public creatorProjects;
    mapping(address => address) public projectCreator;
    address[] public projects;

    modifier onlyCreator() {
        require(creatorTokens[msg.sender] != 0x0);
        _;
    }

    function creatorsCount() public view returns(uint256) {
        return creators.length;
    }

    function tokensCount() public view returns(uint256) {
        return tokens.length;
    }

    function projectsCount() public view returns(uint256) {
        return projects.length;
    }

    function generateToken(
        address creator,
        string _name,
        string _symbol,
        uint256 tokenCap
    )
    onlyOwner
    public
    returns (address token)
    {
        require(creatorTokens[creator] == 0x0);

        token = new YTN_cn(_name, _symbol, tokenCap);
        creators.push(creator);
        creatorTokens[creator] = address(token);
        tokens.push(address(token));

        return address(token);
    }

    function mint(address project, uint256 amount) public {
        address creator = projectCreator[msg.sender];
        require(creator != 0x0 && project == msg.sender);

        YTN_cn(creatorTokens[creator]).mint(project, amount);
    }

    function addProject(address creator, address project)
    onlyOwner
    public
    {
        creatorProjects[creator].push(project);
        projects.push(project);
        projectCreator[project] = creator;
    }
}
