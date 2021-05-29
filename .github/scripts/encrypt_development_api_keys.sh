#!/bin/sh

# Retrieve current script directory
CURRENT_SCRIPT_PATH=$(dirname "$0") && \

# Form the path to api_keys.json
API_KEYS_PATH="$CURRENT_SCRIPT_PATH/../../assets/api_keys.json" && \
# PASSPHRASE could be hardcoded here instead of reading from environment variable
PASSPHRASE=$MEDITO_API_KEYS_PASSPHRASE  && \
echo "Encrypting $API_KEYS_PATH" && \

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --symmetric --cipher-algo AES256 \
--passphrase="$PASSPHRASE" \
--output="$CURRENT_SCRIPT_PATH/api_keys.json.gpg" $API_KEYS_PATH
