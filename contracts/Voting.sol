// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title A decentralized voting system
/// @author Katerina & Mike
/// @notice Allows voters to cast one vote each for a list of candidates
contract Voting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    /// @notice List of all candidates
    Candidate[] public candidates;
    /// @notice Tracks whether an address has already voted
    mapping(address => bool) public hasVoted;
    /// @notice The address that deployed this contract
    address public owner;

    constructor(string[] memory candidateNames) {
        owner = msg.sender;
        for (uint256 i = 0; i < candidateNames.length; ++i) {
            candidates.push(Candidate({name: candidateNames[i], voteCount: 0}));
        }
    }

    error AlreadyVoted(address voter);
    error InvalidCandidate(uint256 index);
    error NoVotesCast();

    /// @notice Emitted when a vote is cast
    /// @param voter The address that cast the vote
    /// @param candidateIndex The index of the candidate that was voted for
    event VoteCast(address indexed voter, uint256 indexed candidateIndex);

    /// @notice Cast a vote for a candidate
    /// @param candidateIndex The index of the candidate to vote for
    function vote(uint256 candidateIndex) public {
        if (hasVoted[msg.sender]) revert AlreadyVoted(msg.sender);
        if (candidateIndex > candidates.length - 1)
            revert InvalidCandidate(candidateIndex);

        hasVoted[msg.sender] = true;
        ++candidates[candidateIndex].voteCount;

        emit VoteCast(msg.sender, candidateIndex);
    }

    /// @notice Get a candidate's name and vote count
    /// @param candidateIndex The index of the candidate
    function getCandidate(
        uint256 candidateIndex
    ) public view returns (string memory, uint256) {
        if (candidateIndex > candidates.length - 1)
            revert InvalidCandidate(candidateIndex);
        Candidate memory c = candidates[candidateIndex];
        return (c.name, c.voteCount);
    }

    /// @notice Get the current winning candidate(s)
    /// @return winnerNames Array of names of candidates with the most votes
    /// @return isTie Whether there is a tie between candidates
    function getWinner()
        public
        view
        returns (string[] memory winnerNames, bool isTie)
    {
        uint256 winningVoteCount = 0;

        // Check if any votes have been cast
        for (uint256 i = 0; i < candidates.length; ++i) {
            if (candidates[i].voteCount > 0) {
                winningVoteCount = candidates[i].voteCount;
                break;
            }
        }
        if (winningVoteCount == 0) revert NoVotesCast();

        // First pass — find the highest vote count
        for (uint256 i = 0; i < candidates.length; ++i) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
            }
        }

        // Count how many candidates share that vote count
        uint256 winnerCount = 0;
        for (uint256 i = 0; i < candidates.length; ++i) {
            if (candidates[i].voteCount == winningVoteCount) {
                ++winnerCount;
            }
        }

        // Build the winners array
        winnerNames = new string[](winnerCount);
        uint256 j = 0;
        for (uint256 i = 0; i < candidates.length; ++i) {
            if (candidates[i].voteCount == winningVoteCount) {
                winnerNames[j] = candidates[i].name;
                ++j;
            }
        }

        isTie = winnerCount > 1;
    }
}
