# SimpleVoting

A decentralized voting smart contract built with Solidity and deployed using Foundry. This contract allows users to vote for predefined candidates in a secure and transparent manner, with only the admin able to end the voting process.

## Overview

The `SimpleVoting` contract provides a straightforward voting system. Key features include:
- Admin-controlled voting process
- One vote per user
- Support for multiple candidates
- Transparent vote counting
- Event emission for vote tracking
- Ability to handle ties by returning multiple winners

## Prerequisites

To work with this project, ensure you have the following installed:
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Solidity](https://docs.soliditylang.org/en/latest/installing-solidity.html) (version ^0.8.13)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/truthixify/simple-voting.git
   cd simple-voting
   ```

2. Install Foundry dependencies:
   ```bash
   forge install
   ```

3. Build the project:
   ```bash
   forge build
   ```

## Usage

### Deploying the Contract

To deploy the contract, you need to provide a list of candidate names (as `bytes32` values). A deployment script is provided in `script/SimpleVoting.s.sol`. Use the following command to deploy on a local network:

```bash
forge script script/SimpleVotingScript.sol:SimpleVotingScript --rpc-url http://127.0.0.1:8545 --private-key <your-private-key> --broadcast
```

To deploy with specific candidate names, modify the `deploySimpleVoting` function call in the script or interact with it programmatically. For example, to deploy with candidates "Candidate1", "Candidate2", and "Candidate3":

```solidity
bytes32[] memory candidateNames = new bytes32[](3);
candidateNames[0] = bytes32("Candidate1");
candidateNames[1] = bytes32("Candidate2");
candidateNames[2] = bytes32("Candidate3");
deploySimpleVoting(candidateNames);
```

### Interacting with the Contract

- **Vote**: Call the `vote(bytes32 candidateName)` function with the candidate's name to cast a vote. Only one vote per address is allowed.
- **End Voting**: The admin can call `endVoting()` to close the voting process.
- **Check Vote Count**: Use `getCandidateVoteCount(bytes32 candidateName)` to retrieve the number of votes for a specific candidate.
- **Get Winner**: Call `getWinner()` to retrieve the name(s) of the candidate(s) with the highest votes.

Example interaction using `cast`:
```bash
cast call <contract-address> "vote(bytes32)" <candidate-name> --rpc-url http://127.0.0.1:8545 --private-key <your-private-key>
```

### Testing

Run the tests using Foundry:
```bash
forge test
```

To see detailed test output:
```bash
forge test -vvv
```

### Contract Details

- **Admin**: The deployer of the contract is set as the admin, who can end the voting process.
- **Vote Status**: The voting process can be `Active` or `Ended`.
- **Errors**:
  - `SimpleVoting__AlreadyVoted`: Thrown if a user tries to vote more than once.
  - `SimpleVoting__InvalidCandidate`: Thrown if the candidate name is not found.
  - `SimpleVoting__VotingHasEnded`: Thrown if a vote is attempted after voting has ended.
  - `SimpleVoting__OnlyAdmin`: Thrown if a non-admin tries to call admin-only functions.
- **Events**:
  - `Voted(address voter, bytes32 candidateName)`: Emitted when a vote is cast.

## Project Structure

```
simple-voting/
├── src/
│   └── SimpleVoting.sol  # The main smart contract
├── script/
│   └── SimpleVoting.s.sol  # Deployment script
├── test/
│   └── SimpleVoting.t.sol  # Test suite
├── README.md  # This file
└── foundry.toml  # Foundry configuration
```