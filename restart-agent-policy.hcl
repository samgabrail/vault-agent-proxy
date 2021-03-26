// Policy to write wrapped secret-id created by Vault Admin
path "auth/approle/role/+/secret*" {
  capabilities = [ "create", "read", "update" ]
  min_wrapping_ttl = "100s"
  max_wrapping_ttl = "300s"
}