import React from 'react';
// import Proposal from './Proposal';

const ProposalList = ({ proposals, doContractCall, onVoteOrEnd }) => {
  return (
    <div>
      <h2>Proposals</h2>
      {proposals.map((proposal) => (
        <Proposal
          key={proposal.proposalId}
          proposal={proposal}
          doContractCall={doContractCall}
          onVoteOrEnd={onVoteOrEnd}
        />
      ))}
    </div>
  );
};

export default ProposalList;
