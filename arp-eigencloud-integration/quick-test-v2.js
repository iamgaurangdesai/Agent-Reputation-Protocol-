const hre = require("hardhat");

const ARP = "0x4b60039392A45F7bC948c61405a700134D7F980A";
const EIGEN_V2 = "0x6c85e66dfEEd28A66c930C8B3636a40fFC969177";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Quick V2 Test\n");
  
  const eigen = await hre.ethers.getContractAt("ARPEigenCloudExtensionV2", EIGEN_V2);
  
  // Test connection
  const arpAddr = await eigen.arp();
  console.log("ARP Linked:", arpAddr);
  console.log("Expected:", ARP);
  console.log("Match:", arpAddr === ARP);
  
  // Test storing proof
  console.log("\nStoring proof for task 5...");
  const crypto = require('crypto');
  const proofHash = "0x" + crypto.createHash('sha256').update("test").digest('hex');
  
  try {
    const tx = await eigen.storeEigenAIProof(5, proofHash, Math.floor(Date.now()/1000));
    await tx.wait();
    console.log("✅ Proof stored!");
    
    const hasProof = await eigen.hasProof(5);
    console.log("Has Proof:", hasProof);
  } catch (e) {
    console.log("Error:", e.reason || e.message);
  }
}

main().catch(console.error);
