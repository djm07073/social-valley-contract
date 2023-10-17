import { ethers, network } from "hardhat";

import { SocialGeneralManager__factory } from "../typechain-types";
import { updateConfig } from "./utils/writeConfig";
import { CCIP_ROUTER } from "../config/ccip";
export const deployManager = async (
  basicUri: string,
  router: `0x${string}`
) => {
  const manager_f: SocialGeneralManager__factory =
    await ethers.getContractFactory("SocialGeneralManager");
  const manager = await manager_f
    .deploy(basicUri, router)
    .then((tx) => tx.waitForDeployment());

  updateConfig(
    `./config/${network.name}.json`,
    "generalManager",
    await manager.getAddress(),
    true
  );
  return await manager.getAddress();
};

deployManager("", CCIP_ROUTER[420].router);
