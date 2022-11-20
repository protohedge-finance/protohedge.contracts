#!/bin/bash

export $(cat ../../../.env | xargs)

deps=$(cat ../../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export VAULT_READER=$(read_address ".vaultReader")
export VAULT=$(read_address ".vault")
export POSITION_MANAGER=$(read_address ".positionManager")
export ETH=$(read_address ".eth")

forge script DeployGlpUtils \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation
