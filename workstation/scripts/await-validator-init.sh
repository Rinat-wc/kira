#!/bin/bash
set +e && source "/etc/profile" &>/dev/null && set -e

GENESIS_SOURCE=$1
GENESIS_DESTINATION=$2
VALIDATOR_NODE_ID=$3

i=0
SEKAID_VERSION="error"
while [ $i -le 18 ]; do
    i=$((i + 1))

    echo "INFO: Waiting for validator container to start..."
    CONTAINER_EXISTS=$($KIRA_SCRIPTS/container-exists.sh "validator" || echo "error")
    if [ "${CONTAINER_EXISTS,,}" != "true" ] ; then
        sleep 3
        echo "WARNING: Validator container does not exists yet, waiting..."
        continue
    else
        echo "INFO: Success, validator container was found"
    fi

    echo "INFO: Checking if sekai was installed..."
    SEKAID_VERSION=$(docker exec -i "validator" sekaid version || echo "error")
    if [ "${SEKAID_VERSION,,}" == "error" ] ; then
        sleep 3
        echo "WARNING: sekaid was not installed yet, waiting..."
        continue
    else
        echo "INFO: Success, sekaid $SEKAID_VERSIO is present"
    fi

    echo "INFO: Attempting to access genesis file..."
    docker cp -a validator:$GENESIS_SOURCE $GENESIS_DESTINATION || rm -fv $GENESIS_DESTINATION

    if [ ! -f "$GENESIS_DESTINATION" ]; then
        sleep 3
        echo "WARNING: Failed to copy genesis file from validator"
        continue
    else
        echo "INFO: Success, genesis file was copied to $GENESIS_DESTINATION"
    fi
done

if [ ! -f "$GENESIS_DESTINATION" ] || [ "${SEKAID_VERSION,,}" == "error" ] ; then
    echo "ERROR: Failed to copy copy genesis file from the validator node"
    exit 1
fi

CHECK_VALIDATOR_NODE_ID=$(docker exec -i "validator" sekaid tendermint show-node-id --home /root/.simapp || echo "error")

if [ "$CHECK_VALIDATOR_NODE_ID" != "$VALIDATOR_NODE_ID" ] ; then echo
    echo "ERROR: Check Validator Node id check failed!"
    echo "ERROR: Expected '$VALIDATOR_NODE_ID', but got '$CHECK_VALIDATOR_NODE_ID'"
    exit 1
else
    echo "INFO: Validator node id check succeded '$CHECK_VALIDATOR_NODE_ID' is a match"
    exit 0
fi