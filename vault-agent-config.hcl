pid_file = "./pidfile"

vault {
  address = "https://vault-cluster.vault.11eb622f-9648-4edd-ad91-0242ac11000c.aws.hashicorp.cloud:8200"
}

auto_auth {
  method "approle" {
    mount_path = "auth/approle"
    // Uncomment below to use Unwrapped Secret-id
      config = {
        role_id_file_path = "/home/sam/vault-agent-proxy/webblog_role_id"
        secret_id_file_path = "/home/sam/vault-agent-proxy/webblog_wrapped_secret_id"
        remove_secret_id_file_after_reading = false
        secret_id_response_wrapping_path = "auth/approle/role/agent/secret-id"
    }
    namespace = "admin"
    // Uncomment below to use Secret-id directly
    //   config = {
    //     role_id_file_path = "./webblog_role_id"
    //     secret_id_file_path = "./webblog_wrapped_secret_id"
    //     remove_secret_id_file_after_reading = false
    // }
  }

  sink "file" {
    config = {
      path = "/home/sam/vault-agent-proxy/vault_token"
      mode = 0644
      }
    }
}

listener "tcp" {
  address = "127.0.0.1:8007"
  tls_disable = true
}

cache {
  use_auto_auth_token = true
}
