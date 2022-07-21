// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./interfaces/IStakingRewards2.sol";

abstract contract RewardsDistributionRecipient is Ownable {
    address public rewardsDistribution;

    function notifyRewardAmount(uint256 reward) external virtual;

    modifier onlyRewardsDistribution() {
        require(
            msg.sender == rewardsDistribution,
            "Caller is not RewardsDistribution contract"
        );
        _;
    }

    function setRewardsDistribution(address _rewardsDistribution)
        external
        onlyOwner
    {
        rewardsDistribution = _rewardsDistribution;
    }
}

contract StakingRewards is
    IStakingRewards,
    Ownable,
    RewardsDistributionRecipient,
    ReentrancyGuard,
    Pausable
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(uint256 amount);

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 30 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    address public walletAddress;
    address[] public whitelistedTokens;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== MODIFIERS ========== */

    /**
     * @dev Updates reward for the given address
     * @param account address of the user
     */
    function updateReward(address account) public {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rewardsDistribution, address _rewardsToken) {
        rewardsToken = IERC20(_rewardsToken);
        rewardsDistribution = _rewardsDistribution;
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @dev User can call this function to stake tokens
     * @param amount Amount of tokens to be staked
     */
    function stake(uint256 amount)
        external
        override
        nonReentrant
        whenNotPaused
    {
        require(amount > 0, "Cannot stake 0");
        updateReward(msg.sender);
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] += amount;
        rewardsToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    /**
     * @dev
     * @param reward
     */
    function notifyRewardAmount(uint256 reward)
        external
        override
        onlyRewardsDistribution
    {
        updateReward(address(0));
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        require(
            rewardRate <= balance.div(rewardsDuration),
            "Provided reward too high"
        );

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    /**
     * @dev Added to support recovering LP Rewards from other systems to be distributed to holders
     * @param tokenAddress address of the tokens to be recovered
     * @param tokenAmount Amount of tokens to be recoverd
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        onlyOwner
    {
        // Cannot recover the staking token or the rewards token
        require(
            tokenAddress != address(rewardsToken),
            "Cannot withdraw the staking or rewards tokens"
        );
        for (uint256 i = 0; i < whitelistedTokens.length; i++) {
            if (whitelistedTokens[i] == tokenAddress) {
                return;
            }
        }
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAmount);
    }

    /**
     * @dev Sets new rewards duration
     * @param _rewardsDuration duration of rewards to be set
     */
    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(
            periodFinish == 0 || block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @dev whitelists the tokens which can be staked
     * @param _tokens array of addresses of tokens which can be staked
     */
    function whitelistTokens(address[] calldata _tokens) public onlyOwner {
        delete whitelistedTokens;
        whitelistedTokens = _tokens;
    }

    /**
     * @dev Withdrawal of staked tokens
     * @param amount amount of tokens to be withdrawn
     */
    function withdraw(uint256 amount) public override nonReentrant {
        require(amount > 0, "Cannot withdraw 0");
        updateReward(msg.sender);
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] -= amount;
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev User can call this function to receive earned rewards
     */
    function getReward() public override nonReentrant {
        updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    /**
     * @dev Unstakes and receive the staked tokens as well as reward tokens
     */
    function exit() public override {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @dev Gets the total supply of tokens to the contract
     * @return _totalSupply Total amount of tokens staked in this contract
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the user balance of tokens
     * @param account address of user
     * @return _balances Total amount of tokens staked by the user
     */
    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view override returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    /**
     * @dev Gets the rewards per token
     * @return rewardPerTokenStored rewards per token to be received
     */
    function rewardPerToken() public view override returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_totalSupply)
            );
    }

    /**
     * @dev Gets the rewards earned by the user
     * @param account address of the user
     * @return rewardPerTokenStored rewards per token to be received
     */
    function earned(address account) public view override returns (uint256) {
        return
            _balances[account]
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    /**
     * @dev Gets the rewards for a particular duration
     * @return rewards to be earned for the duration
     */
    function getRewardForDuration() external view override returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }
}
