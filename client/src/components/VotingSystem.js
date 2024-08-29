import React, { useState, useEffect } from 'react';
import { useConnect } from '@stacks/connect-react';
import { fetchProposals } from '../utils/votingApi';
import ProposalList from './ProposalList';
import CreateProposal from './CreateProposal';

const VotingSystem = () => {
  const { doContractCall } = useConnect();
  const [proposals, setProposals] = useState([]);

  useEffect(() => {
    const getProposals = async () => {
      const fetchedProposals = await fetchProposals();
      setProposals(fetchedProposals);
    };
    getProposals();
  }, []);

  const refreshProposals = async () => {
    const fetchedProposals = await fetchProposals();
    setProposals(fetchedProposals);
  };

  return (
    <div>
      <h1>Decentralized Voting System</h1>
      <CreateProposal doContractCall={doContractCall} onProposalCreated={refreshProposals} />
      <ProposalList proposals={proposals} doContractCall={doContractCall} onVoteOrEnd={refreshProposals} />
    </div>
  );
};

export default VotingSystem;
