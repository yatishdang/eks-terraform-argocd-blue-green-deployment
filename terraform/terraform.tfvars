aws_region              = "us-east-1"
cluster_name            = "blue-green-eks-cluster"
vpc_cidr                = "10.0.0.0/16"
azs                     = ["us-east-1a", "us-east-1b"]
public_subnets_cidr     = ["10.0.101.0/24", "10.0.102.0/24"]
private_subnets_cidr    = ["10.0.1.0/24", "10.0.2.0/24"]
worker_instance_type    = ["t3.small"]
cluster_version         = "1.31"