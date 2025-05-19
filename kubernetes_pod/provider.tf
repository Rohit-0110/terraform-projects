provider "aws" {
  region = "us-west-2"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.workspaces_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.workspaces_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.workspaces_eks.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.workspaces_eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.workspaces_eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.workspaces_eks.token
  }
}

 