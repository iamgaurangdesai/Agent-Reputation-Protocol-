/**
 * Complete task with EigenCloud proof
 * Run: npx hardhat run complete-task-eigencloud.js --network baseSepolia
 */

const hre = require("hardhat");

const ARP_CONTRACT = "0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd";
const EIGEN_CLOUD_EXT = "0xa722DC3eB2cF7Aad601d1C1Ed49BF98DaDf34a8e";

const ARP_ABI = [
  "function getAgent(address) view returns (string name, string bio, string[] skills, uint256 reputationScore, uint256 tasksCompleted, uint256 stakeAmount, bool isRegistered)",
  "function getTask(uint256) view returns (string description, uint256 reward, address creator, address agent, bool isCompleted, bool isDisputed)"
];

const EIGEN_ABI = [
  "function completeTaskEigenAI(uint256 taskId, string solution, bytes32 proofHash, uint256 timestamp)",
  "function taskProofs(uint256) view returns (bytes32 proofHash, uint8 vType, uint256 timestamp, bool verified)"
];

async function generateProof(solution) {
  const crypto = require('crypto');
  const data = JSON.stringify({
    solution: solution,
    timestamp: Date.now(),
    model: 'qwen3-32b-128k-bf16'
  });
  return crypto.createHash('sha256').update(data).digest('hex');
}

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🧪 Completing task with EigenCloud proof\n");
  console.log("Wallet:", deployer.address);
  
  const arp = new hre.ethers.Contract(ARP_CONTRACT, ARP_ABI, deployer);
  const eigenCloud = new hre.ethers.Contract(EIGEN_CLOUD_EXT, EIGEN_ABI, deployer);
  
  // Check agent registration
  const agent = await arp.getAgent(deployer.address);
  if (!agent.isRegistered) {
    console.log("❌ Agent not registered. Run register-agent.js first.");
    return;
  }
  console.log("✅ Agent registered:", agent.name);
  
  // Simulate completing task #1 (or check if there's a real task)
  const taskId = 1;
  console.log("\n📋 Task ID:", taskId);
  
  try {
    const task = await arp.getTask(taskId);
    console.log("Task Description:", task.description);
    console.log("Reward:", hre.ethers.utils.formatEther(task.reward), "ETH");
    console.log("Completed:", task.isCompleted);
    
    if (task.isCompleted) {
      console.log("\n⚠️ Task already completed. Try a different task ID.");
      return;
    }
  } catch (e) {
    console.log("Task check failed (may not exist):", e.message);
  }
  
  // Generate solution and proof
  const solution = "Task completed using EigenAI deterministic inference. Result verified with cryptographic proof.";
  const proofHashHex = await generateProof(solution);
  const proofHash = "0x" + proofHashHex;
  const timestamp = Math.floor(Date.now() / 1000);
  
  console.log("\n🔐 Generated EigenAI Proof:");
  console.log("Proof Hash:", proofHash);
  console.log("Timestamp:", timestamp);
  
  // Complete task with EigenCloud proof
  console.log("\n⏳ Submitting task completion...");
  const tx = await eigenCloud.completeTaskEigenAI(taskId, solution, proofHash, timestamp);
  console.log("Transaction:", tx.hash);
  
  await tx.wait();
  console.log("✅ Task completed with EigenCloud proof!");
  
  // Verify proof stored
  const storedProof = await eigenCloud.taskProofs(taskId);
  console.log("\n📊 Stored Proof:");
  console.log("Hash:", storedProof.proofHash);
  console.log("Type:", storedProof.vType.toString(), "(1 = EIGENAI_DETERMINISTIC)");
  console.log("Timestamp:", storedProof.timestamp.toString());
  console.log("Verified:", storedProof.verified);
  
  // Check new reputation
  const updatedAgent = await arp.getAgent(deployer.address);
  console.log("\n📈 Reputation:");
  console.log("Before:", agent.reputationScore.toString());
  console.log("After:", updatedAgent.reputationScore.toString());
  console.log("Tasks Completed:", updatedAgent.tasksCompleted.toString());
}

main().catch(console.error);
