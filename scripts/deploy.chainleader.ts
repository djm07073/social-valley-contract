import { ethers, network } from "hardhat";
import {
  Arbitrum_Goerli_SocialChainLeader__factory,
  Arbitrum_SocialChainLeader__factory,
  BNB_SocialChainLeader__factory,
  Base_SocialChainLeader__factory,
} from "../typechain-types";
import { updateConfig } from "./utils/writeConfig";
import { CCIP_ROUTER } from "../config/ccip";
import "../config/optimism_goerli.json";
export const deployChainLeader_test = async (
  router: `0x${string}`,
  link: `0x${string}`,
  general_manager: `0x${string}`
) => {
  const chainLeader_f: Arbitrum_Goerli_SocialChainLeader__factory =
    await ethers.getContractFactory("Arbitrum_Goerli_SocialChainLeader");
  console.log("1");
  const chainLeader = await chainLeader_f.deploy(
    router,
    link,
    "0x9Da9b07981d2db157F512F2dFD9A348CF763ED27",
    general_manager
  );
  console.log("2");
  updateConfig(
    "./config/arbitrum_goerli.json",
    "chainLeader",
    await chainLeader.getAddress(),
    true
  );
  return await chainLeader.getAddress();
};

export const deployChainLeader = async (
  router: `0x${string}`,
  link: `0x${string}`,
  general_manager: `0x${string}`
) => {
  if (network.name === "base") {
    const chainLeader_f: Base_SocialChainLeader__factory =
      await ethers.getContractFactory("Base_SocialChainLeader");
    const chainLeader = await chainLeader_f
      .deploy(router, link, CCIP_ROUTER[8453].socialFi, general_manager)
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
      .deploy(router, link, CCIP_ROUTER[56].socialFi, general_manager)
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
      .deploy(router, link, CCIP_ROUTER[42161].socialFi, general_manager)
      .then((tx) => tx.waitForDeployment());
    updateConfig(
      "./config/arbitrum.json",
      "chainLeader",
      await chainLeader.getAddress(),
      true
    );
    return await chainLeader.getAddress();
  } else if (network.name === "arbitrum_goerli") {
    const chainLeader_f: Arbitrum_Goerli_SocialChainLeader__factory =
      await ethers.getContractFactory("Arbitrum_Goerli_SocialChainLeader");
    const chainLeader = await chainLeader_f
      .deploy(router, link, CCIP_ROUTER[421613].socialFi, general_manager)
      .then((tx) => tx.waitForDeployment());
    updateConfig(
      "./config/arbitrum_goerli.json",
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
deployChainLeader_test(
  CCIP_ROUTER[421613].router,
  CCIP_ROUTER[421613].link,
  "0x80B5c20fD7e334AA2342Aa8177163cb0e7F30333"
);
