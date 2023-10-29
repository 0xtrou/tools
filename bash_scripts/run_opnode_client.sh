#!/bin/bash
#heathcheck opgeth, and run

code=$(curl -s -o /dev/null -w "%{http_code}" 'http://opgeth:8551')
echo "Code: "
echo $code

if [ "$code" = 401 ]; then
    echo "Genesis file found. Starting Opnode."
    cd /opstack/optimism/op-node
    ./bin/op-node \
        --l2=http://opgeth:8551 \
        --l2.jwt-secret=./jwt.txt \
        --verifier.l1-confs=3 \
        --rollup.config=./rollup.json \
        --rpc.addr=0.0.0.0 \
        --p2p.static=$BOOT_NODES \
        --p2p.listen.ip=0.0.0.0 \
        --p2p.listen.tcp=9003 \
        --p2p.listen.udp=9003 \
        --rpc.port=8547 \
        --rpc.enable-admin \
        --l1=$L1_RPC \
        --l1.rpckind=$RPC_KIND
else
    echo "Node cannot detect OPGeth... Waiting..."
fi