terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}


provider "kubernetes" {
  # Configure the Kubernetes provider to use your cluster
  config_path = "~/.kube/config"
}
