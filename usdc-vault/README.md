# USDC Vault - Agent-Managed Yield Optimization

An ERC-4626 compliant vault for USDC on Base, designed for autonomous agent management.

## 🎯 Overview

This project demonstrates how AI agents can autonomously manage DeFi positions:

- **Auto-deposit**: Agents monitor wallet balances and deposit idle USDC
- **Monitoring**: Real-time vault status and alerts
- **Withdrawal triggers**: Agents can withdraw based on conditions
- **No human intervention**: Set it and forget it

## 📦 Deployed Contracts (Base Sepolia)

| Contract | Address |
|----------|---------|
| SimpleUSDCVault | `0xe631fA4D466763bC8fE367ccafBaE2747505179d` |
| USDC (Circle) | `0x036CbD53842c5426634e7929541eC2318f3dCF7e` |

[View on BaseScan](https://sepolia.basescan.org/address/0xe631fA4D466763bC8fE367ccafBaE2747505179d)

## 🏗️ Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   User Wallet   │────▶│  SimpleUSDCVault│────▶│   USDC Token    │
│                 │     │    (ERC-4626)   │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       ▲
        │                       │
        ▼                       │
┌─────────────────┐            │
│   AI Agent      │────────────┘
│  (Clawdbot)     │
│                 │
│ • Monitor balance
│ • Auto-deposit  │
│ • Withdraw      │
└─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Base Sepolia ETH (for gas)
- Base Sepolia USDC

### Install Dependencies

```bash
forge install
```

### Build

```bash
forge build
```

### Test

```bash
forge test -vvv
```

### Deploy

```bash
forge script script/DeploySimpleVault.s.sol:DeploySimpleVault \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## 🤖 Agent Scripts

The `agent/` directory contains scripts for autonomous vault management:

### Monitor Status

```bash
./agent/monitor.sh
```

Shows current wallet and vault state with recommendations.

### Get JSON Status

```bash
./agent/status.sh
```

Returns machine-readable JSON for agent integration.

### Manual Deposit

```bash
PRIVATE_KEY=0x... ./agent/deposit.sh 5000000  # 5 USDC
```

### Manual Withdraw

```bash
PRIVATE_KEY=0x... ./agent/withdraw.sh 5000000  # 5 USDC
PRIVATE_KEY=0x... ./agent/withdraw.sh max      # Withdraw all
```

### Auto-Deposit Daemon

```bash
PRIVATE_KEY=0x... ./agent/auto-deposit.sh
```

Runs continuously, automatically depositing when wallet balance exceeds threshold.

## ⚙️ Configuration

Edit `agent/config.json`:

```json
{
  "agent": {
    "minIdleUSDC": 1000000,      // Keep 1 USDC as buffer
    "depositThreshold": 5000000, // Auto-deposit when > 5 USDC
    "checkIntervalMs": 30000     // Check every 30 seconds
  }
}
```

## 🔒 Security

- ERC-4626 standard compliance
- No admin functions or special privileges
- Simple, auditable code
- Verified on Sourcify

## 📊 How It Works

### Deposit Flow
1. User approves USDC spend to vault
2. User calls `deposit(assets, receiver)`
3. Vault mints shares 1:1 with deposited USDC
4. USDC is held in vault contract

### Withdraw Flow
1. User calls `withdraw(assets, receiver, owner)`
2. Vault burns proportional shares
3. User receives USDC

### Agent Integration
1. Agent monitors wallet USDC balance via `status.sh`
2. When balance > threshold, agent calls `deposit.sh`
3. Agent can trigger withdrawals based on external signals
4. All actions are logged for transparency

## 🛠️ Development

### Run Tests

```bash
forge test
```

### Run Specific Test

```bash
forge test --match-test test_Deposit -vvv
```

### Gas Report

```bash
forge test --gas-report
```

## 📄 License

MIT

## 🙏 Acknowledgments

- [OpenZeppelin](https://openzeppelin.com/) - ERC-4626 implementation
- [Foundry](https://getfoundry.sh/) - Development framework
- [Circle](https://www.circle.com/) - USDC
- [Base](https://base.org/) - L2 network

---

Built for the USDC Hackathon 🏆
