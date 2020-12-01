#!/bin/bash

exec 2>&1
set -e
set -x

echo "Staring sentry..."
SEKAID_HOME=$HOME/.sekaid
rm -rf $SEKAID_HOME/config

sekaid init --chain-id=testing testing --home=$SEKAID_HOME
cp $SELF_CONFIGS/genesis.json $SEKAID_HOME/config/genesis.json
cp $SELF_CONFIGS/config.toml $SEKAID_HOME/config/config.toml
cp $SELF_CONFIGS/node_key.json $SEKAID_HOME/config/node_key.json

sekaid start --home=$SEKAID_HOME --rpc.laddr="tcp://0.0.0.0:26657"
