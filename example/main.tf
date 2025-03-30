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
  # Replace this example variable with actual variable(s) from your module
  example_variable = var.example_variable
}
