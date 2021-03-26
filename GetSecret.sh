#!/bin/bash
# export VAULT_ADDR=http://127.0.0.1:8007
export VAULT_AGENT_ADDR=http://127.0.0.1:8007
# Uncomment below to grab the vault token from the Vault agent's sink file. You really don't need to do this since we're using auto-auth in the Vault agent. So we can use the Vault agent's own token obtained from AppRole with the associated Policy to retrieve secrets from the Vault server.
while IFS= read -r line || [[ -n "$line" ]]; do
    export VAULT_TOKEN=$line
done < vault_token

echo "This is the Vault Address used: " $VAULT_ADDR
echo "This is the Vault Agent Address used: " $VAULT_AGENT_ADDR
echo "This is the Vault token: " $VAULT_TOKEN
vault token lookup

# Retrieve the secret using the Vault CLI
vault kv get -namespace=admin secret/test

# Retrieve the secret using CURL
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    $VAULT_AGENT_ADDR/v1/admin/secret/data/test | jq
