terraform {
  required_version = ">= 1.11.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36.0"
    }
  }
}
provider "kubernetes" {
  config_path = var.kubeconfig_path
}
module "arbitrum_full_node" {
  source = "git::https://github.com/Contorno/arbitrum-full-node-terraform-module.git"

  parent_chain_url   = "https://eth-mainnet.g.alchemy.com/v2/example-api-key"
  beacon_url         = "https://beacon-nd-123-456-789.p2pify.com/example-api-key"
  chain_id           = "42161"  # Arbitrum One
  local_arbitrum_dir = "/mnt/arbitrum-data"
}
