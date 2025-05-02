# 🎰 Decentralized Lottery Smart Contract

This project is a Hardhat-based Ethereum smart contract implementing a decentralized lottery system. It integrates Chainlink VRF (Verifiable Random Function) to securely select a truly random winner and Chainlink Automation (formerly Keepers) to automatically trigger winner selection at defined intervals—fully automating the lottery process.

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [Nodejs](https://nodejs.org/en/)
  - You'll know you've installed nodejs right if you can run:
    - `node --version` and get an output like: `vx.x.x`
    - It'll need to be at least `18.16.0` of node
- [Npm](https://www.npmjs.com/)
  - You'll know you've installed npm right if you can run:
    - `npm --version` and get an output like: `x.x.x`

## Quickstart

```
git clone https://github.com/ruifernandes0013/hardhat-smartcontract-lottery
cd hardhat-smartcontract-lottery
nvm use
npm i
```

# Usage

Deploy:

```
npm run deploy
```

# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `INFURA_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `INFURA_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH & LINK. You should see the ETH and LINK show up in your metamask. [You can read more on setting up your wallet with LINK.](https://docs.chain.link/docs/deploy-your-first-contract/#install-and-fund-your-metamask-wallet)

3. Setup a Chainlink VRF Subscription ID

Head over to [vrf.chain.link](https://vrf.chain.link/) and setup a new subscription, and get a subscriptionId. You can reuse an old subscription if you already have one.

[You can follow the instructions](https://docs.chain.link/docs/get-a-random-number/) if you get lost. You should leave this step with:

1. A subscription ID
2. Your subscription should be funded with LINK

3. Deploy

In your `.env` add your `SUBSCRIPTION_ID`, `KEY_HASH` and `VRF_COORDINATOR_ADDRESS`

Then run:

```
NETWORK=sepolia npm run deploy
```

And copy / remember the contract address.

4. Add your contract address as a Chainlink VRF Consumer

Go back to [vrf.chain.link](https://vrf.chain.link) and under your subscription add `Add consumer` and add your contract address. You should also fund the contract with a minimum of 1 LINK.

5. Register a Chainlink Keepers Upkeep

[You can follow the documentation if you get lost.](https://docs.chain.link/docs/chainlink-keepers/compatible-contracts/)

Go to [keepers.chain.link](https://keepers.chain.link/new) and register a new upkeep. Choose `Custom logic` as your trigger mechanism for automation. Your UI will look something like this once completed:

6. Enter your raffle!

Your contract is now setup to be a tamper proof autonomous verifiably random lottery. Enter the lottery using [Remix](https://remix.ethereum.org/) or [Etherscan](https://sepolia.etherscan.io/)

## Verify on etherscan

If you deploy to a testnet or mainnet, you can verify it if you get an [API Key](https://etherscan.io/myapikey) from Etherscan and set it as an environment variable named `ETHERSCAN_API_KEY`. You can pop it into your `.env` file as seen in the `.env.example`.

In its current state, if you have your api key set, it will auto verify sepolia contracts!

# Thank you!

[![Rui Fernandes](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](http://linkedin.com/in/rui-pedro-fernandes-a83b14232)
