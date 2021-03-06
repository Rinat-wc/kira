#!/bin/bash

exec 2>&1
set -e
set -x

echo "Staring sentry..."
SEKAID_HOME=$HOME/.simapp
rm -rf $SEKAID_HOME/config

sekaid init --chain-id=testing testing --home=$SEKAID_HOME
cp root/node_key.json $SEKAID_HOME/config/
cp root/genesis.json $SEKAID_HOME/config/
cp root/config.toml $SEKAID_HOME/config/

sekaid start --home=$SEKAID_HOME --rpc.laddr="tcp://0.0.0.0:26657"
