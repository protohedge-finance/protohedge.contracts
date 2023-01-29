#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export AAVE_ETH_BORROW_POSITION_MANAGER=$(read_address ".aaveEthBorrowPositionManager") 

forge script UpdateAaveEthBorrowPositionManager \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation
