import { ethers } from "hardhat";
import { deployManager } from "../deploy.manager";
import { CCIP_ROUTER } from "../../config/ccip";

import { updateConfig } from "../utils/writeConfig";

export const setTest = async () => {
  const friend_f = await ethers.getContractFactory("FriendtechSharesV1");
  const friend = await friend_f.deploy().then((tx) => tx.waitForDeployment());
};
