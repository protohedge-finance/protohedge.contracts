#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="https://arb1.arbitrum.io/rpc"
export GMX_ROUTER=$(read_address ".gmxRouter") 
export BTC=$(read_address ".btc")
export USDC=$(read_address ".usdc")
export BTC_PRICE_FEED=$(read_address ".btcPriceFeed")
export PRICE_UTILS=$(read_address ".priceUtils")
export AAVE_L2_POOL=$(read_address ".aaveL2Pool")
export AAVE_L2_ENCODER=$(read_address ".aaveL2Encoder")
export AAVE_BORROW_BTC_POSITION_MANAGER_NAME="AaveBorrowBtc"
export GLP_PERP_POOL_VAULT=$(read_address ".aaveL2Encoder")
export AAVE_BORROW_BTC_POSITION_MANAGER_DECIMALS=8
export AAVE_BORROW_BTC_TARGET_LTV=60

forge script DeployAaveBtcBorrowPositionManager \
	--broadcast \
	--private-key $PERSONAL_PRIVATE_KEY \
	--verify \
	--rpc-url $RPC_URL \
	--skip-simulation