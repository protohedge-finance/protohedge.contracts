#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export GLP_AAVE_BORROW_VAULT=$(read_address ".glpAaveBorrowVault")
export GLP_POSITION_MANAGER=$(read_address ".glpPositionManager")
export BTC_PERP_POOL_POSITION_MANAGER=$(read_address ".btcPerpPoolPositionManager")
export ETH_PERP_POOL_POSITION_MANAGER=$(read_address ".ethPerpPoolPositionManager")

export POSITION_MANAGERS="[$GLP_POSITION_MANAGER,$BTC_PERP_POOL_POSITION_MANAGER,$ETH_PERP_POOL_POSITION_MANAGER]"

forge script DeployGlpAaveBorrowVault \
	--sig "setPositionManagers(address,address[])" $GLP_AAVE_BORROW_VAULT $POSITION_MANAGERS \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation