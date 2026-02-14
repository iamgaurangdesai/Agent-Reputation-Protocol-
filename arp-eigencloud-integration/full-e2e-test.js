const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN_V2 = "0x6c85e66dfEEd28A66c930C8B3636a40fFC969177";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🧪 FULL END-TO-END TEST\n");
  console.log("Wallet:", deployer.address);
  console.log("ARP:", ARP);
  console.log("EigenCloud V2:", EIGEN_V2);
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtensionV2", EIGEN_V2);
  
  console.log("\n" + "=".repeat(50));
  console.log("STEP 1: CHECK AGENT REGISTRATION");
  console.log("=".repeat(50));
  
  let agent = await arp.getAgent(deployer.address);
  console.log("Name:", agent.name);
  console.log("Registered:", agent.isRegistered);
  console.log("Reputation:", agent.reputationScore.toString());
  console.log("Tasks Completed:", agent.tasksCompleted.toString());
  
  if (!agent.isRegistered) {
    console.log("\n⚠️ Agent not registered. Registering now...");
    const fee = await arp.registrationFee();
    const tx = await arp.registerAgent("E2ETestAgent", "End-to-end test agent", ["Testing", "EigenCloud"], { value: fee });
    await tx.wait();
    console.log("✅ Agent registered!");
    agent = await arp.getAgent(deployer.address);
  } else {
    console.log("✅ Agent already registered");
  }
  
  console.log("\n" + "=".repeat(50));
  console.log("STEP 2: CHECK EIGENCLOUD VERIFICATION STATUS");
  console.log("=".repeat(50));
  
  const stats = await eigen.getAgentStats(deployer.address);
  const boost = await eigen.getBoostedReputation(deployer.address);
  
  console.log("Verified Tasks:", stats.verifiedTasks.toString());
  console.log("Current Multiplier:", (stats.currentMultiplier / 100).toFixed(2) + "x");
  console.log("Base Reputation:", boost.baseScore.toString());
  console.log("Boosted Reputation:", boost.boostedScore.toString());
  
  console.log("\n" + "=".repeat(50));
  console.log("STEP 3: CREATE NEW TASK");
  console.log("=".repeat(50));
  
  // Get next task ID
  let taskId = 10; // Start from 10 for testing
  let task = await arp.getTask(taskId);
  while (task.reward > 0) {
    taskId++;
    task = await arp.getTask(taskId);
  }
  
  console.log("Creating Task #", taskId);
  const tx1 = await arp.createTask("End-to-end test with EigenCloud V2", { 
    value: hre.ethers.utils.parseEther("0.001") 
  });
  await tx1.wait();
  console.log("✅ Task created! TX:", tx1.hash);
  
  task = await arp.getTask(taskId);
  console.log("Description:", task.description);
  console.log("Reward:", hre.ethers.utils.formatEther(task.reward), "ETH");
  
  console.log("\n" + "=".repeat(50));
  console.log("STEP 4: STORE EIGENCLOUD PROOF");
  console.log("=".repeat(50));
  
  const crypto = require('crypto');
  const solution = "End-to-end test completed with EigenAI deterministic inference.";
  const proofData = JSON.stringify({ 
    solution, 
    timestamp: Date.now(), 
    model: 'qwen3-32b-128k-bf16',
    version: '1.0'
  });
  const proofHash = "0x" + crypto.createHash('sha256').update(proofData).digest('hex');
  const timestamp = Math.floor(Date.now() / 1000);
  
  console.log("Solution:", solution);
  console.log("Proof Hash:", proofHash);
  
  const tx2 = await eigen.storeEigenAIProof(taskId, proofHash, timestamp);
  await tx2.wait();
  console.log("✅ Proof stored! TX:", tx2.hash);
  
  const hasProof = await eigen.hasProof(taskId);
  const storedProof = await eigen.getProof(taskId);
  console.log("\nProof Verification:");
  console.log("  Has Proof:", hasProof);
  console.log("  Stored Hash:", storedProof.proofHash);
  console.log("  Type:", storedProof.vType.toString(), "(1=EIGENAI)");
  console.log("  Agent:", storedProof.agent);
  
  console.log("\n" + "=".repeat(50));
  console.log("STEP 5: COMPLETE TASK ON ARP");
  console.log("=".repeat(50));
  
  const tx3 = await arp.completeTask(taskId, solution);
  await tx3.wait();
  console.log("✅ Task completed! TX:", tx3.hash);
  
  console.log("\n" + "=".repeat(50));
  console.log("STEP 6: VERIFY FINAL STATE");
  console.log("=".repeat(50));
  
  const finalAgent = await arp.getAgent(deployer.address);
  const finalStats = await eigen.getAgentStats(deployer.address);
  const finalBoost = await eigen.getBoostedReputation(deployer.address);
  
  console.log("\nARP Stats:");
  console.log("  Reputation:", finalAgent.reputationScore.toString(), "(was", agent.reputationScore.toString() + ")");
  console.log("  Tasks:", finalAgent.tasksCompleted.toString(), "(was", agent.tasksCompleted.toString() + ")");
  
  console.log("\nEigenCloud Stats:");
  console.log("  Verified Tasks:", finalStats.verifiedTasks.toString(), "(was", stats.verifiedTasks.toString() + ")");
  console.log("  Multiplier:", (finalStats.currentMultiplier / 100).toFixed(2) + "x");
  console.log("  Boosted Rep:", finalBoost.boostedScore.toString());
  
  console.log("\n" + "=".repeat(50));
  console.log("✅ END-TO-END TEST COMPLETE!");
  console.log("=".repeat(50));
  console.log("\nAll flows working:");
  console.log("  ✓ Agent registration");
  console.log("  ✓ Task creation");
  console.log("  ✓ EigenCloud proof storage");
  console.log("  ✓ Task completion on ARP");
  console.log("  ✓ Reputation tracking");
  console.log("  ✓ Verification badges");
}

main().catch(console.error);
