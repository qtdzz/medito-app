#!/bin/sh

# Retrieve current script directory
CURRENT_SCRIPT_PATH=$(dirname "$0") && \

# Form the path to api_keys.json
ENCRYPTED_API_KEYS_PATH="$CURRENT_SCRIPT_PATH/api_keys.json.gpg" && \
OUTPUT_API_KEYS_PATH="$CURRENT_SCRIPT_PATH/../../assets/api_keys.json" && \
# PASSPHRASE could be hardcoded here instead of reading from environment variable
PASSPHRASE=$MEDITO_API_KEYS_PASSPHRASE  && \
echo "Decrypting $ENCRYPTED_API_KEYS_PATH" && \

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$PASSPHRASE" \
--output $OUTPUT_API_KEYS_PATH $ENCRYPTED_API_KEYS_PATH