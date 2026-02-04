#!/bin/bash
# USDC Vault Withdraw Script
# Withdraws USDC from the vault

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/config.json"

RPC=$(jq -r '.network.rpc' "$CONFIG")
VAULT=$(jq -r '.contracts.vault' "$CONFIG")
WALLET=$(jq -r '.agent.wallet' "$CONFIG")

CAST="${CAST:-$HOME/.foundry/bin/cast}"
PRIVATE_KEY="${PRIVATE_KEY:-}"

if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable not set"
    exit 1
fi

AMOUNT=${1:-0}

if [ "$AMOUNT" -eq 0 ]; then
    echo "Usage: PRIVATE_KEY=0x... ./withdraw.sh <amount_in_wei>"
    echo "  Example: PRIVATE_KEY=0x... ./withdraw.sh 5000000  # 5 USDC"
    echo ""
    echo "  Or use 'max' to withdraw all:"
    echo "  PRIVATE_KEY=0x... ./withdraw.sh max"
    exit 1
fi

# Handle 'max' withdrawal
if [ "$AMOUNT" = "max" ]; then
    SHARES=$($CAST call "$VAULT" "balanceOf(address)(uint256)" "$WALLET" --rpc-url "$RPC" | head -1 | awk '{print $1}')
    AMOUNT=$($CAST call "$VAULT" "convertToAssets(uint256)(uint256)" "$SHARES" --rpc-url "$RPC" | head -1 | awk '{print $1}')
    echo "Max withdrawal: $AMOUNT USDC ($(echo "scale=2; $AMOUNT / 1000000" | bc) USDC)"
fi

echo "Withdrawing $AMOUNT USDC ($(echo "scale=2; $AMOUNT / 1000000" | bc) USDC) from vault..."

TX=$($CAST send "$VAULT" "withdraw(uint256,address,address)" "$AMOUNT" "$WALLET" "$WALLET" \
    --rpc-url "$RPC" \
    --private-key "$PRIVATE_KEY" \
    --json | jq -r '.transactionHash')

echo ""
echo "✓ Withdrawal complete!"
echo "  TX: https://sepolia.basescan.org/tx/$TX"
echo ""

# Show new balance
USDC_BAL=$($CAST call "0x036CbD53842c5426634e7929541eC2318f3dCF7e" "balanceOf(address)(uint256)" "$WALLET" --rpc-url "$RPC" | head -1 | awk '{print $1}')
echo "  New USDC balance: $(echo "scale=2; $USDC_BAL / 1000000" | bc) USDC"
