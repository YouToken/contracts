pragma solidity ^0.4.18;

import './Project.sol';

contract Stepable is Project {

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

    uint256 public VOTING_MIN_QUORUM = 3;//percent
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
    event ProposalFinalized(uint proposalId, uint result, uint quorum, bool active);

    struct Vote {
        bool agreed;
        address voter;
    }

    function validateSteps() internal {
        uint256 percents = 100;
        for (uint256 i = 0; i < stepLength; i++) {
            percents = percents.sub(steps[i].percentOfFunds);
        }
    }

    modifier isProduction() {
        require(state == States.Production);
        _;
    }

    modifier onlyInvestor() {
        require(token.balanceOf(msg.sender) > 0);
        _;
    }

    function vote(uint256 proposalId, bool agreed) external isProduction onlyInvestor returns (uint256 voteId) {
        Proposal storage proposal = proposals[proposalId];

        require(!proposal.voted[msg.sender]);

        if (proposal.deadline < block.timestamp) {
            //auto close voting
            _executeProposal(proposalId);
            return 0;
        }

        address voter = msg.sender;
        voteId = proposal.votes.length++;
        proposal.votes[voteId] = Vote({agreed : agreed, voter : voter});
        proposal.voted[voter] = true;

        Voted(proposalId, agreed, voter);

        return voteId;
    }

    function addProposal(uint256 stepId, uint proposalType) external returns (uint256) {
        return _createProposal(stepId, proposalType);
    }

    function _createProposal(uint256 stepId, uint proposalType) internal returns (uint256 proposalID) {
        proposalID = proposalsLength++;
        Proposal storage p = proposals[proposalID];

        p.startTime = block.timestamp;
        p.deadline = block.timestamp + VOTING_DURATION;
        p.executed = false;
        p.proposalType = ProposalTypes(proposalType);
        p.stepId = stepId;

        ProposalAdded(proposalID, proposalType, stepId);

        return proposalID;
    }

    function executeProposal(uint256 proposalId) external isProduction {
        _executeProposal(proposalId);
    }

    function _executeProposal(uint256 proposalId) internal {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.deadline < block.timestamp);
        require(!proposal.executed);

        uint256 yes = 0;
        uint256 no = 0;

        for (uint i = 0; i < proposal.votes.length; i++) {
            Vote storage vote = proposal.votes[i];
            uint256 amount = token.balanceOf(vote.voter);
            if (vote.agreed) {
                yes = yes.add(amount);
            } else {
                no = no.add(amount);
            }
        }

        proposal.executed = true;
        proposal.agreed = yes > no && yes.add(no) > VOTING_MIN_QUORUM;

        if (proposal.proposalType == ProposalTypes.Confirm) {
            closeStep(proposal.stepId, proposal.agreed);
        } else {
            //TODO call to apply step changing
        }
    }

    function addStep(uint256 stepId, string description, uint256 percentOfFunds, uint256 duration) external onlyOwner {
        Step storage step = steps[stepId];
        step.id = stepId;
        step.description = description;
        step.percentOfFunds = percentOfFunds;
        step.duration = duration;
        step.mode = StepMode.None;
        validateSteps();
        stepLength++;
    }

    function startStep(uint256 stepId) internal {
        require(stepId == 0 || stepId > currentStepId);
        require(stepId == 0 || steps[stepId - 1].mode == StepMode.Confirmed);

        Step storage step = steps[stepId];

        step.startTime = block.timestamp;
        step.deadline = step.startTime + step.duration;
        step.mode = StepMode.Running;

        currentStepId = stepId;
    }

    function changeStep(uint256 stepId) external onlyOwner isProduction {}

    function startStepConfirmation(uint256 stepId) external isProduction returns (uint256) {
        Step storage step = steps[stepId];

        require(step.mode == StepMode.Running);

        //if owner didn't start voting anybody can start after during time
        require(msg.sender == owner || step.deadline > block.timestamp);

        step.mode = StepMode.Voting;

        return _createProposal(stepId, uint(ProposalTypes.Confirm));
    }

    function closeStep(uint256 stepId, bool isConfirm) internal {
        Step storage step = steps[stepId];

        step.endTime = block.timestamp;

        if (isConfirm) {
            vault.sendPercent(step.percentOfFunds);
            step.mode = StepMode.Confirmed;

            //if its last step
            if (stepId == stepLength - 1) {
                setState(States.Existence);
            } else {
                startStep(stepId + 1);
            }
        } else {
            step.mode = StepMode.Failed;
            setState(States.Refunding);
        }
    }

    function setState(States _state) internal {
        if (_state == States.Production) {
            startStep(0);
        }

        if(_state == States.Existence) {
            vault.close();
        }

        super.setState(_state);
    }
}
