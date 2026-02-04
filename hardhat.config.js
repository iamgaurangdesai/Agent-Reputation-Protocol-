require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config");

module.exports = {
  solidity: "0.8.19",
  networks: {
    baseSepolia: {
      url: process.env.BASE_SEPOLIA_RPC || "https://sepolia.base.org",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""]
    },
    base: {
      url: process.env.BASE_RPC || "https://base.mainnet.rpc",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""]
    }
  },
  etherscan: {
    apiKey: process.env.BASESCAN_API_KEY || ""
  }
};
