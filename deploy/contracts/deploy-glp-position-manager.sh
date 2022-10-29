#!/bin/bash

args=(
	--rpc-url $RPC_URL
	--private-key=$PRIVATE_KEY
	--constructor-args
		$GLP_POSITION_MANAGER_ID
		$PRICE_UTILS
		$GLP_UTILS
		$GLP_MANAGER
		$USDC
		$REWARD_ROUTER
		$DELTA_NEUTRAL_REBALANCER
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