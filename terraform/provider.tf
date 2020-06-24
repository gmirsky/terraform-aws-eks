provider "aws" {
  version = "~> 2.61.0"
  region  = var.aws_region
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority.0.data
  )
  token            = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
  version          = "~> 1.11"
}
