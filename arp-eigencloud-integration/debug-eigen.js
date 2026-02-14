const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN = "0xe7fBb54ff84134C999d6B04AC71a16C3E73Bb57f";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🔍 Debugging EigenCloud\n");
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  
  // Direct call to ARP
  console.log("Direct call to ARP:");
  const agent = await arp.getAgent(deployer.address);
  console.log("isRegistered:", agent.isRegistered);
  
  // Call through EigenCloud
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtension", EIGEN);
  
  // Try the getBoostedReputation function which also calls getAgent
  console.log("\nCall through EigenCloud:");
  try {
    const boost = await eigen.getBoostedReputation(deployer.address);
    console.log("Base Score:", boost.baseScore.toString());
    console.log("Success!");
  } catch (e) {
    console.log("Error:", e.reason || e.message);
  }
}

main().catch(console.error);
