#!/bin/bash
# USDC Vault Deposit Script
# Deposits USDC into the vault

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/config.json"

RPC=$(jq -r '.network.rpc' "$CONFIG")
VAULT=$(jq -r '.contracts.vault' "$CONFIG")
USDC=$(jq -r '.contracts.usdc' "$CONFIG")
WALLET=$(jq -r '.agent.wallet' "$CONFIG")

CAST="${CAST:-$HOME/.foundry/bin/cast}"
PRIVATE_KEY="${PRIVATE_KEY:-}"

if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable not set"
    exit 1
fi

AMOUNT=${1:-0}

if [ "$AMOUNT" -eq 0 ]; then
    echo "Usage: PRIVATE_KEY=0x... ./deposit.sh <amount_in_wei>"
    echo "  Example: PRIVATE_KEY=0x... ./deposit.sh 5000000  # 5 USDC"
    exit 1
fi

echo "Depositing $AMOUNT USDC ($(echo "scale=2; $AMOUNT / 1000000" | bc) USDC) into vault..."

# Approve
echo "1. Approving USDC spend..."
$CAST send "$USDC" "approve(address,uint256)" "$VAULT" "$AMOUNT" \
    --rpc-url "$RPC" \
    --private-key "$PRIVATE_KEY" \
    --quiet

# Deposit
echo "2. Depositing into vault..."
TX=$($CAST send "$VAULT" "deposit(uint256,address)" "$AMOUNT" "$WALLET" \
    --rpc-url "$RPC" \
    --private-key "$PRIVATE_KEY" \
    --json | jq -r '.transactionHash')

echo ""
echo "✓ Deposit complete!"
echo "  TX: https://sepolia.basescan.org/tx/$TX"
echo ""

# Show new balance
SHARES=$($CAST call "$VAULT" "balanceOf(address)(uint256)" "$WALLET" --rpc-url "$RPC" | head -1 | awk '{print $1}')
echo "  New share balance: $(echo "scale=2; $SHARES / 1000000" | bc) svUSDC"
