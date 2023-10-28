#!/bin/bash
export IMPL_SALT=$(openssl rand -hex 32)
export LATEST_BLOCK=$(cast block finalized --rpc-url https://opbnb-testnet-rpc.bnbchain.org --json)
export L2_OUTPUT_ORACLE_TIMESTAMP=$(echo $LATEST_BLOCK | jq -r '.timestamp')
export L1STARTINGBLOCKTAG=$(echo $LATEST_BLOCK | jq -r '.hash')

if [ ! -f "/opstack/optimism/op-node/genesis.json" ]; then
    echo "Preparing files..."
    cp -R /opstack-temp/* /opstack/
    # Run builder and replace files
    cd /opstack/tools/
    node server.js
    cp /opstack/tools/builds/getting-started.json /opstack/optimism/packages/contracts-bedrock/deploy-config/getting-started.json
    cp /opstack/tools/builds/hardhat.config.ts /opstack/optimism/packages/contracts-bedrock/hardhat.config.ts
    echo "Files Ready"

    # Deploy Contracts
    echo "Now deploying contracts..."
    cd /opstack/optimism/packages/contracts-bedrock
    rm -rf deployments/*
    mkdir deployments/getting-started
    forge script scripts/Deploy.s.sol:Deploy --private-key $PRIVATE_KEY --broadcast --rpc-url $ETH_RPC_URL
    forge script scripts/Deploy.s.sol:Deploy --sig 'sync()' --private-key $PRIVATE_KEY --broadcast --rpc-url $ETH_RPC_URL


    # Generate the L2 config files
    cd /opstack/optimism/op-node
    go run cmd/main.go genesis l2 \
    --deploy-config ../packages/contracts-bedrock/deploy-config/getting-started.json \
    --deployment-dir ../packages/contracts-bedrock/deployments/getting-started/ \
    --outfile.l2 genesis.json \
    --outfile.rollup rollup.json \
    --l1-rpc $L1_RPC
    openssl rand -hex 32 > jwt.txt
    cp genesis.json /opstack/op-geth
    cp jwt.txt /opstack/op-geth

    # Initialize op-geth
    cd /opstack/op-geth
    mkdir datadir
    echo "pwd" > datadir/password
    echo $PRIVATE_KEY_SEQUENCER > datadir/block-signer-key
    ./build/bin/geth account import --datadir=datadir --password=datadir/password datadir/block-signer-key
    build/bin/geth init --datadir=datadir genesis.json
    echo "Build Successful ✅"
    exit 0
else
    echo "Found genesis file. Not rebuilding."
    exit 0
fi