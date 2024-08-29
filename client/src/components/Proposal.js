import React from 'react';
import { uintCV, trueCV, falseCV } from '@stacks/transactions';
import { getContractInfo } from '../utils/votingApi';

const Proposal = ({ proposal, doContractCall, onVoteOrEnd }) => {
  const { contractAddress, contractName } = getContractInfo();

  const handleVote = async (voteFor) => {
    await doContractCall({
      contractAddress,
      contractName,
      functionName: 'vote',
      functionArgs: [uintCV(proposal.proposalId), voteFor ? trueCV() : falseCV()],
      onFinish: (data) => {
        console.log('Vote cast:', data);
        onVoteOrEnd();
      },
      onCancel: () => {
        console.log('Voting cancelled');
      },
    });
  };

  const handleEndVoting = async () => {
    await doContractCall({
      contractAddress,
      contractName,
      functionName: 'end-voting',
      functionArgs: [uintCV(proposal.proposalId)],
      onFinish: (data) => {
        console.log('Voting ended:', data);
        onVoteOrEnd();
      },
      onCancel: () => {
        console.log('End voting cancelled');
      },
    });
  };

  return (
    <div>
      <h3>{proposal.title}</h3>
      <p>{proposal.description}</p>
      <p>Votes For: {proposal.votesFor}</p>
      <p>Votes Against: {proposal.votesAgainst}</p>
      <button onClick={() => handleVote(true)}>Vote For</button>
      <button onClick={() => handleVote(false)}>Vote Against</button>
      <button onClick={handleEndVoting}>End Voting</button>
    </div>
  );
};

export default Proposal;
