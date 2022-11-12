#!/bin/bash

export $(cat ../../.env | xargs)

deps=$(cat contract-dependencies.arbitrum.json)

read_address () {
    echo $deps | jq $1 | tr -d '"'
}

deploy_contract () {
    echo $($1) | jq ".deployedTo" | tr -d '"'
}

export RPC_URL="http://localhost:8545"
export VAULT_READER=$(read_address ".vaultReader")
export VAULT=$(read_address ".vault")
export REWARD_ROUTER=$(read_address ".rewardRouter")
export POSITION_MANAGER=$(read_address ".positionManager")
export GLP_MANAGER=$(read_address ".glpManager")
export GLP_TOKEN=$(read_address ".glpToken")
export POOL_STATE_HELPER=$(read_address ".poolStateHelper")
export BTC=$(read_address ".btc")
export ETH=$(read_address ".eth")
export USDC=$(read_address ".usdc")
export BTC_POOL_TOKEN=$(read_address ".btcPoolToken")
export BTC_LEVERAGED_POOL=$(read_address ".btcLeveragedPool")
export BTC_POOL_COMMITTER=$(read_address ".btcPoolCommitter")
export ETH_POOL_TOKEN=$(read_address ".ethPoolToken")
export ETH_LEVERAGED_POOL=$(read_address ".ethLeveragedPool")
export ETH_POOL_COMMITTER=$(read_address ".ethPoolCommitter")
export ETH_PRICE_FEED=$(read_address ".ethPriceFeed")
export VERIFY=false
export BTC_PERP_POOL_POSITION_MANAGER_NAME="BtcPerpPool"
export ETH_PERP_POOL_POSITION_MANAGER_NAME="EthPerpPool"
export GLP_PERP_POOL_VAULT_NAME="GLP-PERP-POOL"

export GLP_UTILS=$(deploy_contract ./deploy-glp-utils.sh)
export PRICE_UTILS=$(deploy_contract ./deploy-price-utils.sh)
export PERP_POOL_UTILS=$(deploy_contract ./deploy-perp-pool-utils.sh)
export GLP_PERP_POOL_VAULT=$(deploy_contract ./deploy-protohedge-vault.sh)
export BTC_PERP_POOL_POSITION_MANAGER=$(deploy_contract ./deploy-btc-perp-pool-position-manager.sh)
export ETH_PERP_POOL_POSITION_MANAGER=$(deploy_contract ./deploy-eth-perp-pool-position-manager.sh)
export GLP_POSITION_MANAGER=$(deploy_contract ./deploy-glp-position-manager.sh)

export GLP_PERP_POSITION_MANAGERS="[$GLP_POSITION_MANAGER,$BTC_PERP_POOL_POSITION_MANAGER,$ETH_PERP_POOL_POSITION_MANAGER]"

cast send --private-key $PRIVATE_KEY $GLP_POSITION_MANAGER "setGlpTokens(address[])" "[0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f,0x82af49447d8a07e3bd95bd0d56f35241523fbab1,0xff970a61a04b1ca14834a43f5de4533ebddb5cc8,0xda10009cbd5d07dd0cecc66161fc93d7c9000da1,0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9]"
cast send --private-key $PRIVATE_KEY $GLP_PERP_POOL_VAULT "setPositionManagers(address[])" $GLP_PERP_POSITION_MANAGERS
cast send --private-key $PERSONAL_PRIVATE_KEY $USDC "transfer(address,uint256)" "$GLP_PERP_POOL_VAULT" 100000

echo "GlpUtils: $GLP_UTILS"
echo "PriceUtils: $PRICE_UTILS"
echo "PerpPoolUtils: $PERP_POOL_UTILS"
echo "BtcPerpPoolPositionManager: $BTC_PERP_POOL_POSITION_MANAGER"
echo "EthPerpPoolPositionManager: $ETH_PERP_POOL_POSITION_MANAGER"
echo "GlpPositionManager: "$GLP_POSITION_MANAGER""
echo "GlpPerpPoolVault": "$GLP_PERP_POOL_VAULT"