# Instructions

## Vault Server in HCP

Start an Enterprise [HCP Vault cluster](https://portal.cloud.hashicorp.com/)

Note: you don't need to run an enterprise Vault server for this demo. However, please don't use Vault server in dev mode. I've found that if you don't specify the vault token, the Vault agent will automatically use the root token from the Vault server running in dev mode.

## Vault Admin Token

Generate an admin token in the HCP Vault cluster and drop it into a new file and call it `vault_root_token.txt`. Make sure you don't check it into Git. I have an example file in `vault_root_token_example.txt`

## Run the Start script

In a new tab run the following:

```shell
./start.sh
```

## Update the Vault Address for the Agent Config

Update the `vault-agent-config.hcl` file with your Vault's address. Example:

```hcl
vault {
  address = "https://vault-cluster.vault.11eb622f-9648-4edd-x532-0242ac11000c.aws.hashicorp.cloud:8200"
}
```

## Run the Vault Agent

In a third tab run: 

```shell
vault agent -config vault-agent-config.hcl
```

### Copy the systemd vault-agent.service file to this folder: /etc/systemd/system/
sudo cp vault-agent.service /etc/systemd/system/

### Run the the service
sudo systemctl enable vault-agent
sudo systemctl restart vault-agent


## Retrieve the secret via Vault Agent

Now let's see how to retrieve secrets via the Vault agent without talking directly to Vault.

### Get Secret via Vault CLI and Curl
Run the following in a separate tab:

```shell
./GetSecret.sh
```

### Get Secret via Python HVAC Library

```shell
python vault.py
```




## My Observations

- If the Vault agent is restarted for whatever reason and you are using a wrapped secret_id:
  - Then you have to deliver the `wrapped secret_id` once again to a file where the Vault agent can read it. This can be done via a pipeline or a script tied to systemd for example.
  - This is regardless of whether you enable: `remove_secret_id_file_after_reading = true` because the wrapped token is only allowed to be read once.
- The only way to not worry about the vault agent restarting is to deliver the `secret_id` directly into a file to be read by the Vault agent. This `secret-id` would need to be long-lived and allowed to be used for an unlimited number of times. As you can see, this is not secure.
- The Vault agent can be used as a proxy to retrieve secrets from Vault. It has its own listener and an app could retrieve secrets via the Vault agent. The `use_auto_auth_token = false` under the cache stanza if set to false, will force the use of the token generated by the AppRole for the vault agent. The policy attached to that AppRole is what will also be used. If you set `use_auto_auth_token = true`, this will give preference to a Vault token that you can specify in your request to the Vault agent.
- The Vault agent can cache requests. These requests are for tokens and leased secrets. An example of a leased secret is a dynamic secret. KV secrets are non-leased secrets and won't get cached.
- Be careful when using Dev mode with the Vault server. I've found that if you don't specify the vault token, the Vault agent will automatically use the root token from the Vault server.
- You need to use the vault token from the Sink file when talking to the Vault agent as a proxy. This is demonstrated via the Vault CLI, CURL, and the python hvac library.
- When using the Vault CLI or CURL I can use either the VAULT_ADDR environment variable or the VAULT_AGENT_ADDR environment variable for the URL of the Vault Agent.
- When using the Python hvac library, I use the address of the Vault agent in the client initiation.

## References

- [Quick Overview on Vault Agent](https://learn.hashicorp.com/tutorials/vault/secure-introduction#vault-agent)
- [Vault Agent Caching](https://learn.hashicorp.com/tutorials/vault/agent-caching)
- [Vault Agent Caching Video](https://www.youtube.com/watch?v=PNtRk3wRtWM&t=933s)
- [Vault Agent Template Example Configuration](https://www.vaultproject.io/docs/agent/template#example-configuration)
