#!/bin/bash

CHAIN_HOME=/data
CHAIN_ID=cytonic_52225-1
RUN_NODE_COMMAND="docker compose run --no-deps --rm"

mkdir -p ./data/chain

$RUN_NODE_COMMAND node-a init node-a --chain-id $CHAIN_ID --home $CHAIN_HOME/node-a
$RUN_NODE_COMMAND node-b init node-b --chain-id $CHAIN_ID --home $CHAIN_HOME/node-b
$RUN_NODE_COMMAND node-c init node-c --chain-id $CHAIN_ID --home $CHAIN_HOME/node-c
$RUN_NODE_COMMAND node-d init node-d --chain-id $CHAIN_ID --home $CHAIN_HOME/node-d

cp sample-genesis.json data/chain/node-a/config
mv data/chain/node-a/config/sample-genesis.json data/chain/node-a/config/genesis.json

NODE_A_KEY=$($RUN_NODE_COMMAND node-a keys add validator-a --keyring-backend test --home $CHAIN_HOME/node-a --output json)
NODE_B_KEY=$($RUN_NODE_COMMAND node-b keys add validator-b --keyring-backend test --home $CHAIN_HOME/node-b --output json)
NODE_C_KEY=$($RUN_NODE_COMMAND node-c keys add validator-c --keyring-backend test --home $CHAIN_HOME/node-c --output json)
NODE_D_KEY=$($RUN_NODE_COMMAND node-d keys add validator-d --keyring-backend test --home $CHAIN_HOME/node-d --output json)

NODE_A_ADDRESS=$(echo $NODE_A_KEY | jq -r .address)
NODE_B_ADDRESS=$(echo $NODE_B_KEY | jq -r .address)
NODE_C_ADDRESS=$(echo $NODE_C_KEY | jq -r .address)
NODE_D_ADDRESS=$(echo $NODE_D_KEY | jq -r .address)

$RUN_NODE_COMMAND node-a add-genesis-account $NODE_A_ADDRESS 10000000000000000000000000000aevmos --home $CHAIN_HOME/node-a
$RUN_NODE_COMMAND node-a add-genesis-account $NODE_B_ADDRESS 10000000000000000000000000000aevmos --home $CHAIN_HOME/node-a
$RUN_NODE_COMMAND node-a add-genesis-account $NODE_C_ADDRESS 10000000000000000000000000000aevmos --home $CHAIN_HOME/node-a
$RUN_NODE_COMMAND node-a add-genesis-account $NODE_D_ADDRESS 10000000000000000000000000000aevmos --home $CHAIN_HOME/node-a

echo data/chain/node-b/config data/chain/node-c/config data/chain/node-d/config | xargs -n 1 cp data/chain/node-a/config/genesis.json

$RUN_NODE_COMMAND node-a gentx validator-a 1000000000000000000aevmos --keyring-backend test --home $CHAIN_HOME/node-a --chain-id $CHAIN_ID
$RUN_NODE_COMMAND node-b gentx validator-b 1000000000000000000aevmos --keyring-backend test --home $CHAIN_HOME/node-b --chain-id $CHAIN_ID --output-document $CHAIN_HOME/node-a/config/gentx/validator-b.json
$RUN_NODE_COMMAND node-c gentx validator-c 1000000000000000000aevmos --keyring-backend test --home $CHAIN_HOME/node-c --chain-id $CHAIN_ID --output-document $CHAIN_HOME/node-a/config/gentx/validator-c.json
$RUN_NODE_COMMAND node-d gentx validator-d 1000000000000000000aevmos --keyring-backend test --home $CHAIN_HOME/node-d --chain-id $CHAIN_ID --output-document $CHAIN_HOME/node-a/config/gentx/validator-d.json

$RUN_NODE_COMMAND node-a collect-gentxs --home $CHAIN_HOME/node-a

echo data/chain/node-b/config data/chain/node-c/config data/chain/node-d/config | xargs -n 1 cp data/chain/node-a/config/genesis.json

$RUN_NODE_COMMAND node-a validate-genesis --home $CHAIN_HOME/node-a

#sed -i.bak 's/seed_mode = false/seed_mode = true/g' data/chain/node-a/config/config.toml
BOOTSTRAP_ID=$($RUN_NODE_COMMAND node-a tendermint show-node-id --home $CHAIN_HOME/node-a)

sed -i.bak 's/seeds = \"\"/seeds = \"'$BOOTSTRAP_ID'@10.5.0.2:26656\"/g' data/chain/node-b/config/config.toml
sed -i.bak 's/seeds = \"\"/seeds = \"'$BOOTSTRAP_ID'@10.5.0.2:26656\"/g' data/chain/node-c/config/config.toml
sed -i.bak 's/seeds = \"\"/seeds = \"'$BOOTSTRAP_ID'@10.5.0.2:26656\"/g' data/chain/node-d/config/config.toml

sed -i.bak 's/addr_book_strict = true/addr_book_strict = false/g' data/chain/node-a/config/config.toml
sed -i.bak 's/addr_book_strict = true/addr_book_strict = false/g' data/chain/node-b/config/config.toml
sed -i.bak 's/addr_book_strict = true/addr_book_strict = false/g' data/chain/node-c/config/config.toml
sed -i.bak 's/addr_book_strict = true/addr_book_strict = false/g' data/chain/node-d/config/config.toml

echo "Node A mnemonic:" $(echo $NODE_A_KEY | jq -r .mnemonic)
echo "Node B mnemonic:" $(echo $NODE_B_KEY | jq -r .mnemonic)
echo "Node C mnemonic:" $(echo $NODE_C_KEY | jq -r .mnemonic)
echo "Node D mnemonic:" $(echo $NODE_D_KEY | jq -r .mnemonic)