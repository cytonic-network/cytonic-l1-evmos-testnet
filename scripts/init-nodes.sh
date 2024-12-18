#!/bin/bash

CHAIN_HOME=/data
CHAIN_ID=cytonic_52225-1

mkdir -p ./data/chain

docker compose run --no-deps --rm node-a init node-a --chain-id $CHAIN_ID --home $CHAIN_HOME/node-a
docker compose run --no-deps --rm node-b init node-b --chain-id $CHAIN_ID --home $CHAIN_HOME/node-b
docker compose run --no-deps --rm node-c init node-c --chain-id $CHAIN_ID --home $CHAIN_HOME/node-c
docker compose run --no-deps --rm node-d init node-d --chain-id $CHAIN_ID --home $CHAIN_HOME/node-d

cp genesis.json data/chain/node-a/config

NODE_A_KEY=$(docker compose run --no-deps --rm node-a keys add validator-a --keyring-backend test --home $CHAIN_HOME/node-a --output json --no-backup | jq -r .address)
NODE_B_KEY=$(docker compose run --no-deps --rm node-b keys add validator-b --keyring-backend test --home $CHAIN_HOME/node-b --output json --no-backup | jq -r .address)
NODE_C_KEY=$(docker compose run --no-deps --rm node-c keys add validator-c --keyring-backend test --home $CHAIN_HOME/node-c --output json --no-backup | jq -r .address)
NODE_D_KEY=$(docker compose run --no-deps --rm node-d keys add validator-d --keyring-backend test --home $CHAIN_HOME/node-d --output json --no-backup | jq -r .address)

docker compose run --no-deps --rm node-a add-genesis-account $NODE_A_KEY 10000000000000000000000000000aevmos --home $CHAIN_HOME/node-a
docker compose run --no-deps --rm node-a add-genesis-account $NODE_B_KEY 10000000000000000000000000000aevmos --home $CHAIN_HOME/node-a
docker compose run --no-deps --rm node-a add-genesis-account $NODE_C_KEY 10000000000000000000000000000aevmos --home $CHAIN_HOME/node-a
docker compose run --no-deps --rm node-a add-genesis-account $NODE_D_KEY 10000000000000000000000000000aevmos --home $CHAIN_HOME/node-a

echo data/chain/node-b/config data/chain/node-c/config data/chain/node-d/config | xargs -n 1 cp data/chain/node-a/config/genesis.json

docker compose run --no-deps --rm node-a gentx validator-a 1000000000000000000aevmos --keyring-backend test --home $CHAIN_HOME/node-a --chain-id $CHAIN_ID
docker compose run --no-deps --rm node-b gentx validator-b 1000000000000000000aevmos --keyring-backend test --home $CHAIN_HOME/node-b --chain-id $CHAIN_ID --output-document $CHAIN_HOME/node-a/config/gentx/validator-b.json
docker compose run --no-deps --rm node-c gentx validator-c 1000000000000000000aevmos --keyring-backend test --home $CHAIN_HOME/node-c --chain-id $CHAIN_ID --output-document $CHAIN_HOME/node-a/config/gentx/validator-c.json
docker compose run --no-deps --rm node-d gentx validator-d 1000000000000000000aevmos --keyring-backend test --home $CHAIN_HOME/node-d --chain-id $CHAIN_ID --output-document $CHAIN_HOME/node-a/config/gentx/validator-d.json

docker compose run --rm node-a collect-gentxs --home $CHAIN_HOME/node-a

echo data/chain/node-b/config data/chain/node-c/config data/chain/node-d/config | xargs -n 1 cp data/chain/node-a/config/genesis.json

docker compose run --rm node-a validate-genesis --home $CHAIN_HOME/node-a

#sed -i.bak 's/seed_mode = false/seed_mode = true/g' data/chain/node-a/config/config.toml
BOOTSTRAP_ID=$(docker compose run --rm node-a tendermint show-node-id --home $CHAIN_HOME/node-a)

sed -i.bak 's/seeds = \"\"/seeds = \"'$BOOTSTRAP_ID'@10.5.0.2:26656\"/g' data/chain/node-b/config/config.toml
sed -i.bak 's/seeds = \"\"/seeds = \"'$BOOTSTRAP_ID'@10.5.0.2:26656\"/g' data/chain/node-c/config/config.toml
sed -i.bak 's/seeds = \"\"/seeds = \"'$BOOTSTRAP_ID'@10.5.0.2:26656\"/g' data/chain/node-d/config/config.toml

sed -i.bak 's/addr_book_strict = true/addr_book_strict = false/g' data/chain/node-a/config/config.toml
sed -i.bak 's/addr_book_strict = true/addr_book_strict = false/g' data/chain/node-b/config/config.toml
sed -i.bak 's/addr_book_strict = true/addr_book_strict = false/g' data/chain/node-c/config/config.toml
sed -i.bak 's/addr_book_strict = true/addr_book_strict = false/g' data/chain/node-d/config/config.toml