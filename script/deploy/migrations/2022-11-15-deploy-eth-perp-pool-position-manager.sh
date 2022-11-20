#!/bin/bash

export $(cat ../../../.env | xargs)

deps=$(cat ../../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export ETH=$(read_address ".eth")
export USDC=$(read_address ".usdc")
export ETH_POOL_TOKEN=$(read_address ".ethPoolToken")
export ETH_LEVERAGED_POOL=$(read_address ".ethLeveragedPool")
export ETH_POOL_COMMITTER=$(read_address ".ethPoolCommitter")
export VERIFY=false
export ETH_PERP_POOL_POSITION_MANAGER_NAME="EthPerpPool"
export ETH_PERP_POOL_VAULT_NAME="GLP-PERP-POOL"
export PRICE_UTILS=$(read_address ".priceUtils") 
export PERP_POOL_UTILS=$(read_address ".perpPoolUtils") 
export GLP_PERP_POOL_VAULT=$(read_address ".glpPerpPoolVault") 

forge script DeployEthPerpPoolPositionManager \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation