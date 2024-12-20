#!/bin/bash

./scripts/run-node-command.sh $1 init $1
cp genesis.json data/chain/$1/config/