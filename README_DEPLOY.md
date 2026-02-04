# Deploy to Base Testnet

## Prerequisites
1. Node.js 18+
2. npm install ethers dotenv
3. Base Sepolia ETH for gas

## Setup
```bash
npm install ethers dotenv
```

## Environment
Create `.env` file:
```env
BASE_SEPOLIA_RPC=https://sepolia.base.org
DEPLOYER_PRIVATE_KEY=0x...
```

## Deploy
```bash
npx hardhat run deploy.js --network baseSepolia
```

## Contract Address
After deployment, address will be saved to `.contract地址.txt`

## Base Sepolia Faucet
Get testnet ETH:
- https://faucet.base.org/
- https://cloud.base.org/faucet

## Verified Contract
Verify on BaseScan:
```bash
npx hardhat verify --network baseSepolia CONTRACT_ADDRESS
```

## Contract Features
- ✅ Agent registration with stake
- ✅ Transaction attestations
- ✅ Unified scoring (50% ARP + 50% Ethos)
- ✅ Delegated staking
- ✅ Shared slashing
- ✅ Risk assessment

## Demo Agents
Contract pre-registers:
- Gaurang-Desai (Legendary, 114.7 score)
- Trustworthy-Alice (Established, 72.2 score)
- ScamBot-Eve (Blacklisted, 5.6 score)

## Integration
Call `updateEthosScore()` to sync with Ethos Network:
```javascript
await contract.updateEthosScore(agentAddress, ethosScore);
```
