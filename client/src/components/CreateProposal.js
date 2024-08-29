import React, { useState } from 'react';
import { stringAsciiCV } from '@stacks/transactions';
import { getContractInfo } from './votingApi';

const CreateProposal = ({ doContractCall, onProposalCreated }) => {
  const [newProposal, setNewProposal] = useState({ title: '', description: '' });
  const { contractAddress, contractName } = getContractInfo();

  const handleCreateProposal = async () => {
    await doContractCall({
      contractAddress,
      contractName,
      functionName: 'create-proposal',
      functionArgs: [stringAsciiCV(newProposal.title), stringAsciiCV(newProposal.description)],
      onFinish: (data) => {
        console.log('Proposal created:', data);
        onProposalCreated();
        setNewProposal({ title: '', description: '' });
      },
      onCancel: () => {
        console.log('Proposal creation cancelled');
      },
    });
  };

  return (
    <div>
      <h2>Create Proposal</h2>
      <input
        type="text"
        placeholder="Title"
        value={newProposal.title}
        onChange={(e) => setNewProposal({ ...newProposal, title: e.target.value })}
      />
      <input
        type="text"
        placeholder="Description"
        value={newProposal.description}
        onChange={(e) => setNewProposal({ ...newProposal, description: e.target.value })}
      />
      <button onClick={handleCreateProposal}>Create Proposal</button>
    </div>
  );
};

export default CreateProposal;
