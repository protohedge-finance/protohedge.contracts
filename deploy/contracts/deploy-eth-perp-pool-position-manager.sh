#!/bin/bash

args=(
	--rpc-url $RPC_URL
	--private-key=$PRIVATE_KEY
	--constructor-args
        $ETH_PERP_POOL_POSITION_MANAGER_NAME
        $ETH_POOL_TOKEN
        $PRICE_UTILS
        $ETH_LEVERAGED_POOL
        $ETH
        $ETH_POOL_COMMITTER
        $USDC
        $PERP_POOL_UTILS
        $GLP_PERP_POOL_VAULT
    --etherscan-api-key=$ETHERSCAN_API_KEY
    --json
)

if [ "$VERIFY" = true ]; then
    args+=(
        --verify
    )
fi

args+=(src/PerpPoolPositionManager.sol:PerpPoolPositionManager)

forge create "${args[@]}"