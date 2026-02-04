#!/bin/bash
# USDC Vault Monitor - Agent Script
# Monitors wallet balance and auto-deposits idle USDC into the vault

set -e

# Load config
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/config.json"

RPC=$(jq -r '.network.rpc' "$CONFIG")
VAULT=$(jq -r '.contracts.vault' "$CONFIG")
USDC=$(jq -r '.contracts.usdc' "$CONFIG")
WALLET=$(jq -r '.agent.wallet' "$CONFIG")
MIN_IDLE=$(jq -r '.agent.minIdleUSDC' "$CONFIG")
DEPOSIT_THRESHOLD=$(jq -r '.agent.depositThreshold' "$CONFIG")

CAST="${CAST:-$HOME/.foundry/bin/cast}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           USDC Vault Agent Monitor                        ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Get balances
get_usdc_balance() {
    $CAST call "$USDC" "balanceOf(address)(uint256)" "$1" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}'
}

get_share_balance() {
    $CAST call "$VAULT" "balanceOf(address)(uint256)" "$1" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}'
}

get_total_assets() {
    $CAST call "$VAULT" "totalAssets()(uint256)" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}'
}

get_total_supply() {
    $CAST call "$VAULT" "totalSupply()(uint256)" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}'
}

format_usdc() {
    echo "scale=2; $1 / 1000000" | bc
}

# Fetch current state
WALLET_USDC=$(get_usdc_balance "$WALLET")
WALLET_SHARES=$(get_share_balance "$WALLET")
VAULT_ASSETS=$(get_total_assets)
VAULT_SUPPLY=$(get_total_supply)

echo -e "${GREEN}Wallet State:${NC}"
echo "  Address:     $WALLET"
echo "  USDC:        $(format_usdc $WALLET_USDC) USDC"
echo "  Vault Shares: $(format_usdc $WALLET_SHARES) svUSDC"
echo ""

echo -e "${GREEN}Vault State:${NC}"
echo "  Address:     $VAULT"
echo "  Total Assets: $(format_usdc $VAULT_ASSETS) USDC"
echo "  Total Supply: $(format_usdc $VAULT_SUPPLY) svUSDC"
echo ""

# Calculate share price (if supply > 0)
if [ "$VAULT_SUPPLY" -gt 0 ]; then
    SHARE_PRICE=$(echo "scale=6; $VAULT_ASSETS / $VAULT_SUPPLY" | bc)
    echo -e "${GREEN}Share Price:${NC} $SHARE_PRICE USDC/svUSDC"
else
    echo -e "${YELLOW}Share Price:${NC} N/A (no shares minted)"
fi
echo ""

# Check if auto-deposit needed
if [ "$WALLET_USDC" -gt "$DEPOSIT_THRESHOLD" ]; then
    DEPOSIT_AMOUNT=$((WALLET_USDC - MIN_IDLE))
    echo -e "${YELLOW}⚠ Idle USDC detected: $(format_usdc $WALLET_USDC) USDC${NC}"
    echo -e "${YELLOW}  Recommended deposit: $(format_usdc $DEPOSIT_AMOUNT) USDC${NC}"
    echo -e "${YELLOW}  (keeping $(format_usdc $MIN_IDLE) USDC as buffer)${NC}"
    echo ""
    echo "  Run: ./deposit.sh $DEPOSIT_AMOUNT"
else
    echo -e "${GREEN}✓ No action needed - wallet balance within threshold${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
