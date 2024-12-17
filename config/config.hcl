ui = true
disable_mlock = "true"

storage "raft" {
  path    = "/vault/data"
  node_id = "node1"
}

listener "tcp" {
  address = "[::]:8200"
  tls_disable = "false"
  tls_cert_file = "/certs/fullchain.pem"
  tls_key_file  = "/certs/privkey.pem"
}

api_addr = "https://${DOMAIN_NAME}:8200"
cluster_addr = "https://${DOMIAN_NAME}:8201"