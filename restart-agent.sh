#!/bin/bash
export VAULT_ADDR=https://vault-cluster.vault.11eb622f-9648-4edd-ad91-0242ac11000c.aws.hashicorp.cloud:8200
export VAULT_NAMESPACE=admin
# Grab the restart approle creds from files
while IFS= read -r line || [[ -n "$line" ]]; do
    export RESTART_ROLE_ID=$line
done < /home/sam/vault-agent-proxy/restart_role_id
while IFS= read -r line || [[ -n "$line" ]]; do
    export RESTART_SECRET_ID=$line
done < /home/sam/vault-agent-proxy/restart_secret_id

# Authenticate to Vault with the restart AppRole creds
export VAULT_TOKEN=`vault write -field=token auth/approle/login role_id=$RESTART_ROLE_ID secret_id=$RESTART_SECRET_ID`
echo "Restart Token is: $VAULT_TOKEN"
vault token lookup
# Write a wrapped secret-id to the same file that the agent expects from its config
vault write -field=wrapping_token -wrap-ttl=200s -f auth/approle/role/agent/secret-id > /home/sam/vault-agent-proxy/webblog_wrapped_secret_id
# Start the agent
vault agent -config /home/sam/vault-agent-proxy/vault-agent-config.hcl
