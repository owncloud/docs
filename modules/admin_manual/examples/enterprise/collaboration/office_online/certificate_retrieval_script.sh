#!/usr/bin/env bash set -eo pipefail

VAULT_ADDR="${VAULT_ADDR:-https://vault.owncloud.com}"
VAULT_ROLE_ID="${VAULT_ROLE_ID:-6cf38a42-a1b0-0f5b-861c-128d7de08ba3}"
VAULT_SECRET_ID="${VAULT_SECRET_ID:-b6d7311d-292f-19f4-8428-295a0391764d}"
VAULT_PREFIX="${VAULT_PREFIX:-dehydrated}"

if [[ -z "$\{VAULT_TOKEN}" ]] then
    VAULT_TOKEN=$(curl -s -X POST -d "{"role_id":"$\{VAULT_ROLE_ID}","secret_id":"$\{VAULT_SECRET_ID}"}" $\{VAULT_ADDR}/v1/auth/approle/login | jq -r .auth.client_token) 
fi

RES="$(curl -s -X GET -H "X-Vault-Token: $\{VAULT_TOKEN}" $\{VAULT_ADDR}/v1/$\{VAULT_PREFIX}/owncloud.com/test)"

echo $\{RES} \ 
    | jq -r '.data.fullchain' \
    >| owncloud.crt echo $\{RES} \ 
    | jq -r '.data.key' \
    >| owncloud.key

openssl pkcs12 -export \
    -out owncloud.pfx \
    -inkey owncloud.key \
    -in owncloud.crt \
    -passout pass:
