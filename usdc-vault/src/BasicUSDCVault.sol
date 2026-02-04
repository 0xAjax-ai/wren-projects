// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IPool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

/**
 * @title BasicUSDCVault
 * @notice A minimal ERC-4626 vault that deposits USDC into Aave V3 on Base Sepolia
 * @dev Designed for the USDC Hackathon - agent-managed yield vault
 * 
 * How it works:
 * 1. Users deposit USDC and receive vUSDC shares
 * 2. USDC is automatically supplied to Aave V3
 * 3. Yield accrues via aUSDC (interest-bearing token)
 * 4. Users redeem vUSDC shares to withdraw USDC + earned yield
 *
 * Agent integration:
 * - Agents monitor wallet balances and auto-deposit idle USDC
 * - Agents track APY and can trigger withdrawals if rates drop
 * - No human intervention needed after initial setup
 */
contract BasicUSDCVault is ERC4626 {
    using SafeERC20 for IERC20;

    // Base Sepolia Aave V3 addresses
    IPool public constant AAVE_POOL = IPool(0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27);
    IERC20 public constant USDC = IERC20(0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f);
    IERC20 public constant A_USDC = IERC20(0x10F1A9D11CDf50041f3f8cB7191CBE2f31750ACC);

    constructor() ERC4626(USDC) ERC20("Basic Vault USDC", "vUSDC") {}

    /**
     * @notice Total assets managed by the vault (aUSDC balance includes accrued interest)
     * @return Total USDC value held in Aave
     */
    function totalAssets() public view override returns (uint256) {
        return A_USDC.balanceOf(address(this));
    }

    /**
     * @notice Hook called after deposit - supplies USDC to Aave
     * @param assets Amount of USDC deposited
     */
    function _afterDeposit(uint256 assets, uint256 /*shares*/) internal {
        USDC.forceApprove(address(AAVE_POOL), assets);
        AAVE_POOL.supply(address(USDC), assets, address(this), 0);
    }

    /**
     * @notice Hook called before withdraw - pulls USDC from Aave
     * @param assets Amount of USDC to withdraw
     */
    function _beforeWithdraw(uint256 assets, uint256 /*shares*/) internal {
        AAVE_POOL.withdraw(address(USDC), assets, address(this));
    }

    /**
     * @notice Override deposit to call our hook
     */
    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        uint256 shares = super.deposit(assets, receiver);
        _afterDeposit(assets, shares);
        return shares;
    }

    /**
     * @notice Override mint to call our hook
     */
    function mint(uint256 shares, address receiver) public override returns (uint256) {
        uint256 assets = super.mint(shares, receiver);
        _afterDeposit(assets, shares);
        return assets;
    }

    /**
     * @notice Override withdraw to call our hook
     */
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        _beforeWithdraw(assets, 0);
        return super.withdraw(assets, receiver, owner);
    }

    /**
     * @notice Override redeem to call our hook
     */
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256) {
        uint256 assets = previewRedeem(shares);
        _beforeWithdraw(assets, shares);
        return super.redeem(shares, receiver, owner);
    }
}
