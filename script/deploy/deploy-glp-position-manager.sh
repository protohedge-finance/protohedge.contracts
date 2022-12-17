#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export GLP_MANAGER=$(read_address ".glpManager")
export ETH=$(read_address ".eth")
export USDC=$(read_address ".usdc")
export ETH_PRICE_FEED=$(read_address ".ethPriceFeed")
export PRICE_UTILS=$(read_address ".priceUtils")
export GLP_UTILS=$(read_address ".glpUtils")
export REWARD_ROUTER=$(read_address ".rewardRouter")
export GLP_AAVE_BORROW_VAULT=$(read_address ".glpAaveBorrowVault")

forge script DeployGlpPositionManager \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation

