const { ethers } = require('ethers');
require('dotenv').config();

// Base Sepolia RPC
const RPC_URL = process.env.BASE_SEPOLIA_RPC || 'https://sepolia.base.org';
const PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY;

async function main() {
    console.log('🚀 Deploying Agent Reputation Protocol to Base Sepolia...');
    
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    
    console.log('📤 Deployer:', wallet.address);
    
    // Get factory
    const artifact = require('./artifacts/contracts/AgentReputationProtocol.sol/AgentReputationProtocol.json');
    const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, wallet);
    
    console.log('📦 Deploying contract...');
    const contract = await factory.deploy();
    await contract.waitForDeployment();
    
    const address = await contract.getAddress();
    console.log('✅ Deployed at:', address);
    
    // Save address
    require('fs').writeFileSync('.contract地址.txt', address);
    console.log('📁 Address saved to .contract地址.txt');
}

main()
    .then(() => process.exit(0))
    .catch((e) => { console.error(e); process.exit(1); });
