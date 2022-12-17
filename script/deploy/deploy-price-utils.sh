#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export GLP_MANAGER=$(read_address ".glpManager")
export GLP_TOKEN=$(read_address ".glpToken")
export VAULT=$(read_address ".vault")
export POOL_STATE_HELPER=$(read_address ".poolStateHelper")

forge script DeployPriceUtils \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation

