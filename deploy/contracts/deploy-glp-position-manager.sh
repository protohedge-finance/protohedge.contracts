#!/bin/bash

args=(
	--rpc-url $RPC_URL
	--private-key=$PRIVATE_KEY
	--constructor-args
		$PRICE_UTILS
		$GLP_UTILS
		$GLP_MANAGER
		$USDC
		$ETH
		$ETH_PRICE_FEED
		$REWARD_ROUTER
		$GLP_PERP_POOL_VAULT
    --etherscan-api-key=$ETHERSCAN_API_KEY
    --json
)

if [ "$VERIFY" = true ]; then
    args+=(
        --verify
    )
fi

args+=(src/GlpPositionManager.sol:GlpPositionManager)

forge create "${args[@]}"