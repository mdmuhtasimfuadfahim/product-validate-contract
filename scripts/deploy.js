async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const productValidation = await hre.ethers.getContractFactory("productValidation");
  const deployProductValidation = await productValidation.deploy();

  await deployProductValidation.deployed();

  //verify: npx hardhat verify --bsctestnet rinkeby DEPLOYED_CONTRACT_ADDRESS
  console.log("Product validation contract deployed address: ", deployProductValidation.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

