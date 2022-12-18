#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export GLP_AAVE_BORROW_VAULT_NAME="GLP-PERP-POOL"
export USDC=$(read_address ".usdc")
export PRICE_UTILS=$(read_address ".priceUtils")
export ETH_PRICE_FEED=$(read_address ".ethPriceFeed")

forge script DeployGlpAaveBorrowVault \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation
