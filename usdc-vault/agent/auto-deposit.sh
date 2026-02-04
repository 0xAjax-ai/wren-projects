#!/bin/bash
# USDC Vault Auto-Deposit Daemon
# Continuously monitors and auto-deposits idle USDC

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/config.json"

RPC=$(jq -r '.network.rpc' "$CONFIG")
VAULT=$(jq -r '.contracts.vault' "$CONFIG")
USDC=$(jq -r '.contracts.usdc' "$CONFIG")
WALLET=$(jq -r '.agent.wallet' "$CONFIG")
MIN_IDLE=$(jq -r '.agent.minIdleUSDC' "$CONFIG")
DEPOSIT_THRESHOLD=$(jq -r '.agent.depositThreshold' "$CONFIG")
INTERVAL=$(jq -r '.agent.checkIntervalMs' "$CONFIG")

CAST="${CAST:-$HOME/.foundry/bin/cast}"
PRIVATE_KEY="${PRIVATE_KEY:-}"

if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable not set"
    echo "Usage: PRIVATE_KEY=0x... ./auto-deposit.sh"
    exit 1
fi

INTERVAL_SEC=$((INTERVAL / 1000))

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║        USDC Vault Auto-Deposit Agent Started              ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo "║  Wallet:    $WALLET"
echo "║  Vault:     $VAULT"
echo "║  Threshold: $(echo "scale=2; $DEPOSIT_THRESHOLD / 1000000" | bc) USDC"
echo "║  Min Idle:  $(echo "scale=2; $MIN_IDLE / 1000000" | bc) USDC"
echo "║  Interval:  ${INTERVAL_SEC}s"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get wallet USDC balance
    WALLET_USDC=$($CAST call "$USDC" "balanceOf(address)(uint256)" "$WALLET" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}')
    
    echo "[$TIMESTAMP] Wallet USDC: $(echo "scale=2; $WALLET_USDC / 1000000" | bc)"
    
    # Check if deposit needed
    if [ "$WALLET_USDC" -gt "$DEPOSIT_THRESHOLD" ]; then
        DEPOSIT_AMOUNT=$((WALLET_USDC - MIN_IDLE))
        
        echo "[$TIMESTAMP] ⚡ Auto-depositing $(echo "scale=2; $DEPOSIT_AMOUNT / 1000000" | bc) USDC..."
        
        # Approve
        $CAST send "$USDC" "approve(address,uint256)" "$VAULT" "$DEPOSIT_AMOUNT" \
            --rpc-url "$RPC" \
            --private-key "$PRIVATE_KEY" \
            --quiet 2>/dev/null
        
        # Deposit
        TX=$($CAST send "$VAULT" "deposit(uint256,address)" "$DEPOSIT_AMOUNT" "$WALLET" \
            --rpc-url "$RPC" \
            --private-key "$PRIVATE_KEY" \
            --json 2>/dev/null | jq -r '.transactionHash')
        
        echo "[$TIMESTAMP] ✓ Deposited! TX: $TX"
    fi
    
    sleep "$INTERVAL_SEC"
done
