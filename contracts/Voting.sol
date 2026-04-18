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

    /// @notice Cast a vote for a candidate
    /// @param candidateIndex The index of the candidate to vote for
    function vote(uint256 candidateIndex) public {
        if (hasVoted[msg.sender]) revert AlreadyVoted(msg.sender);
        if (candidateIndex > candidates.length - 1)
            revert InvalidCandidate(candidateIndex);

        hasVoted[msg.sender] = true;
        ++candidates[candidateIndex].voteCount;
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
}
