import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "hardhat-gas-reporter"

import dotenv from "dotenv"
dotenv.config()

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.26",
      },
      {
        version: "0.8.0",
      },
    ],
  },
  defaultNetwork: "hardhat",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545/",
      chainId: 31337,
    },
    sepolia: {
      url: process.env.INFURA_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
      gas: 5000000,
      gasPrice: 10000000000,
      timeout: 300000,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: true,
    currency: "ETH",
    gasPrice: 21,
    outputFile: "gasReport.txt",
  },
}

export default config
