const hre = require("hardhat");

async function main() {
  const ARP_ADDRESS = "0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd";
  console.log("Deploying ARP EigenCloud Extension...");
  console.log("ARP Contract:", ARP_ADDRESS);

  const ARPEigenCloud = await hre.ethers.getContractFactory("ARPEigenCloudExtension");
  const eigenCloudExt = await ARPEigenCloud.deploy(ARP_ADDRESS);
  await eigenCloudExt.deployed();

  console.log("✅ Deployed to:", eigenCloudExt.address);
  console.log(`Verify: npx hardhat verify --network base ${eigenCloudExt.address} ${ARP_ADDRESS}`);
}

main().catch(console.error);
