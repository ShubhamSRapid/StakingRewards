// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardsToken is ERC20, Ownable {
    constructor() ERC20("Rewards Tokens", "RTN") {
        _mint(msg.sender, 1000*10**18);
    }
    function transferTokens(address _account) public onlyOwner {
        uint TotalSupply = totalSupply();
        transfer(_account, TotalSupply);
    }
}