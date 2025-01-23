#!/bin/bash

CHAIN_ID=cytonic_52225-1
CHAIN_HOME=/data
RUN_NODE_COMMAND="docker compose exec"

$RUN_NODE_COMMAND $1 evmosd --chain-id $CHAIN_ID --home $CHAIN_HOME/$1 "${@:2}"