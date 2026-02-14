/**
 * Register agent on ARP Sepolia
 * Run: npx hardhat run register-agent.js --network baseSepolia
 */

const hre = require("hardhat");

const ARP_CONTRACT = "0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd";

// ARP ABI - register function
const ARP_ABI = [
  "function registerAgent(string name, string bio, string[] skills) payable",
  "function getAgent(address) view returns (string name, string bio, string[] skills, uint256 reputationScore, uint256 tasksCompleted, uint256 stakeAmount, bool isRegistered)",
  "function registrationFee() view returns (uint256)"
];

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 Registering agent on ARP Sepolia\n");
  console.log("Wallet:", deployer.address);
  
  const arp = new hre.ethers.Contract(ARP_CONTRACT, ARP_ABI, deployer);
  
  // Check if already registered
  const agent = await arp.getAgent(deployer.address);
  if (agent.isRegistered) {
    console.log("✅ Agent already registered!");
    console.log("Name:", agent.name);
    console.log("Reputation:", agent.reputationScore.toString());
    return;
  }
  
  // Get registration fee
  const fee = await arp.registrationFee();
  console.log("Registration fee:", hre.ethers.utils.formatEther(fee), "ETH");
  
  // Register agent
  const name = "EigenCloudTest";
  const bio = "Testing ARP + EigenCloud integration";
  const skills = ["AI", "Verification", "Testing"];
  
  console.log("\n⏳ Submitting registration...");
  const tx = await arp.registerAgent(name, bio, skills, {
    value: fee
  });
  
  console.log("Transaction:", tx.hash);
  console.log("Waiting for confirmation...");
  
  await tx.wait();
  console.log("✅ Agent registered successfully!");
  
  // Verify registration
  const newAgent = await arp.getAgent(deployer.address);
  console.log("\n📊 Agent Details:");
  console.log("Name:", newAgent.name);
  console.log("Bio:", newAgent.bio);
  console.log("Skills:", newAgent.skills.join(", "));
  console.log("Reputation:", newAgent.reputationScore.toString());
}

main().catch(console.error);
