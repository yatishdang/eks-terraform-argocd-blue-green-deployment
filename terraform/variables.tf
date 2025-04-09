variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}
variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnets_cidr" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "worker_instance_type" {
  description = "EC2 Instance Type"
  type = list(string)
}
