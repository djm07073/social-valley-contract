import { ethers, network } from "hardhat";
import {
  AVAX_SocialChainLeader__factory,
  Arbitrum_SocialChainLeader__factory,
  BNB_SocialChainLeader__factory,
  Base_SocialChainLeader__factory,
} from "../typechain-types";
import { updateConfig } from "./utils/writeConfig";
import "../config/optimism_goerli.json";
import { SOCIAL } from "../config/social";

export const deployChainLeader = async () => {
  if (network.name === "base") {
    const chainLeader_f: Base_SocialChainLeader__factory =
      await ethers.getContractFactory("Base_SocialChainLeader");
    const chainLeader = await chainLeader_f
      .deploy(SOCIAL[8453].socialFi)
      .then((tx) => tx.waitForDeployment());
    updateConfig(
      "./config/base.json",
      "chainLeader",
      await chainLeader.getAddress(),
      true
    );
    return await chainLeader.getAddress();
  } else if (network.name === "bnb") {
    const chainLeader_f: BNB_SocialChainLeader__factory =
      await ethers.getContractFactory("BNB_SocialChainLeader");
    const chainLeader = await chainLeader_f
      .deploy(SOCIAL[56].socialFi)
      .then((tx) => tx.waitForDeployment());
    updateConfig(
      "./config/bnb.json",
      "chainLeader",
      await chainLeader.getAddress(),
      true
    );
    return await chainLeader.getAddress();
  } else if (network.name === "arbitrum") {
    const chainLeader_f: Arbitrum_SocialChainLeader__factory =
      await ethers.getContractFactory("Base_SocialChainLeader");
    const chainLeader = await chainLeader_f
      .deploy(SOCIAL[42161].socialFi)
      .then((tx) => tx.waitForDeployment());
    updateConfig(
      "./config/arbitrum.json",
      "chainLeader",
      await chainLeader.getAddress(),
      true
    );
    return await chainLeader.getAddress();
  } else if (network.name == "avalanche") {
    const chainLeader_f: AVAX_SocialChainLeader__factory =
      await ethers.getContractFactory("AVAX_SocialChainLeader");
    const chainLeader = await chainLeader_f
      .deploy(SOCIAL[43114].socialFi)
      .then((tx) => tx.waitForDeployment());
    updateConfig(
      "./config/arbitrum.json",
      "chainLeader",
      await chainLeader.getAddress(),
      true
    );
    return await chainLeader.getAddress();
  } else {
    updateConfig("./config/hardhat.json", "chainLeader", "hardhat", true);
    return "hardhat";
  }
};
