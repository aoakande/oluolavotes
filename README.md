# Decentralized Voting System Smart Contract

## Overview

This Clarity 3.0 smart contract implements a basic decentralized voting system on the Stacks blockchain. It allows users to create proposals, vote on them, and enables the contract owner to end voting periods.

## Features

- Create proposals with titles and descriptions
- Vote on proposals (for or against)
- Retrieve proposal information
- Check individual votes
- Time-limited voting periods
- Admin function to end voting

## Contract Details

### Constants

- `CONTRACT_OWNER`: The principal who deployed the contract
- `VOTING_PERIOD`: The duration of the voting period in blocks

### Data Structures

- `Proposals`: A map storing proposal details
- `Votes`: A map tracking user votes

### Functions

#### Read-Only Functions

1. `get-proposal (proposal-id uint)`
   - Retrieves details of a specific proposal

2. `get-vote (voter principal) (proposal-id uint)`
   - Retrieves a user's vote for a specific proposal

#### Public Functions

1. `create-proposal (title (string-utf8 50)) (description (string-utf8 500))`
   - Creates a new proposal
   - Returns the new proposal ID

2. `vote (proposal-id uint) (vote bool)`
   - Allows a user to vote on a proposal
   - `vote` is `true` for "yes" and `false` for "no"

#### Admin Functions

1. `end-voting (proposal-id uint)`
   - Ends the voting period for a specific proposal
   - Can only be called by the contract owner
   - Can only be called after the voting period has ended

## Usage

### Creating a Proposal

To create a proposal, call the `create-proposal` function with a title and description:

```clarity
(contract-call? .voting-system create-proposal "Proposal Title" "Proposal Description")
```

### Voting on a Proposal

To vote on a proposal, call the vote function with the proposal ID and your vote:

```(contract-call? .voting-system vote u1 true)```

### Retrieving Proposal Information

To get information about a proposal:
```(contract-call? .voting-system get-proposal u1)```

### Checking a Vote

To check a specific user's vote:
```(contract-call? .voting-system get-vote 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u1)```

### Error Codes

u1: Proposal not found
u2: Voting period has ended
u3: User has already voted
u4: Voting period not yet ended
u5: Not authorized (not contract owner)

### Security Considerations

The contract does not implement any access control for proposal creation. Consider adding restrictions if needed.
There's no mechanism to prevent the contract owner from ending voting prematurely. Additional checks could be implemented for increased security.
The contract doesn't handle potential integer overflow in vote counting. For high-stakes voting, additional safeguards should be implemented.

### Future Improvements

Implement token-gated voting
Add different voting mechanisms (e.g., quadratic voting)
Include proposal execution based on voting results
Expand the proposal structure to include more details
Implement a more sophisticated admin system with multiple privileges
