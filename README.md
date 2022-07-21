StakingRewards.sol => 0x2760274e457c1D2805412bB4ef2fBFe67F05dC88;
StakingToken.sol => 0x683f7b4015812E71fA140231c8ec9828aD5046b0;
RewardToken.sol => 0x9d890A1BDf3B5bce83E6a98d6b012f16BE0E57d6;




Hey guys, so i think we can make some progress on the staking contracts for stables in our bridge. Our 'bridge' is actually a wallet that is controlled by a relayer, so from a high level, the staking contract needs to:

1. Admin / Owner functions
- function to set accepted erc20 tokens, ie: we will need to 'whitelist' which tokens it accepts
- function to change the bridge wallet address -->

2. DepositFunction
- accept an erc20 token
- the token amount
- transfer that token to the bridge
- record the user's deposit balance in a map which has token, and amount
- emit an event

3. Withdraw function
- emit an event that has token, amount, chain id for withdraw
- reduce the user's deposit balance by that amount

4. GET functions for getting the user's balance

let's start there