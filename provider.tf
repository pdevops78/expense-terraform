provider "vault" {
  address = "https://vault-internal.pdevops78.online:8200"
  skip_tls_verify = true
  token = var.vault_token
}


