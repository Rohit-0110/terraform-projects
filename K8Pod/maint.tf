data "aws_eks_cluster" "workspaces_eks" {
  name = "gitlab-workspaces"
}

data "aws_eks_cluster_auth" "workspaces_eks" {
  name = "gitlab-workspaces"
}

resource "kubernetes_pod_v1" "test" {
  metadata {
    name      = "app"
    namespace = "default"
  }

  spec {
    container {
      image = var.image
      name  = var.name
    }
  }
}