#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export BTC=$(read_address ".btc")
export USDC=$(read_address ".usdc")
export BTC_POOL_TOKEN=$(read_address ".btcPoolToken")
export BTC_LEVERAGED_POOL=$(read_address ".btcLeveragedPool")
export BTC_POOL_COMMITTER=$(read_address ".btcPoolCommitter")
export VERIFY=false
export BTC_PERP_POOL_POSITION_MANAGER_NAME="BtcPerpPool"
export GLP_AAVE_BORROW_VAULT_NAME="GLP-PERP-POOL"
export PRICE_UTILS=$(read_address ".priceUtils") 
export PERP_POOL_UTILS=$(read_address ".perpPoolUtils") 
export GLP_AAVE_BORROW_VAULT=$(read_address ".glpAaveBorrowVault") 

forge script DeployBtcPerpPoolPositionManager \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation