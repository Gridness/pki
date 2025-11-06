#!/bin/bash

set -e

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
INIT_OUTPUT_FILE="vault_init.json"
KEYS_FILE="vault_keys.txt"
UNSEAL_THRESHOLD=2

function unseal_vault() {
    local unseal_keys
    local count

    unseal_keys=$(jq -r '.unseal_keys_b64[]' "$INIT_OUTPUT_FILE")
    count=0

    for key in $unseal_keys; do
        if [ $count -lt $UNSEAL_THRESHOLD ]; then
            echo "Unsealing with key $((count + 1)) / $UNSEAL_THRESHOLD"
            vault operator unseal "$key"
            ((count++))
        fi
    done

    echo "Vault unsealing complete"
}

function initialize_vault() {
    echo "Initializing vault"

    if vault operator init -status >/dev/null 2>&1; then
        echo "Vault already initialized"
        return 0
    else
        vault operator init \
            -key-shares=3 \
            -key-threshold=$UNSEAL_THRESHOLD \
            -fromat=json > "$INIT_OUTPUT_FILE"
    fi

    ROOT_TOKEN=$(jq -r '.root_token' "$INIT_OUTPUT_FILE")
    export VAULT_TOKEN="$ROOT_TOKEN"

    jq -r '.unseal_keys_b64[]' "$INIT_OUTPUT_FILE" > "$KEYS_FILE"

    echo "Root token saved to VAULT_TOKEN"

    unseal_vault
}

function run() {
    initialize_vault
}

run "$@" || exit 1
