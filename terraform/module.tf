module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 2.39.0"
  name                 = var.aws_vpc_name
  cidr                 = var.aws_vpc_cidr
  azs                  = local.aws_availability_zones
  private_subnets      = local.aws_private_subnet_cidrs
  public_subnets       = local.aws_public_subnet_cidrs
  enable_ipv6          = false
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  tags                 = local.common_tags
  vpc_tags = merge(
    local.aws_vpc_tags,
    local.common_tags
  )
}

module "eks" {
  source                                = "terraform-aws-modules/eks/aws"
  version                               = "~> 12.1.0"
  cluster_name                          = local.cluster_name
  cluster_version                       = var.eks_cluster_version
  subnets                               = module.vpc.public_subnets
  vpc_id                                = module.vpc.vpc_id
  enable_irsa                           = true
  cluster_create_security_group         = true
  cluster_create_timeout                = "30m"
  cluster_delete_timeout                = "15m"
  cluster_endpoint_private_access_cidrs = ["0.0.0.0/0"]
  cluster_endpoint_public_access        = true
  cluster_endpoint_public_access_cidrs  = ["0.0.0.0/0"]
  cluster_log_retention_in_days         = 90
  config_output_path                    = "./"
  manage_cluster_iam_resources          = true
  manage_worker_iam_resources           = true
  eks_oidc_root_ca_thumbprint           = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" #Thumbprint of Root CA for EKS OIDC, Valid until 2037
  worker_sg_ingress_from_port           = 22                                         #Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443).
  write_kubeconfig                      = true
  tags                                  = local.common_tags
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]
  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = var.worker_instance_type
      asg_desired_capacity = var.worker_asg_desired_capacity
      asg_max_size         = var.worker_asg_max_size
      suspended_processes  = ["AZRebalance"]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
    {
      name                 = "spot-worker-group"
      spot_price           = var.spot_price
      instance_type        = "c4.xlarge"
      asg_desired_capacity = var.spot_asg_desired_capacity
      asg_max_size         = var.spot_asg_max_size
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
    }
  ]
}

module "iam_assumable_role_admin" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "~> v2.6.0"
  create_role = true
  role_name   = "cluster-autoscaler"
  provider_url = replace(
    module.eks.cluster_oidc_issuer_url,
    "https://",
    ""
  )
  role_policy_arns = [
    aws_iam_policy.cluster_autoscaler.arn
  ]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"
  ]
}

module "ecr-repo" {
  source           = "trussworks/ecr-repo/aws"
  version          = "~> 1.0.0"
  container_name   = local.cluster_name
  ecr_policy       = data.aws_iam_policy_document.org_ecr.json
  lifecycle_policy = local.lifecycle_policy_json
  scan_on_push     = true
  tags = merge(
    local.aws_vpc_tags,
    local.common_tags
  )
}
