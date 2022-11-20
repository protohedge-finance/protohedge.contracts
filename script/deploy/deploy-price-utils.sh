#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="http://localhost:8545"

forge script DeployPriceUtils \
	--json \
	--broadcast \
	--private-key $PRIVATE_KEY \
	--rpc-url $RPC_URL \

	
	