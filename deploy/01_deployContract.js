const { network } = require("hardhat");
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  let productValidation = await deploy("ProductValidation", {
    from: deployer,
    log: true,
    args: ["0xb9884b3aB614E60ED29f6d803b85255c8D46b91d", 0, 0],
  });
};
module.exports.tags = ["Product"];