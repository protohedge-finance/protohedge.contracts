#!/bin/bash

forge script DeployPriceUtils \
	--json \
	--broadcast \
	--private-key $PRIVATE_KEY \
	--rpc-url $RPC_URL \
	--skip-simulation

	
	