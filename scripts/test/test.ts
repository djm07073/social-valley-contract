import { ethers, network } from "hardhat";

import { updateConfig } from "../utils/writeConfig";

export const setFriendTech = async () => {
  const friend_f = await ethers.getContractFactory("FriendtechSharesV1");
  const friend = await friend_f.deploy().then((tx) => tx.waitForDeployment());
  updateConfig(
    `./config/${network.name}.json`,
    "friend",
    await friend.getAddress(),
    true
  );
};
export const buyShares = async () => {
  const friend = await ethers.getContractAt(
    "FriendtechSharesV1",
    "0x9Da9b07981d2db157F512F2dFD9A348CF763ED27"
  );
  const buyPrice = await friend.getBuyPrice(
    "0xf768a8FD04c16193aCd2F613b8374C1D7e521509",
    1
  );
  const [signer, addr1] = await ethers.getSigners();
  await friend
    .connect(addr1)
    .buyShares("0x31D613CBa3d5200b1C82C13e0ff09661A59c08B8", 1, {
      value: buyPrice,
    })
    .then((tx) => tx.wait());
};
export const buySharesby2 = async () => {
  const friend = await ethers.getContractAt(
    "FriendtechSharesV1",
    "0x9Da9b07981d2db157F512F2dFD9A348CF763ED27"
  );
  const buyPrice = await friend.getBuyPrice(
    "0xf768a8FD04c16193aCd2F613b8374C1D7e521509",
    1
  );
  const [signer, addr1] = await ethers.getSigners();
  await friend
    .connect(addr1)
    .buyShares("", 1, {
      value: buyPrice,
    })
    .then((tx) => tx.wait());
};
export const buyShareskey2 = async () => {
  const friend = await ethers.getContractAt(
    "FriendtechSharesV1",
    "0x9Da9b07981d2db157F512F2dFD9A348CF763ED27"
  );
  const buyPrice = await friend.getBuyPrice(
    "0xf768a8FD04c16193aCd2F613b8374C1D7e521509",
    1
  );
  const [signer, addr1] = await ethers.getSigners();
  await friend
    .buyShares("0x31D613CBa3d5200b1C82C13e0ff09661A59c08B8", 1, {
      value: buyPrice,
    })
    .then((tx) => tx.wait());
};
export const sellShares = async () => {
  const friend = await ethers.getContractAt(
    "FriendtechSharesV1",
    "0x9Da9b07981d2db157F512F2dFD9A348CF763ED27"
  );
  await friend
    .sellShares("0xf768a8FD04c16193aCd2F613b8374C1D7e521509", 1)
    .then((tx) => tx.wait());
};

export const setAccount = async (account: string) => {
  const leader = await ethers.getContractAt(
    "Arbitrum_Goerli_SocialChainLeader",
    "0xEaC24893CAD32ad3a9771Ab35772D6A3383FD127"
  );
  await leader.addAccount(account).then((tx) => tx.wait());
};
const main = async () => {
  // await setAccount("0x31D613CBa3d5200b1C82C13e0ff09661A59c08B8");
  // await buyShares();
  // sellShares();
  // await buySharesby2();
  await buyShareskey2();
  // setFriendTech();
};
main();
