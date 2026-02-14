const hre = require("hardhat");

async function main() {
  // Your mainnet ARP contract
  const ARP_MAINNET = "0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd";
  
  console.log("🚀 Deploying EigenCloud V2 to Base Mainnet\n");
  console.log("ARP Mainnet:", ARP_MAINNET);
  
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deployer:", deployer.address);
  
  // Check balance
  const balance = await deployer.getBalance();
  console.log("Balance:", hre.ethers.utils.formatEther(balance), "ETH");
  
  if (balance.lt(hre.ethers.utils.parseEther("0.001"))) {
    console.log("\n⚠️  LOW BALANCE - Need ETH for gas");
    console.log("Wallet:", deployer.address);
    return;
  }
  
  // Deploy EigenCloud V2
  const ARPEigenCloudV2 = await hre.ethers.getContractFactory("ARPEigenCloudExtensionV2");
  const eigenCloudV2 = await ARPEigenCloudV2.deploy(ARP_MAINNET);
  await eigenCloudV2.deployed();
  
  console.log("\n✅ EigenCloud V2 deployed to Mainnet!");
  console.log("Address:", eigenCloudV2.address);
  console.log("Transaction:", eigenCloudV2.deployTransaction.hash);
  console.log("\nUpdate these files with the new address:");
  console.log("- dashboard.html");
  console.log("- README.md");
  console.log("\nVerify on Basescan:");
  console.log(`npx hardhat verify --network base ${eigenCloudV2.address} ${ARP_MAINNET}`);
}

main().catch(console.error);
