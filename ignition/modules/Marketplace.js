const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MarketplaceModule", (m) => {
  const marketplace = m.contract("Marketplace");

  return { marketplace };
});

// npx hardhat ignition deploy ./ignition/modules/Marketplace.js --network sepolia --verify
