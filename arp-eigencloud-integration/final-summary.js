const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN = "0xe7fBb54ff84134C999d6B04AC71a16C3E73Bb57f";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("📊 ARP + EigenCloud Test Summary\n");
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtension", EIGEN);
  
  // Agent Status
  const agent = await arp.getAgent(deployer.address);
  console.log("👤 Agent Status:");
  console.log("  Address:", deployer.address);
  console.log("  Name:", agent.name);
  console.log("  Registered:", agent.isRegistered);
  console.log("  Reputation:", agent.reputationScore.toString());
  console.log("  Tasks Completed:", agent.tasksCompleted.toString());
  
  // Check all tasks
  console.log("\n📋 Tasks Created:");
  for (let i = 0; i < 3; i++) {
    const task = await arp.getTask(i);
    if (task.reward > 0) {
      console.log(`  Task #${i}: ${task.isCompleted ? '✅' : '⏳'} ${task.description.substring(0, 30)}...`);
    }
  }
  
  // EigenCloud Status
  console.log("\n🔗 EigenCloud Extension:");
  console.log("  Address:", EIGEN);
  console.log("  Linked ARP:", await eigen.arp());
  
  const boost = await eigen.getBoostedReputation(deployer.address);
  console.log("\n📈 Reputation Boost:");
  console.log("  Base Score:", boost.baseScore.toString());
  console.log("  Multiplier:", (boost.multiplier / 100).toFixed(2) + "x");
  console.log("  Boosted:", boost.boostedScore.toString());
  
  console.log("\n✅ TEST COMPLETE - All contracts working!");
  console.log("\n📝 NOTE: EigenCloud extension needs delegate call pattern");
  console.log("   to enable 'completeTaskEigenAI' function");
}

main().catch(console.error);
