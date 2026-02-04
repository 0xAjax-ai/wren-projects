# USDC Vault: Agent-Managed DeFi
## Autonomous Yield Optimization on Base

---

# The Problem 🤔

**Idle USDC sitting in wallets earns nothing**

- Users forget to deposit into yield protocols
- Manual management is time-consuming
- Missed opportunities while you sleep

---

# The Solution 💡

**AI agents that manage your USDC autonomously**

- Auto-detect idle balances
- Deposit into yield vaults automatically
- 24/7 operation, no human needed
- Configurable thresholds

---

# How It Works

```
┌──────────────┐     ┌──────────────┐
│  Your Wallet │────▶│  USDC Vault  │
│   (USDC)     │     │  (svUSDC)    │
└──────────────┘     └──────────────┘
       ▲                    │
       │    ┌───────────┐   │
       └────│ AI Agent  │◀──┘
            │ (Clawd)   │
            └───────────┘
            
1. Agent monitors wallet balance
2. Detects idle USDC above threshold
3. Auto-deposits into vault
4. You earn yield while sleeping
```

---

# Tech Stack 🛠️

| Layer | Technology |
|-------|------------|
| Smart Contract | Solidity, ERC-4626 |
| Framework | Foundry |
| Network | Base Sepolia |
| Agent | Clawdbot (AI) |
| Token | Circle USDC |

---

# Smart Contract

**SimpleUSDCVault.sol** - ERC-4626 Compliant

```solidity
contract SimpleUSDCVault is ERC4626 {
    IERC20 public constant USDC = 
        IERC20(0x036CbD53842c5426634e7929541eC2318f3dCF7e);

    constructor() 
        ERC4626(USDC) 
        ERC20("Simple Vault USDC", "svUSDC") {}

    function totalAssets() public view override returns (uint256) {
        return USDC.balanceOf(address(this));
    }
}
```

✅ Simple, auditable, secure

---

# Agent Scripts

```bash
agent/
├── monitor.sh      # Dashboard view
├── status.sh       # JSON for automation
├── deposit.sh      # Manual deposit
├── withdraw.sh     # Manual withdraw
└── auto-deposit.sh # 🤖 Autonomous daemon
```

**Auto-deposit daemon runs 24/7:**
- Checks wallet every 30 seconds
- Deposits when balance > 5 USDC
- Keeps 1 USDC buffer for gas

---

# Live Demo 🎬

**Deployed Contract:**
`0xe631fA4D466763bC8fE367ccafBaE2747505179d`

**Current State:**
- Vault Balance: 10 USDC
- Shares Minted: 10 svUSDC
- Share Price: 1.0

[View on BaseScan →](https://sepolia.basescan.org/address/0xe631fA4D466763bC8fE367ccafBaE2747505179d)

---

# Agent in Action

```
╔═══════════════════════════════════════════╗
║   USDC Vault Auto-Deposit Agent Started   ║
╠═══════════════════════════════════════════╣
║  Threshold: 5.00 USDC                     ║
║  Min Idle:  1.00 USDC                     ║
║  Interval:  30s                           ║
╚═══════════════════════════════════════════╝

[06:55:01] Wallet USDC: 2.50 ✓
[06:55:31] Wallet USDC: 2.50 ✓
[06:56:01] Wallet USDC: 12.00 
[06:56:01] ⚡ Auto-depositing 11.00 USDC...
[06:56:05] ✓ Deposited! TX: 0x7a3f...
```

---

# Why ERC-4626?

**The "Tokenized Vault Standard"**

- ✅ Composable with other DeFi
- ✅ Standard interface (deposit/withdraw/redeem)
- ✅ Share-based accounting
- ✅ Easy integration for agents
- ✅ Battle-tested pattern

---

# Future Roadmap 🚀

**Phase 1** (Now)
- ✅ Basic vault on testnet
- ✅ Agent auto-deposit

**Phase 2**
- Aave/Compound yield integration
- Multi-strategy optimization
- APY monitoring & switching

**Phase 3**
- Cross-chain deposits
- Risk-adjusted allocation
- DAO governance

---

# Security Considerations 🔒

- **No admin keys** - Fully permissionless
- **ERC-4626 standard** - Well-audited pattern
- **Simple code** - Easy to verify
- **Open source** - Full transparency
- **Verified on Sourcify** ✅

---

# Team

**Built by AI + Human collaboration**

- 🤖 Clawdbot - AI coding agent
- 👤 Aregus - Human guidance

*Demonstrating the future of development:*
*Humans direct, AI executes*

---

# Links

| Resource | URL |
|----------|-----|
| Contract | [BaseScan](https://sepolia.basescan.org/address/0xe631fA4D466763bC8fE367ccafBaE2747505179d) |
| GitHub | [Coming Soon] |
| Demo Video | [Coming Soon] |

---

# Thank You! 🙏

**Questions?**

Built for the USDC Hackathon 🏆

---
