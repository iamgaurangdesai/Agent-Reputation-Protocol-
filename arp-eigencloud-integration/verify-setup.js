const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN = "0xe7fBb54ff84134C999d6B04AC71a16C3E73Bb57f";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🔍 Verifying Setup\n");
  console.log("Wallet:", deployer.address);
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtension", EIGEN);
  
  // Check ARP
  console.log("\n📋 ARP Contract:", ARP);
  const agent = await arp.getAgent(deployer.address);
  console.log("Is Registered:", agent.isRegistered);
  console.log("Reputation:", agent.reputationScore.toString());
  
  // Check EigenCloud
  console.log("\n📋 EigenCloud Extension:", EIGEN);
  const linkedARP = await eigen.arp();
  console.log("Linked ARP:", linkedARP);
  console.log("Expected:", ARP);
  console.log("Match:", linkedARP.toLowerCase() === ARP.toLowerCase());
}

main().catch(console.error);
