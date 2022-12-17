#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat ../../config/addresses.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

export RPC_URL="http://localhost:8545"
export VAULT_READER=$(read_address ".vaultReader")
export VAULT=$(read_address ".vault")
export REWARD_ROUTER=$(read_address ".rewardRouter")
export POSITION_MANAGER=$(read_address ".positionManager")
export GLP_MANAGER=$(read_address ".glpManager")
export GLP_TOKEN=$(read_address ".glpToken")
export POOL_STATE_HELPER=$(read_address ".poolStateHelper")
export GMX_ROUTER=$(read_address ".gmxRouter") 
export BTC=$(read_address ".btc")
export ETH=$(read_address ".eth")
export USDC=$(read_address ".usdc")
export BTC_POOL_TOKEN=$(read_address ".btcPoolToken")
export BTC_PRICE_FEED=$(read_address ".btcPriceFeed")
export BTC_LEVERAGED_POOL=$(read_address ".btcLeveragedPool")
export BTC_POOL_COMMITTER=$(read_address ".btcPoolCommitter")
export ETH_POOL_TOKEN=$(read_address ".ethPoolToken")
export ETH_LEVERAGED_POOL=$(read_address ".ethLeveragedPool")
export ETH_POOL_COMMITTER=$(read_address ".ethPoolCommitter")
export ETH_PRICE_FEED=$(read_address ".ethPriceFeed")
export AAVE_L2_POOL=$(read_address ".aaveL2Pool")
export AAVE_L2_ENCODER=$(read_address ".aaveL2Encoder")
export ETH_PRICE_FEED=$(read_address ".ethPriceFeed")
export AAVE_PROTOCOL_DATA_PROVIDER=$(read_address ".aaveProtocolDataProvider")

export VERIFY=false
export BTC_PERP_POOL_POSITION_MANAGER_NAME="BtcPerpPool"
export ETH_PERP_POOL_POSITION_MANAGER_NAME="EthPerpPool"
export AAVE_BORROW_BTC_POSITION_MANAGER_NAME="AaveBorrowBtc"
export AAVE_BORROW_BTC_TARGET_LTV=60
export AAVE_BORROW_BTC_POSITION_MANAGER_DECIMALS=8
export AAVE_BORROW_ETH_POSITION_MANAGER_NAME="AaveBorrowEth"
export AAVE_BORROW_ETH_POSITION_MANAGER_DECIMALS=8
export AAVE_BORROW_ETH_TARGET_LTV=60
export GLP_AAVE_BORROW_VAULT_NAME="GLP-PERP-POOL"

forge script DeployAllContracts \
	--broadcast \
	--private-key $PRIVATE_KEY \
	--rpc-url $RPC_URL \
	--skip-simulation
