const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN = "0xe7fBb54ff84134C999d6B04AC71a16C3E73Bb57f";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🧪 Create Task + Complete via EigenCloud\n");
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtension", EIGEN);
  
  // Create new task
  console.log("📋 Creating new task...");
  const tx1 = await arp.createTask("Review DeFi protocol security", { value: hre.ethers.utils.parseEther("0.001") });
  await tx1.wait();
  
  // Get task ID (should be 1)
  const taskId = 1;
  const task = await arp.getTask(taskId);
  console.log("✅ Task created! ID:", taskId);
  console.log("Description:", task.description);
  console.log("Completed:", task.isCompleted);
  
  // Complete via EigenCloud
  console.log("\n🔐 Completing via EigenCloud...");
  const crypto = require('crypto');
  const solution = "DeFi protocol reviewed. 2 medium risk issues found and documented.";
  const proofData = JSON.stringify({ solution, timestamp: Date.now(), model: 'eigenai' });
  const proofHash = "0x" + crypto.createHash('sha256').update(proofData).digest('hex');
  const timestamp = Math.floor(Date.now() / 1000);
  
  console.log("Proof Hash:", proofHash);
  
  try {
    const tx2 = await eigen.completeTaskEigenAI(taskId, solution, proofHash, timestamp);
    console.log("Transaction:", tx2.hash);
    await tx2.wait();
    console.log("✅ Task completed with EigenCloud proof!");
    
    // Verify
    const storedProof = await eigen.taskProofs(taskId);
    console.log("\n📊 Proof stored:");
    console.log("Verified:", storedProof.verified);
    console.log("Type:", storedProof.vType.toString(), "(1=EIGENAI)");
    
    const agent = await arp.getAgent(deployer.address);
    console.log("\n📈 Reputation:", agent.reputationScore.toString());
    console.log("Tasks:", agent.tasksCompleted.toString());
    
  } catch (e) {
    console.log("❌ Error:", e.reason || e.message);
  }
}

main().catch(console.error);
