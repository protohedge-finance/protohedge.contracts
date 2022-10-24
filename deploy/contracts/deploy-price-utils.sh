#!/bin/bash

args=(
	--rpc-url $RPC_URL
	--private-key=$PRIVATE_KEY
	--constructor-args
		$GLP_MANAGER
		$GLP_TOKEN
		$VAULT
		$POOL_STATE_HELPER
    --etherscan-api-key=$ETHERSCAN_API_KEY
    --json
)

if [ "$VERIFY" = true ]; then
    args+=(
        --verify
    )
fi

args+=(src/PriceUtils.sol:PriceUtils)

forge create "${args[@]}"