const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN_V2 = "0x6c85e66dfEEd28A66c930C8B3636a40fFC969177";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("📊 Checking Final Test Results\n");
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtensionV2", EIGEN_V2);
  
  const agent = await arp.getAgent(deployer.address);
  const stats = await eigen.getAgentStats(deployer.address);
  const boost = await eigen.getBoostedReputation(deployer.address);
  
  console.log("Agent:", deployer.address);
  console.log("Name:", agent.name);
  console.log("Reputation:", agent.reputationScore.toString());
  console.log("Tasks:", agent.tasksCompleted.toString());
  console.log("Verified Tasks:", stats.verifiedTasks.toString());
  console.log("Multiplier:", (stats.currentMultiplier / 100).toFixed(2) + "x");
  console.log("Boosted Rep:", boost.boostedScore.toString());
  
  // Check task 10
  const task10 = await arp.getTask(10);
  if (task10.reward > 0) {
    console.log("\nTask #10:");
    console.log("  Completed:", task10.isCompleted);
    console.log("  Agent:", task10.agent);
    
    const proof = await eigen.hasProof(10);
    console.log("  Has EigenCloud Proof:", proof);
  }
  
  console.log("\n✅ System is operational!");
}

main().catch(console.error);
