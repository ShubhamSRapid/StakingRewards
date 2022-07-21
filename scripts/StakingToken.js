async function main() {
    const StakingTokenERC20 = await ethers.getContractFactory("StakingToken");
  
    // Start deployment, returning a promise that resolves to a contract object
    const StakingTokenContractERC20 = await StakingTokenERC20.deploy();
    console.log("Contract deployed to address:", StakingTokenContractERC20.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });