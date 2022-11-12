#!/bin/bash

args=(
	--rpc-url $RPC_URL
	--private-key=$PRIVATE_KEY
	--constructor-args
		$GLP_PERP_POOL_VAULT_NAME
		$USDC
    --etherscan-api-key=$ETHERSCAN_API_KEY
    --json
)


if [ "$VERIFY" = true ]; then
    args+=(
        --verify
    )
fi

args+=(src/ProtohedgeVault.sol:ProtohedgeVault)

forge create "${args[@]}"
