const hre = require("hardhat");

async function main() {
  const ARP_ADDRESS = "0x4b60039392A45F7bC948c61405a700134D7F980A";
  console.log("Deploying ARP EigenCloud Extension...");
  console.log("ARP Contract:", ARP_ADDRESS);

  const ARPEigenCloud = await hre.ethers.getContractFactory("ARPEigenCloudExtension");
  const eigenCloudExt = await ARPEigenCloud.deploy(ARP_ADDRESS);
  await eigenCloudExt.deployed();

  console.log("✅ Deployed to:", eigenCloudExt.address);
}

main().catch(console.error);
