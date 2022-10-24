#!/bin/bash

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
export VERIFY=false


export GLP_UTILS=$(deploy_contract ./deploy-glp-utils.sh)
export PRICE_UTILS=$(deploy_contract ./deploy-price-utils.sh)
export PERP_POOL_UTILS=$(deploy_contract ./deploy-perp-pool-utils.sh)
export DELTA_NEUTRAL_REBALANCER=$(deploy_contract ./deploy-delta-neutral-rebalancer.sh)
export BTC_PERP_POOL_POSITION_MANAGER=$(deploy_contract ./deploy-btc-perp-pool-position-manager.sh)
export ETH_PERP_POOL_POSITION_MANAGER=$(deploy_contract ./deploy-eth-perp-pool-position-manager.sh)
export GLP_POSITION_MANAGER=$(deploy_contract ./deploy-glp-position-manager.sh)