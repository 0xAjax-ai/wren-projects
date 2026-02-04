// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SimpleUSDCVault
 * @notice A minimal ERC-4626 vault for USDC on Base Sepolia
 * @dev Designed for the USDC Hackathon - agent-managed vault
 * 
 * How it works:
 * 1. Users deposit USDC and receive vUSDC shares
 * 2. USDC is held in the vault
 * 3. Users redeem vUSDC shares to withdraw USDC
 *
 * Agent integration:
 * - Agents monitor wallet balances and auto-deposit idle USDC
 * - Agents can trigger withdrawals based on conditions
 * - No human intervention needed after initial setup
 *
 * Note: This is a simple holding vault. For yield, integrate with
 * Aave/Compound on mainnet where proper test tokens exist.
 */
contract SimpleUSDCVault is ERC4626 {
    // Circle's official USDC on Base Sepolia
    IERC20 public constant USDC = IERC20(0x036CbD53842c5426634e7929541eC2318f3dCF7e);

    constructor() ERC4626(USDC) ERC20("Simple Vault USDC", "svUSDC") {}

    /**
     * @notice Total assets managed by the vault (USDC balance)
     * @return Total USDC held in the vault
     */
    function totalAssets() public view override returns (uint256) {
        return USDC.balanceOf(address(this));
    }
}
