async function main() {
    const Staking = await ethers.getContractFactory("StakingRewards");
  
    // Start deployment, returning a promise that resolves to a contract object
    const StakingContract = await Staking.deploy("0xCf603aB9471cda375eBB2B04F3c05F537F1a4EeA", "0xCf603aB9471cda375eBB2B04F3c05F537F1a4EeA", "0x9d890A1BDf3B5bce83E6a98d6b012f16BE0E57d6", "0x683f7b4015812E71fA140231c8ec9828aD5046b0");
    console.log("Contract deployed to address:", StakingContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });