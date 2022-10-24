#!/bin/bash

args=(
	--rpc-url $RPC_URL
	--private-key=$PRIVATE_KEY
	--constructor-args
		$VAULT_READER
		$VAULT
		$POSITION_MANAGER
		$ETH
    --etherscan-api-key=$ETHERSCAN_API_KEY
    --json
)


if [ "$VERIFY" = true ]; then
    args+=(
        --verify
    )
fi

args+=(src/GlpUtils.sol:GlpUtils)

forge create "${args[@]}"

