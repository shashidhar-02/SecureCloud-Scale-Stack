variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "eks_cluster_version" {
  type = string
}

variable "eks_instance_types" {
  type = list(string)
}

variable "eks_desired_size" {
  type = number
}

variable "eks_min_size" {
  type = number
}

variable "eks_max_size" {
  type = number
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to access EKS public endpoint"
  type        = list(string)
}

variable "rds_engine_version" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_allocated_storage" {
  type = number
}

variable "db_username" {
  type = string
}

variable "tags" {
  description = "Fortune 500 mandatory resource tagging"
  type        = map(string)
  default     = {}
}
