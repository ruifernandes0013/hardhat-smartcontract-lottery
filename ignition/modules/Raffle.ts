import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"
import dotenv from "dotenv"
dotenv.config()

const RaffleModule = buildModule("RaffleModule", (m) => {
  const subscriptionId = process.env.SUBSCRIPTION_ID || ""
  const vrfAddress = process.env.VRF_COORDINATOR_ADDRESS || ""
  const keyHash = process.env.KEY_HASH || ""

  console.log("[vrfAddress, subscriptionId, keyHash", [
    vrfAddress,
    subscriptionId,
    keyHash,
  ])
  const raffle = m.contract("Raffle", [vrfAddress,subscriptionId, keyHash])

  return { raffle }
})

export default RaffleModule
