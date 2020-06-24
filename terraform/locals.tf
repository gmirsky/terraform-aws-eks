locals {
  cluster_name                  = "eks-irsa-${lower(terraform.workspace)}"
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler"
  aws_availability_zones = [
    "${var.aws_region}${var.first_az_code}",
    "${var.aws_region}${var.second_az_code}",
    "${var.aws_region}${var.third_az_code}"
  ]
  aws_vpc_tags = {
    Name = "${var.aws_vpc_name}"
  }
  common_tags = {
    Environment       = lower(terraform.workspace)
    cost-center       = "00-0000.00"
    Role              = "EKS"
    created_by        = data.aws_caller_identity.current.arn
    terraform_managed = true
  }
  aws_private_subnet_cidrs = [
    cidrsubnet("${var.aws_vpc_cidr}", 8, 250),
    cidrsubnet("${var.aws_vpc_cidr}", 8, 251),
    cidrsubnet("${var.aws_vpc_cidr}", 8, 252)
  ]
  aws_public_subnet_cidrs = [
    cidrsubnet("${var.aws_vpc_cidr}", 8, 253),
    cidrsubnet("${var.aws_vpc_cidr}", 8, 254),
    cidrsubnet("${var.aws_vpc_cidr}", 8, 255)
  ]
  lifecycle_policy_json = file(
    "${path.module}/lifecycle-policy.json"
  )
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority.0.data
  )
}
