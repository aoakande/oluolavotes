import { callReadOnlyFunction, uintCV } from '@stacks/transactions';
import { StacksMainnet } from '@stacks/network';

const network = new StacksMainnet();
const contractAddress = 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7';
const contractName = 'voting-system';

export const fetchProposals = async () => {
  // Before deploying, I will need to implement pagination and fetching of multiple proposals
  const proposal = await callReadOnlyFunction({
    contractAddress,
    contractName,
    functionName: 'get-proposal',
    functionArgs: [uintCV(1)],
    network,
  });

  return proposal ? [proposal.value] : [];
};

export const getContractInfo = () => ({
  contractAddress,
  contractName,
});
