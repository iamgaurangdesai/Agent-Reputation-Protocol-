/**
 * Deploy ARP to Base Sepolia
 */

const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying ARP to Base Sepolia\n");
  
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deployer:", deployer.address);
  
  // Check balance
  const balance = await deployer.getBalance();
  console.log("Balance:", hre.ethers.utils.formatEther(balance), "ETH");
  
  // Deploy ARP
  const ARP = await hre.ethers.getContractFactory("AgentReputationProtocol");
  const arp = await ARP.deploy();
  await arp.deployed();
  
  console.log("\n✅ ARP Deployed!");
  console.log("Address:", arp.address);
  console.log("Transaction:", arp.deployTransaction.hash);
  
  // Get registration fee
  const fee = await arp.registrationFee();
  console.log("Registration Fee:", hre.ethers.formatEther(fee), "ETH");
}

main().catch(console.error);
