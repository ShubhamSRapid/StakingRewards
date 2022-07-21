async function main() {
    const RewardsTokenERC20 = await ethers.getContractFactory("RewardsToken");
  
    // Start deployment, returning a promise that resolves to a contract object
    const RewardsTokenContractERC20 = await RewardsTokenERC20.deploy();
    console.log("Contract deployed to address:", RewardsTokenContractERC20.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });