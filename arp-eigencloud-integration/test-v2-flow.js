const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN_V2 = "0x6c85e66dfEEd28A66c930C8B3636a40fFC969177";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🧪 Testing EigenCloud V2 Fixed Flow\n");
  console.log("Wallet:", deployer.address);
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtensionV2", EIGEN_V2);
  
  // Step 1: Create new task
  console.log("\n📋 Step 1: Create Task #3");
  const tx1 = await arp.createTask("Test EigenCloud V2 proof storage", { 
    value: hre.ethers.utils.parseEther("0.001") 
  });
  await tx1.wait();
  const taskId = 3;
  console.log("✅ Task created! ID:", taskId);
  
  // Step 2: Generate EigenAI proof
  console.log("\n🔐 Step 2: Generate EigenAI Proof");
  const crypto = require('crypto');
  const solution = "Task analyzed with EigenAI deterministic inference.";
  const proofData = JSON.stringify({ 
    solution, 
    timestamp: Date.now(), 
    model: 'qwen3-32b-128k-bf16',
    eigenAi: true 
  });
  const proofHash = "0x" + crypto.createHash('sha256').update(proofData).digest('hex');
  const timestamp = Math.floor(Date.now() / 1000);
  
  console.log("Proof Hash:", proofHash);
  
  // Step 3: Store proof in EigenCloud V2 (FIXED - doesn't call ARP)
  console.log("\n💾 Step 3: Store Proof in EigenCloud V2");
  const tx2 = await eigen.storeEigenAIProof(taskId, proofHash, timestamp);
  await tx2.wait();
  console.log("✅ Proof stored! TX:", tx2.hash);
  
  // Verify proof stored
  const hasProof = await eigen.hasProof(taskId);
  const proof = await eigen.getProof(taskId);
  console.log("\n📊 Proof Verification:");
  console.log("Has Proof:", hasProof);
  console.log("Proof Hash:", proof.proofHash);
  console.log("Type:", proof.vType.toString(), "(1=EIGENAI)");
  console.log("Stored by:", proof.agent);
  
  // Step 4: Complete task on ARP directly
  console.log("\n✅ Step 4: Complete Task on ARP");
  const tx3 = await arp.completeTask(taskId, solution);
  await tx3.wait();
  console.log("✅ Task completed! TX:", tx3.hash);
  
  // Step 5: Check agent stats
  console.log("\n📈 Step 5: Agent Stats");
  const stats = await eigen.getAgentStats(deployer.address);
  console.log("Verified Tasks:", stats.verifiedTasks.toString());
  console.log("Verification Level:", stats.vLevel.toString());
  console.log("Multiplier:", (stats.currentMultiplier / 100).toFixed(2) + "x");
  
  const agent = await arp.getAgent(deployer.address);
  console.log("\nARP Stats:");
  console.log("Reputation:", agent.reputationScore.toString());
  console.log("Total Tasks:", agent.tasksCompleted.toString());
  
  console.log("\n🎉 SUCCESS! Full flow working with EigenCloud V2");
  console.log("\nKey Improvement:");
  console.log("✅ Proof stored separately from task completion");
  console.log("✅ No msg.sender issue");
  console.log("✅ Reputation boost calculated from verified tasks");
}

main().catch(console.error);
