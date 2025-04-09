provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig-blue-green.yaml"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}