pragma solidity ^0.4.18;

contract Creator {
    address[] public creators;

    mapping(address => address) public creatorTokens;
    address[] public tokens;

    mapping(address => address[]) public creatorProjects;
    address[] public projects;

    modifier onlyCreator() {
        require(creatorTokens[msg.sender] != 0x0);
        _;
    }

    function creatorsCount() public returns(uint256) {
        return creators.length;
    }

    function tokensCount() public returns(uint256) {
        return tokens.length;
    }

    function projectsCount() public returns(uint256) {
        return projects.length;
    }

    function addProject(address project) internal {
        creatorProjects[msg.sender].push(project);
        projects.push(project);
    }
}
