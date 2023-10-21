import { ethers, network } from "hardhat";
import { updateConfig } from "./utils/updateConfig";

const deployProfile = async () => {
  const profile_f = await ethers.getContractFactory("ValleyProfile");
  const profile = await profile_f.deploy().then((tx) => tx.waitForDeployment());
  updateConfig(
    `./config/${network.name}.json`,
    "profile",
    await profile.getAddress(),
    false
  );
};

const main = async () => {
  await deployProfile();
};

main();
