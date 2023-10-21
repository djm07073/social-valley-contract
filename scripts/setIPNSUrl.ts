import { ethers, network } from "hardhat";

export const setBaseUrl = async (url: string) => {
  try {
    const config = require(`../config/${network.name}.json`);
    const chainleader_address = config.chainLeader;

    const chainleader = await ethers.getContractAt(
      "SocialChainLeader",
      chainleader_address
    );
    await chainleader.setBaseUrl(url).then((tx) => tx.wait());
  } catch (error) {
    console.error("Error reading the config file:", error);
  }
};
export const setIPNSUrl = async (url: string) => {
  try {
    const config = require(`../config/${network.name}.json`);
    const chainleader_address = config.chainLeader;

    const chainleader = await ethers.getContractAt(
      "SocialChainLeader",
      chainleader_address
    );
    await chainleader.acc(url).then((tx) => tx.wait());
  } catch (error) {
    console.error("Error reading the config file:", error);
  }
};
