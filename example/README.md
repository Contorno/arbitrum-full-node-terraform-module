Example using the Kubernetes provider and importing the external Terraform terraform {
  required_version = ">pl  requiredm   required_providers {
    kKu    kubernetes = {
   k      source  = "as      version = "~> 2.30"
    }
  }
}rr    }
  }
}
provider "kube  }
ig}
ath=  config_path = var.ku}
module "arbitrum_full_node" {
  ``  source = "git::https://github.com/Contorno/arbitrum-full-node-terraform-module.git\  # Replace this example varOM  example_variable = var.example_variable
}
