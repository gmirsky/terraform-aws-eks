aws_region                  = "us-east-1"
first_az_code               = "a"
second_az_code              = "b"
third_az_code               = "c"
aws_vpc_name                = "k8s-vpc"
aws_vpc_cidr                = "10.255.0.0/16"
worker_instance_type        = "t3a.large"
worker_asg_desired_capacity = 3
worker_asg_max_size         = 5
common_tags = {
  Owner             = "user"
  Environment       = "development"
  cost-center       = "00-0000.00"
  Role              = "EKS"
  terraform_managed = true
}
spot_price               = 0.199
spot_instance_type       = "t3a.large"
spot_asg_desired_capacit = 3
spot_asg_max_size        = 5