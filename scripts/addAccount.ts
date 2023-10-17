import { ethers, network } from "hardhat";

export const addAccountByOwner = async (account: string) => {
  try {
    const config = require(`../config/${network.name}.json`);
    const chainleader_address = config.chainLeader;

    const chainleader = await ethers.getContractAt(
      "SocialChainLeader",
      chainleader_address
    );
    await chainleader.addAccountByOwner(account).then((tx) => tx.wait());
  } catch (error) {
    console.error("Error reading the config file:", error);
  }
};

export const addAccountBySelf = async () => {
  try {
    const config = require(`../config/${network.name}.json`);
    const chainleader_address = config.chainLeader;

    const chainleader = await ethers.getContractAt(
      "SocialChainLeader",
      chainleader_address
    );
    await chainleader.addAccount().then((tx) => tx.wait());
  } catch (error) {
    console.error("Error reading the config file:", error);
  }
};
const main = async () => {
  await addAccountBySelf(); // it's me
  await addAccountByOwner("0xe4f1c86df8a2f355bf3573ddc25fc757ad191416"); // Beaker
  await addAccountByOwner("0x12709a007d3bc885693668c5e615fd3798ceb359"); // Jaynti Kanani (JD)
  await addAccountByOwner("0xf9b7cf4be6f4cde37dd1a5b75187d431d94a4fcc"); // Levi
};
main();
