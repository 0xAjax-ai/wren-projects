#!/bin/bash
# USDC Vault Status - Quick one-liner for agents
# Returns JSON status for easy parsing

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/config.json"

RPC=$(jq -r '.network.rpc' "$CONFIG")
VAULT=$(jq -r '.contracts.vault' "$CONFIG")
USDC=$(jq -r '.contracts.usdc' "$CONFIG")
WALLET=$(jq -r '.agent.wallet' "$CONFIG")

CAST="${CAST:-$HOME/.foundry/bin/cast}"

# Fetch all data
WALLET_USDC=$($CAST call "$USDC" "balanceOf(address)(uint256)" "$WALLET" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}')
WALLET_SHARES=$($CAST call "$VAULT" "balanceOf(address)(uint256)" "$WALLET" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}')
VAULT_ASSETS=$($CAST call "$VAULT" "totalAssets()(uint256)" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}')
VAULT_SUPPLY=$($CAST call "$VAULT" "totalSupply()(uint256)" --rpc-url "$RPC" 2>/dev/null | head -1 | awk '{print $1}')

# Calculate share price
if [ "$VAULT_SUPPLY" -gt 0 ]; then
    SHARE_PRICE=$(echo "scale=6; $VAULT_ASSETS / $VAULT_SUPPLY" | bc)
else
    SHARE_PRICE="1.000000"
fi

# Output JSON
cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "network": "base-sepolia",
  "vault": {
    "address": "$VAULT",
    "totalAssets": $VAULT_ASSETS,
    "totalAssetsFormatted": "$(echo "scale=2; $VAULT_ASSETS / 1000000" | bc) USDC",
    "totalSupply": $VAULT_SUPPLY,
    "sharePrice": $SHARE_PRICE
  },
  "wallet": {
    "address": "$WALLET",
    "usdcBalance": $WALLET_USDC,
    "usdcFormatted": "$(echo "scale=2; $WALLET_USDC / 1000000" | bc) USDC",
    "vaultShares": $WALLET_SHARES,
    "sharesFormatted": "$(echo "scale=2; $WALLET_SHARES / 1000000" | bc) svUSDC"
  }
}
EOF
