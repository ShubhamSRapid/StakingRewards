const { expect } = require("chai");
const { ethers } = require("hardhat");
// const { BigNumber } = require("ethers");

async function toWei(n) {
    await ethers.utils.parseEther(n);
}

async function toEth(n) {
    await ethers.utils.formatEther(n);
}

describe("Deployments", function() {
    let owner, user1, user2, user3, user4, wallet, wallet2;
    let staking, reward, token1, token2;

    beforeEach(async function() {
        [owner, user1, user2, user3, user4, wallet, wallet2] = await ethers.getSigners();
        const Reward = await ethers.getContractFactory("RewardsToken");
        reward = await Reward.deploy();

        const Token = await ethers.getContractFactory("StakingToken");
        token1 = await Token.deploy();

        const Staking = await ethers.getContractFactory("StakingRewards");
        staking = await Staking.deploy(owner.address, owner.address, reward.address);
        
        await token1.transfer(user1.address, 10000);
        await token1.transfer(user2.address, 10000);
        await token1.transfer(user3.address, 10000);
        await token1.transfer(user4.address, 10000);
    });

    describe("Check Deployments", function() {
        it("Should be deployed", async function() {
            await reward.deployed();
            await token1.deployed();
            await staking.deployed();
        });
        it("Should assign the totalSupply to the owner", async function() {
            const balance = await token1.totalSupply();
            expect(await token1.balanceOf(owner.address)).to.equal(balance);
        });
    });

    describe("Function whitelistTokens", function() {
        // it("Should fail if non owner tries to set the whitelist tokens", async function() {
        //     expect(await staking.connect(user1).whitelistTokens([token1.address])).to.be.revertedWith("Only the contract owner may perform this action");
        // });
        it("Should be able to set whitelisted tokens by the owner", async function() {
            await staking.whitelistTokens([token1.address]);
            expect(await staking.isWhitelisted(token1.address)).to.be.true;
        });
    });

    describe("function setWalletAddress", function() {
        // it("Should fail if non-owner tries to change bridge wallet address", async function() {
        //     expect(await staking.connect(user1).setWalletAddress(wallet.address)).to.be.revertedWith('Only the contract owner may perform this action');
        // });
        it("Should be able to set walletAddress by the owner", async function() {
            await staking.setWalletAddress(wallet.address);
            expect (await staking.walletAddress()).to.equal(wallet.address);
        });
        it("Should be able to change walletAddress by the owner", async function() {
            await staking.setWalletAddress(wallet.address);
            expect (await staking.walletAddress()).to.equal(wallet.address);
            await staking.setWalletAddress(wallet2.address);
            expect (await staking.walletAddress()).to.equal(wallet2.address);
        });
    });

    describe("Function Stake", function() {
        it("Should fail if deposit amount is equal to zero", async function() {

        });
        it("Should fail if the token is not whitelisted", async function() {

        });
        it("Should update the totalSupply and balances of user on deposit", async function() {

        });
        it("Should transfer tokens to correct wallet address on deposit", async function() {

        });
        //get function to check user balance
    });

    describe("Function Withdraw", function() {
        it("Should fail if withdraw amount is equal to zero", async function() {

        });
        it("Should update the totalSupply and balances of user on withdraw", async function() {

        });
        //get function to check user balance
    });
});

