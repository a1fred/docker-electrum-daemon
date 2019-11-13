#!/usr/bin/env sh
set -ex

# Graceful shutdown
trap 'pkill -TERM -P1; electrum daemon stop; exit 0' SIGTERM

# Set config
electrum setconfig rpcuser ${ELECTRUM_USER}
electrum setconfig rpcpassword ${ELECTRUM_PASSWORD}
electrum setconfig rpchost 0.0.0.0
electrum setconfig rpcport 7000

# Run application
electrum daemon start

# Check load wallet or create
if [ ! -z "$ELECTRUM_SEED_PHRASE" ]
then
	echo "Seed defined. Perform wallet operations"

  if [ ! -e "/home/electrum/.electrum/wallets/default_wallet" ]
  then
    echo "default_wallet not exists. Creating from given seed."
    electrum restore --passphrase= "${ELECTRUM_SEED_PHRASE}"
  fi
else
	echo "Seed not defined. Skipping wallet creation"
fi

# Loading wallet if exists
if [ -e "/home/electrum/.electrum/wallets/default_wallet" ]
then
  echo "Loading wallet."
  electrum daemon load_wallet
fi

# Wait forever
while true; do
  tail -f /dev/null & wait ${!}
done
