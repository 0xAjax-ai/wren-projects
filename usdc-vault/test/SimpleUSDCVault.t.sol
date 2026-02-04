// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {SimpleUSDCVault} from "../src/SimpleUSDCVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleUSDCVaultTest is Test {
    SimpleUSDCVault public vault;
    IERC20 public usdc;
    
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    
    // Fork Base Sepolia for realistic testing
    uint256 public baseSepolia;
    
    function setUp() public {
        // Fork Base Sepolia
        baseSepolia = vm.createFork("https://sepolia.base.org");
        vm.selectFork(baseSepolia);
        
        // Deploy vault
        vault = new SimpleUSDCVault();
        usdc = IERC20(0x036CbD53842c5426634e7929541eC2318f3dCF7e);
        
        // Deal USDC to test users (using deal cheatcode)
        deal(address(usdc), alice, 1000e6); // 1000 USDC
        deal(address(usdc), bob, 500e6);    // 500 USDC
    }
    
    function test_Deposit() public {
        uint256 depositAmount = 100e6; // 100 USDC
        
        vm.startPrank(alice);
        usdc.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount, alice);
        vm.stopPrank();
        
        // First deposit: shares == assets (1:1)
        assertEq(shares, depositAmount, "Shares should equal deposit amount");
        assertEq(vault.balanceOf(alice), depositAmount, "Alice should have shares");
        assertEq(vault.totalAssets(), depositAmount, "Vault should have assets");
    }
    
    function test_Withdraw() public {
        uint256 depositAmount = 100e6;
        
        // Deposit first
        vm.startPrank(alice);
        usdc.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);
        
        // Withdraw half
        uint256 withdrawAmount = 50e6;
        uint256 sharesBurned = vault.withdraw(withdrawAmount, alice, alice);
        vm.stopPrank();
        
        assertEq(sharesBurned, withdrawAmount, "Should burn equal shares");
        assertEq(usdc.balanceOf(alice), 950e6, "Alice should have 950 USDC");
        assertEq(vault.totalAssets(), 50e6, "Vault should have 50 USDC left");
    }
    
    function test_Redeem() public {
        uint256 depositAmount = 100e6;
        
        vm.startPrank(alice);
        usdc.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount, alice);
        
        // Redeem all shares
        uint256 assets = vault.redeem(shares, alice, alice);
        vm.stopPrank();
        
        assertEq(assets, depositAmount, "Should receive all assets back");
        assertEq(vault.balanceOf(alice), 0, "Alice should have no shares");
        assertEq(vault.totalAssets(), 0, "Vault should be empty");
    }
    
    function test_MultipleDepositors() public {
        // Alice deposits 100 USDC
        vm.startPrank(alice);
        usdc.approve(address(vault), 100e6);
        vault.deposit(100e6, alice);
        vm.stopPrank();
        
        // Bob deposits 50 USDC
        vm.startPrank(bob);
        usdc.approve(address(vault), 50e6);
        vault.deposit(50e6, bob);
        vm.stopPrank();
        
        assertEq(vault.totalAssets(), 150e6, "Total assets should be 150 USDC");
        assertEq(vault.balanceOf(alice), 100e6, "Alice has 100 shares");
        assertEq(vault.balanceOf(bob), 50e6, "Bob has 50 shares");
    }
    
    function test_SharePriceRemains1to1() public {
        // In a simple vault without yield, share price is always 1:1
        vm.startPrank(alice);
        usdc.approve(address(vault), 100e6);
        vault.deposit(100e6, alice);
        vm.stopPrank();
        
        uint256 previewDeposit = vault.previewDeposit(100e6);
        uint256 previewRedeem = vault.previewRedeem(100e6);
        
        assertEq(previewDeposit, 100e6, "1 USDC = 1 share");
        assertEq(previewRedeem, 100e6, "1 share = 1 USDC");
    }
    
    function testFuzz_DepositWithdraw(uint256 amount) public {
        // Bound amount to reasonable values (1 USDC to 1M USDC)
        amount = bound(amount, 1e6, 1000000e6);
        
        // Give alice enough USDC
        deal(address(usdc), alice, amount);
        
        vm.startPrank(alice);
        usdc.approve(address(vault), amount);
        uint256 shares = vault.deposit(amount, alice);
        
        // Withdraw everything
        uint256 assets = vault.redeem(shares, alice, alice);
        vm.stopPrank();
        
        // Should get back exactly what was deposited
        assertEq(assets, amount, "Should get back exact amount");
    }
}
