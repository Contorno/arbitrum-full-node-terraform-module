# StorageClass for local filesystem storage
resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }
  volume_binding_mode = "WaitForFirstConsumer" # Binds when pod is scheduled
  storage_provisioner = "kubernetes.io/no-provisioner"
}

# PersistentVolume for the local filesystem
resource "kubernetes_persistent_volume" "arbitrum_pv" {
  metadata {
    name = "arbitrum-pv"
  }
  spec {
    capacity = {
      storage = "1500Gi" # Adjust size as needed
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain" # Keeps data after pod deletion
    storage_class_name = kubernetes_storage_class.local_storage.metadata[0].name
    persistent_volume_source {
      local {
        path = var.local_arbitrum_dir
      }
    }

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = [] # Replace with your node's hostname or leave empty for single-node clusters
          }
        }
      }
    }
  }
}

# PersistentVolumeClaim to request storage from the PV
resource "kubernetes_persistent_volume_claim" "arbitrum_pvc" {
  metadata {
    name      = "arbitrum-pvc"
    namespace = "default"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1500Gi" # Must match PV capacity
      }
    }
    storage_class_name = kubernetes_storage_class.local_storage.metadata[0].name
    volume_name        = kubernetes_persistent_volume.arbitrum_pv.metadata[0].name
  }
}

# Deployment for the Arbitrum Nitro node
resource "kubernetes_deployment" "nitro_node" {
  metadata {
    name      = "nitro-node"
    namespace = "default"
    labels = {
      app = "nitro-node"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nitro-node"
      }
    }
    template {
      metadata {
        labels = {
          app = "nitro-node"
        }
      }
      spec {
        container {
          name  = "nitro-node"
          image = "offchainlabs/nitro-node:v3.5.3-0a9c975"

          # Command-line arguments from the Docker command
          args = [
            "--parent-chain.connection.url=${var.parent_chain_url}",
            "--parent-chain.blob-client.beacon-url=${var.beacon_url}",
            "--chain.id=${var.chain_id}",
            "--init.latest=pruned",
            "--http.api=net,web3,eth",
            "--http.corsdomain=*",
            "--http.addr=0.0.0.0",
            "--http.vhosts=*"
          ]

          resources {
            requests = {
              cpu    = "4"
              memory = "16Gi"
            }
            limits = {
              cpu    = "8"
              memory = "32Gi"
            }
          }

          # Port mappings
          port {
            container_port = 8547
            protocol       = "TCP"
          }
          port {
            container_port = 8548
            protocol       = "TCP"
          }

          # Volume mount
          volume_mount {
            name       = "arbitrum-data"
            mount_path = "/home/user/.arbitrum"
          }
        }

        # Volume definition (using PVC for persistence)
        volume {
          name = "arbitrum-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.arbitrum_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# Service to expose the ports
resource "kubernetes_service" "nitro_node_service" {
  metadata {
    name      = "nitro-node-service"
    namespace = "default"
  }
  spec {
    selector = {
      app = "nitro-node"
    }
    port {
      name        = "http-rpc"
      port        = 8547
      target_port = 8547
      protocol    = "TCP"
    }
    port {
      name        = "websocket-rpc"
      port        = 8548
      target_port = 8548
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}