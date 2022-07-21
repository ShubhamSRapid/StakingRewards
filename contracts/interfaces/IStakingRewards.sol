// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IStakingRewards {
    // Views
    function lastTimeRewardApplicable() external view returns (uint256);
    function rewardPerToken() external view returns (uint256);
    function earned(address _token, address account) external view returns (uint256);
    function getRewardForDuration() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _token, address account) external view returns (uint256);

    // Mutative
    function stake(address _tokenAddress, uint256 amount) external;
    function withdraw(address _tokenAddress, uint256 amount) external;
    function getReward(address _tokenAddress) external;
    function exit(address _token) external;
}