const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("EtherStakingSmartContract", (m) => {

  const bankSimulation = m.contract("EtherStaking");

  return { bankSimulation };
});
