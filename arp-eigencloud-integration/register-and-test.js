const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN = "0xe7fBb54ff84134C999d6B04AC71a16C3E73Bb57f";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("🧪 Full ARP + EigenCloud Test\n");
  console.log("Wallet:", deployer.address);
  
  const arp = await hre.ethers.getContractAt("AgentReputationProtocol", ARP);
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtension", EIGEN);
  
  // STEP 1: Register Agent
  console.log("\n📋 STEP 1: Register Agent on ARP");
  let agent = await arp.getAgent(deployer.address);
  if (!agent.isRegistered) {
    const fee = await arp.registrationFee();
    console.log("Registration fee:", hre.ethers.utils.formatEther(fee), "ETH");
    
    const tx = await arp.registerAgent("TestAgent", "Testing EigenCloud integration", ["AI", "Testing"], { value: fee });
    await tx.wait();
    console.log("✅ Agent registered!");
  } else {
    console.log("✅ Agent already registered");
  }
  
  agent = await arp.getAgent(deployer.address);
  console.log("Name:", agent.name);
  console.log("Reputation:", agent.reputationScore.toString());
  console.log("Tasks:", agent.tasksCompleted.toString());
  
  // STEP 2: Create a task
  console.log("\n📋 STEP 2: Create Task");
  const taskId = 0; // First task
  let task = await arp.getTask(taskId);
  if (task.reward == 0) {
    console.log("Creating task...");
    const tx = await arp.createTask("Analyze smart contract for reentrancy", { value: hre.ethers.utils.parseEther("0.001") });
    await tx.wait();
    console.log("✅ Task created!");
    task = await arp.getTask(taskId);
  } else {
    console.log("✅ Task already exists");
  }
  console.log("Description:", task.description);
  console.log("Reward:", hre.ethers.utils.formatEther(task.reward), "ETH");
  
  // STEP 3: Complete task with EigenCloud proof
  console.log("\n📋 STEP 3: Complete Task with EigenCloud Proof");
  
  if (task.isCompleted) {
    console.log("✅ Task already completed");
  } else {
    const crypto = require('crypto');
    const solution = "Smart contract analyzed. No reentrancy vulnerabilities found. All external calls follow checks-effects-interactions pattern.";
    const proofData = JSON.stringify({ solution, timestamp: Date.now(), model: 'eigenai' });
    const proofHash = "0x" + crypto.createHash('sha256').update(proofData).digest('hex');
    const timestamp = Math.floor(Date.now() / 1000);
    
    console.log("Solution:", solution.substring(0, 50) + "...");
    console.log("Proof Hash:", proofHash);
    
    const tx = await eigen.completeTaskEigenAI(taskId, solution, proofHash, timestamp);
    await tx.wait();
    console.log("✅ Task completed with EigenCloud proof!");
  }
  
  // STEP 4: Verify results
  console.log("\n📋 STEP 4: Verify Results");
  const updatedAgent = await arp.getAgent(deployer.address);
  console.log("New Reputation:", updatedAgent.reputationScore.toString());
  console.log("Tasks Completed:", updatedAgent.tasksCompleted.toString());
  
  const storedProof = await eigen.taskProofs(taskId);
  console.log("Proof Stored:", storedProof.verified);
  console.log("Proof Type:", storedProof.vType.toString(), "(1 = EIGENAI)");
  
  console.log("\n✅ FULL TEST COMPLETE!");
  console.log("\nDeployed Contracts:");
  console.log("- ARP Sepolia:", ARP);
  console.log("- EigenCloud Extension:", EIGEN);
}

main().catch(console.error);
