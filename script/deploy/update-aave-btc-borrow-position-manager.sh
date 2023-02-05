#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export AAVE_BTC_BORROW_POSITION_MANAGER=$(read_address ".aaveBtcBorrowPositionManager") 

forge script UpdateAaveBtcBorrowPositionManager \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify  \
	--rpc-url $RPC_URL \
	--skip-simulation
