const hre = require("hardhat");

async function main() {
  const ARP_ADDRESS = "0x4b60039392A45F7bC948c61405a700134D7F980A";
  console.log("🚀 Deploying ARP EigenCloud Extension V2 (Fixed)\n");
  console.log("ARP Contract:", ARP_ADDRESS);

  const ARPEigenCloudV2 = await hre.ethers.getContractFactory("ARPEigenCloudExtensionV2");
  const eigenCloudV2 = await ARPEigenCloudV2.deploy(ARP_ADDRESS);
  await eigenCloudV2.deployed();

  console.log("✅ Deployed V2 to:", eigenCloudV2.address);
  console.log("\nNew Features:");
  console.log("- storeEigenAIProof() - Stores proof without calling ARP");
  console.log("- storeFullProof() - Stores TEE+AI proof");
  console.log("- hasProof() - Check if task has proof");
  console.log("- getProof() - Get proof details");
  console.log("- getAgentStats() - Get verified task count");
}

main().catch(console.error);
