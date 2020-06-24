variable "aws_region" {
  description = "AWS Region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "first_az_code" {
  description = "Code letter of the first availability zone to deploy to"
  type        = string
  default     = "a"
}

variable "second_az_code" {
  description = "Code letter of the second availability zone to deploy to"
  type        = string
  default     = "b"
}

variable "third_az_code" {
  description = "Code letter of the third availability zone to deploy to"
  type        = string
  default     = "c"
}

variable "aws_vpc_name" {
  description = "AWS VPC Name"
  type        = string
  default     = "k8s-vpc"
}

variable "aws_vpc_cidr" {
  description = "AWS VPC Network CIDR (must be a /16)"
  type        = string
  default     = "10.255.0.0/16"
}

variable "worker_instance_type" {
  description = "AWS worker node instance type"
  type        = string
  default     = "t3a.large"
}

variable "worker_asg_desired_capacity" {
  type        = number
  description = "Auto scaling group desired capacity for the worker group"
  default     = 3
}

variable "worker_asg_max_size" {
  type        = number
  description = "Auto scaling group maximum capacity for the worker group"
  default     = 5
}

variable "spot_price" {
  type        = number
  description = "Spot instance price"
  default     = 0.199
}

variable "spot_instance_type" {
  description = "AWS spot node instance type"
  type        = string
  default     = "t3a.large"
}

variable "spot_asg_desired_capacity" {
  type        = number
  description = "Auto scaling group desired capacity for the spot group"
  default     = 3
}

variable "spot_asg_max_size" {
  type        = number
  description = "Auto scaling group maximum capacity for the spot group"
  default     = 5
}

variable "eks_cluster_version" {
  description = "AWS EKS Cluster Version"
  type        = number
  default     = 1.16
}
