const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 Completing task via ARP directly\n");
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  
  const taskId = 0;
  const solution = "Smart contract analyzed. No reentrancy vulnerabilities found.";
  
  console.log("Task ID:", taskId);
  console.log("Solution:", solution);
  
  try {
    const tx = await arp.completeTask(taskId, solution);
    console.log("Transaction:", tx.hash);
    await tx.wait();
    console.log("✅ Task completed!");
    
    const task = await arp.getTask(taskId);
    console.log("Task completed status:", task.isCompleted);
    console.log("Completed by:", task.agent);
    
    const agent = await arp.getAgent(deployer.address);
    console.log("\nNew Reputation:", agent.reputationScore.toString());
    console.log("Tasks Completed:", agent.tasksCompleted.toString());
  } catch (e) {
    console.log("❌ Error:", e.reason || e.message);
  }
}

main().catch(console.error);
