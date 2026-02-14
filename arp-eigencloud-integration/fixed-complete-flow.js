const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN = "0xe7fBb54ff84134C999d6B04AC71a16C3E73Bb57f";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🧪 Fixed EigenCloud Flow (Store Proof + Complete Task)\n");
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtension", EIGEN);
  
  // Create task
  console.log("📋 Creating Task #2...");
  const tx1 = await arp.createTask("Audit NFT smart contract", { value: hre.ethers.utils.parseEther("0.001") });
  await tx1.wait();
  const taskId = 2;
  console.log("✅ Task created! ID:", taskId);
  
  // Generate proof
  const crypto = require('crypto');
  const solution = "NFT contract audited. ERC-721 compliance verified. No critical issues.";
  const proofData = JSON.stringify({ solution, timestamp: Date.now(), model: 'eigenai' });
  const proofHash = "0x" + crypto.createHash('sha256').update(proofData).digest('hex');
  const timestamp = Math.floor(Date.now() / 1000);
  
  console.log("\n🔐 Generated EigenAI Proof:");
  console.log("Hash:", proofHash);
  
  // CURRENT LIMITATION: Can't call completeTask through EigenCloud
  // because msg.sender changes. Instead:
  // 1. Store proof in EigenCloud (needs new function)
  // 2. Complete task directly on ARP
  // 3. Link proof to task (off-chain or with new function)
  
  console.log("\n⚠️  LIMITATION: EigenCloud can't call arp.completeTask directly");
  console.log("   (msg.sender becomes EigenCloud contract, not user)");
  
  // For now, complete task directly
  console.log("\n📋 Completing task via ARP directly...");
  const tx2 = await arp.completeTask(taskId, solution);
  await tx2.wait();
  console.log("✅ Task completed! TX:", tx2.hash);
  
  // Show final status
  const agent = await arp.getAgent(deployer.address);
  console.log("\n📊 Final Status:");
  console.log("Reputation:", agent.reputationScore.toString());
  console.log("Tasks Completed:", agent.tasksCompleted.toString());
  
  console.log("\n💡 TO FIX: Add storeProof() function to EigenCloud");
  console.log("   that doesn't call arp.completeTask");
}

main().catch(console.error);
