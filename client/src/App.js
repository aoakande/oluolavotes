import React from 'react';
import { Connect } from '@stacks/connect-react';
import VotingSystem from './components/VotingSystem';

const App = () => {
  const appDetails = {
    name: 'Decentralized Voting System',
    icon: '/path/to/your/icon.png',
  };

  return (
    <Connect authOptions={{ appDetails }}>
      <div className="App">
        <VotingSystem />
      </div>
    </Connect>
  );
};

export default App;
