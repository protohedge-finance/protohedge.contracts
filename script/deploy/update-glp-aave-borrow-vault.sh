#!/bin/bash

export $(cat ../../../.env | xargs)

deps=$(cat ../../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export GLP_AAVE_BORROW_VAULT_NAME="GLP-PERP-POOL"
export GLP_AAVE_BORROW_VAULT=$(read_address ".glpAaveBorrowVault") 
export GLP_AAVE_BORROW_VAULT_IMPLEMENTATION=0xd4e733280e7edfb5f6f2f9d7760a252d198edbb4
export USDC=$(read_address ".usdc")

forge script UpdateGlpAaveBorrowVault \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation