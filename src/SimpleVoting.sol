// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title SimpleVoting
 * @dev Implement a simple voting contract
 * @author truthixify
 * @notice This contract allows users to vote for candidates.
 */
contract SimpleVoting {
    // Errors
    error SimpleVoting__AlreadyVoted();
    error SimpleVoting__InvalidCandidate();
    error SimpleVoting__VotingHasEnded();
    error SimpleVoting__OnlyAdmin();

    // Type Declarations
    enum VoteStatus {
        Active,
        Ended
    }

    struct Voter {
        bool voted;
        uint256 vote;
    }

    struct Candidate {
        bytes32 name;
        uint256 voteCount;
    }

    // State Variables
    address public admin;
    VoteStatus public voteStatus;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    // Events
    event Voted(address indexed voter, bytes32 indexed candidateName);

    // Modifiers
    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert SimpleVoting__OnlyAdmin();
        }

        _;
    }

    constructor(bytes32[] memory candidateNames) {
        admin = msg.sender;

        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({name: candidateNames[i], voteCount: 0}));
        }
    }

    /**
     * @dev End Voting
     * @notice Only admin can call this function
     */
    function endVoting() public onlyAdmin {
        voteStatus = VoteStatus.Ended;
    }

    /**
     * @dev Vote for a candidate
     * @notice Only valid candidates can be voted for and voters can only vote once
     * @param candidateName Name of the candidate to vote for
     */
    function vote(bytes32 candidateName) public {
        // Check if voting has ended
        if (voteStatus == VoteStatus.Ended) {
            revert SimpleVoting__VotingHasEnded();
        }

        // Check if voter has already voted
        if (voters[msg.sender].voted) {
            revert SimpleVoting__AlreadyVoted();
        }

        // Get candidate index
        uint256 candidateIndex = getCandidateIndex(candidateName);

        voters[msg.sender].voted = true;
        voters[msg.sender].vote = candidateIndex;
        candidates[candidateIndex].voteCount++;

        emit Voted(msg.sender, candidateName);
    }

    /**
     * @dev Get candidate index
     * @notice Only admin can call this function
     * @param candidateName Name of the candidate to get index for
     * @return candidateIndex Index of the candidate
     */
    function getCandidateIndex(bytes32 candidateName) private view returns (uint256) {
        // Check if candidate exists and return index if it does
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].name == candidateName) {
                return i;
            }
        }

        // Candidate does not exist then revert
        revert SimpleVoting__InvalidCandidate();
    }

    function getCandidateVoteCount(bytes32 candidateName) public view returns (uint256) {
        uint256 candidateIndex = getCandidateIndex(candidateName);

        return candidates[candidateIndex].voteCount;
    }

    /**
     * @dev Get winner
     * @notice Only admin can call this function
     * @return winners Winners of the election
     */
    function getWinner() public view returns (bytes32[] memory) {
        uint256 highestVoteCount = 0;
        uint256 winnerCount = 0;

        // Get highest vote count
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > highestVoteCount) {
                highestVoteCount = candidates[i].voteCount;
            }
        }

        // Get winner count
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount == highestVoteCount) {
                winnerCount++;
            }
        }

        bytes32[] memory winners = new bytes32[](winnerCount);
        uint256 index = 0;

        // Get winners
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount == highestVoteCount) {
                winners[index] = candidates[i].name;
                index++;
            }
        }

        return winners;
    }
}
