const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("BaseNftModule", (m) => {
  const baseNft = m.contract("BasicNft");

  return { baseNft };
});
