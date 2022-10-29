#!/bin/bash

args=(
	--rpc-url $RPC_URL
	--private-key=$PRIVATE_KEY
	--constructor-args
        $BTC_PERP_POOL_POSITION_MANAGER_ID
        $BTC_POOL_TOKEN
        $PRICE_UTILS
        $BTC_LEVERAGED_POOL
        $BTC
        $BTC_POOL_COMMITTER
        $USDC
        $PERP_POOL_UTILS
        $DELTA_NEUTRAL_REBALANCER
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