pragma solidity ^0.4.23;

interface Project {

    enum StepMode {None, Running, Voting, Confirmed, Failed}

    struct Step {
        uint256 id;
        StepMode mode;

        string description;
        uint256 percentOfFunds;
        uint256 duration;//in sec

        uint256 startTime;
        uint256 deadline;
        uint256 endTime;
    }

    mapping(uint256 => Step) public steps;
    uint256 public stepLength;
    uint256 public currentStepId;

    uint256 public VOTING_DURATION = 60 * 60 * 24;//in sec

    enum ProposalTypes {Confirm, Edit}

    struct Proposal {
        ProposalTypes proposalType;

        uint256 startTime;
        uint256 deadline;
        bool executed;
        bool agreed;

        Vote[] votes;
        mapping(address => bool) voted;

        uint256 stepId;
    }

    uint256 public proposalsLength;
    mapping(uint256 => Proposal) public proposals;

    event ProposalAdded(uint proposalId, uint proposalType, uint stepId);
    event Voted(uint proposalId, bool agree, address voter);
    event ProposalFinalized(uint proposalId, uint quorum, bool aggreed);

    struct Vote {
        bool agreed;
        address voter;
    }

    modifier isProduction() {
        _;
    }

    modifier onlyInvestor() {
        _;
    }

    modifier onlyOwner() {
        _;
    }

    function vote(uint256 proposalId, bool agreed) external isProduction onlyInvestor returns (uint256 voteId);

    //emit ProposalAdded
    function addProposal(uint256 stepId, uint proposalType) external returns (uint256);

    //if executed emit ProposalFinalized
    function executeProposal(uint256 proposalId) external isProduction;

    function addStep(uint256 stepId, string description, uint256 percentOfFunds, uint256 duration) external onlyOwner;

    function changeStep(uint256 stepId) external onlyOwner isProduction;

    function startStepConfirmation(uint256 stepId) external isProduction returns (uint256);

    function goalReached() public view returns (bool);

    function claimRefund() public;
}
