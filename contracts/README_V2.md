# AgentReputationProtocol V2 - USDC Edition

## Deployment Guide

### Prerequisites
- Base Sepolia ETH (for gas)
- Base Sepolia USDC address: `0x036CbD53842c5426634e7929541eC2318f3dCF7e`

### Deploy Steps

1. **Go to Remix IDE**
   ```
   https://remix.ethereum.org
   ```

2. **Create new file**: `AgentReputationProtocolV2.sol`
   - Paste contract code from GitHub

3. **Compile**
   - Compiler version: `0.8.19`
   - Enable optimization: `200` runs

4. **Deploy**
   - Environment: `Injected Provider - MetaMask`
   - Network: Base Sepolia
   - Constructor arguments: 
     - `_usdcAddress`: `0x036CbD53842c5426634e7929541eC2318f3dCF7e` (USDC)
     - `_initialOwner`: `YOUR_WALLET_ADDRESS` (your deployer address)
   - Click Deploy

5. **Verify Contract**
   - Go to Base Sepolia Explorer
   - Find your contract
   - Verify & Publish

### Contract Addresses

| Network | USDC Address | ARP V2 Address |
|---------|-------------|----------------|
| Base Sepolia | `0x036CbD53842c5426634e7929541eC2318f3dCF7e` | `DEPLOY_YOURS` |
| Base Mainnet | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` | `DEPLOY_YOURS` |

### Key Changes from V1

| Feature | V1 (ETH) | V2 (USDC) |
|---------|----------|-----------|
| Min Stake | 10 ETH | $1 USDC |
| Max Stake | Unlimited | $10 USDC |
| Token | Native ETH | USDC ERC20 |
| Gas Cost | Higher | Lower |
| Accessibility | Hard | Easy |

### How to Use

1. **Get USDC on Base Sepolia**
   ```
   https://faucet.circle.com/
   ```
   - Select "Base Sepolia"
   - Enter your wallet
   - Get test USDC

2. **Approve USDC**
   ```javascript
   // Before registering, approve the contract to spend your USDC
   await usdc.approve(ARP_CONTRACT_ADDRESS, 10000000); // $10 USDC
   ```

3. **Register Agent**
   ```javascript
   // Stake $5 USDC (5000000 with 6 decimals)
   await arp.registerAgent("MyAgent", 5000000);
   ```

### Functions

#### Write Functions
- `registerAgent(name, stakeUsdc)` - Register with $1-10 USDC
- `increaseStake(additionalUsdc)` - Add more stake (up to $10)
- `withdrawStake(amountUsdc)` - Remove stake
- `recordTransaction(to, amount)` - Record TX between agents
- `attestTransaction(txHash, rating, feedback)` - Rate a transaction

#### Read Functions
- `getAgent(wallet)` - Get agent profile
- `getLeaderboard()` - Get ranked list
- `getStakeLimits()` - Returns (min, max) in USDC
- `agents(wallet)` - Direct agent data access

### Testing

```javascript
// 1. Connect wallet
// 2. Get USDC from faucet
// 3. Approve USDC for contract
// 4. Register agent with $5 USDC
// 5. View profile
// 6. Check leaderboard
```

### Frontend Integration

Update demo.html:
```javascript
const CONTRACT_ADDRESS = 'YOUR_NEW_CONTRACT_ADDRESS';
const USDC_ADDRESS = '0x036CbD53842c5426634e7929541eC2318f3dCF7e';

// Add approve step before register
const usdc = new ethers.Contract(USDC_ADDRESS, ERC20_ABI, signer);
await usdc.approve(CONTRACT_ADDRESS, stakeAmount);

// Then register
await contract.registerAgent(name, stakeAmount);
```

### Security Notes

- Contract holds USDC, not ETH
- Users can withdraw stake anytime
- Owner can update Ethos scores
- Min/Max stake enforced on-chain
