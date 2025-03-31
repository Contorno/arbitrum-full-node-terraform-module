# Define variables for configurable parameters
variable "parent_chain_url" {
  description = "Ethereum RPC URL"
  type        = string
  default     = "https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY" # Replace with your URL
}

variable "beacon_url" {
  description = "Ethereum beacon chain RPC URL"
  type        = string
}

variable "chain_id" {
  description = "Arbitrum chain ID (e.g., 42161 for Arbitrum One, 42170 for Nova)"
  type        = string
  default     = "42161" # Replace with your chain ID
}

variable "local_arbitrum_dir" {
  description = "Local directory for Arbitrum data (host path)"
  type        = string
  default     = "/mnt/arbitrum-data"
}

# Deployment for the Arbitrum Nitro node
variable "snapshot_url" {
  description = "URL for the snapshot used to initialize the Arbitrum Nitro node"
  type = string
  default = "file:///home/user/.arbitrum/pruned.tar"
}