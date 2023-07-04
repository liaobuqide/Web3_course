// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    address public admin;
    bool public votingOpen;
    uint public totalVotes;

    struct Proposal {
        string name;
        string description;
        uint voteCount;
    }

    Proposal[] public proposals;

    mapping(address => bool) public hasVoted;
    mapping(uint => address[]) public proposalVotes;

    constructor() {
        admin = msg.sender;
        votingOpen = false;
        totalVotes = 0;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyDuringVoting() {
        require(votingOpen, "Voting is not currently open");
        _;
    }

    function addProposal(string memory _name, string memory _description) public onlyAdmin {
        require(!votingOpen, "Cannot add proposal while voting is open");
        proposals.push(Proposal({
            name: _name,
            description: _description,
            voteCount: 0
        }));
    }

    function openVoting() public onlyAdmin {
        require(proposals.length > 0, "Cannot open voting with no proposals");
        votingOpen = true;
    }

    function closeVoting() public onlyAdmin {
        require(votingOpen, "Voting is not currently open");
        votingOpen = false;
        totalVotes = 0;
        for (uint i = 0; i < proposals.length; i++) {
            Proposal storage proposal = proposals[i];
            proposal.voteCount = 0;
        }
    }

    function vote(uint _proposalIndex) public onlyDuringVoting {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_proposalIndex < proposals.length, "Invalid proposal index");
        Proposal storage proposal = proposals[_proposalIndex];
        proposalVotes[_proposalIndex].push(msg.sender);
        proposal.voteCount++;
        totalVotes++;
        hasVoted[msg.sender] = true;
    }

    function getWinningProposal() public view onlyAdmin returns (string memory) {
        require(!votingOpen, "Voting is still open");
        uint winningIndex = 0;
        uint winningVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            Proposal storage proposal = proposals[i];
            if (proposal.voteCount > winningVoteCount) {
                winningIndex = i;
                winningVoteCount = proposal.voteCount;
            }
        }
        return proposals[winningIndex].name;
    }

    function getProposalVoteCount(uint _proposalIndex) public view onlyAdmin returns (uint) {
        require(!votingOpen, "Voting is still open");
        require(_proposalIndex < proposals.length, "Invalid proposal index");
        return proposals[_proposalIndex].voteCount;
    }

    function withdrawTokens(address _tokenAddress, address _to, uint _amount) public onlyAdmin {
        require(_to != address(0), "Invalid recipient address");
        IERC20 token = IERC20(_tokenAddress);
        require(token.transfer(_to, _amount), "Token transfer failed");
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}