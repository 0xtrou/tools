#!/bin/bash
if [ -f "/opstack/op-geth/genesis.json" ] && [ -f "/opstack/optimism/op-node/rollup.json" ]; then
    echo "Preparing files..."
    cp -R /opstack-temp/* /opstack/

    # copy assets
    cp /assets/genesis.json /opstack/op-geth
    cp /assets/rollup.json /opstack/optimism/op-node

    # Generate the L2 config files
    cd /opstack/optimism/op-node
    openssl rand -hex 32 > jwt.txt
    cp jwt.txt /opstack/op-geth

    # Initialize op-geth
    cd /opstack/op-geth
    mkdir datadir
    echo "pwd" > datadir/password
    build/bin/geth init --datadir=datadir genesis.json
    echo "Build Successful ✅"
    exit 0
else
    echo "Not found genesis file. Not rebuilding."
    exit 0
fi