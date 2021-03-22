#!/usr/bin/bash
# export VAULT_ADDR=http://127.0.0.1:8201
export VAULT_ADDR=https://vault-cluster.vault.11eb622f-9648-4edd-ad91-0242ac11000c.aws.hashicorp.cloud:8200
export VAULT_NAMESPACE=admin
# Grab the vault root token from file
while IFS= read -r line || [[ -n "$line" ]]; do
    export VAULT_TOKEN=$line
done < vault_root_token.txt
# Create an approle
vault auth enable approle
vault policy write agent agent-policy.hcl
vault write auth/approle/role/agent \
    secret_id_ttl=2h \
    token_num_uses=100 \
    token_ttl=5h \
    token_max_ttl=24h \
    secret_id_num_uses=150 \
    token_policies="agent"

# Create a KV secret
vault kv put secret/test foo=bar

# Read the role_id and create a wrapped secret_id and store them in the proper location for the vault agent
vault read -field=role_id auth/approle/role/agent/role-id > ./webblog_role_id
# Uncomment below to use secret_id directly
# vault write -field=secret_id -f auth/approle/role/agent/secret-id > ./webblog_wrapped_secret_id
# Uncomment below to use the wrapped secret_id
vault write -field=wrapping_token -wrap-ttl=200s -f auth/approle/role/agent/secret-id > ./webblog_wrapped_secret_id