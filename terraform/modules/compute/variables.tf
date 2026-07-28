variable "project_name" { type = string }
variable "environment" { type = string }
variable "tags" { type = map(string) }

variable "app_ami_id" {
  type    = string
  default = null
}

variable "app_instance_type" { type = string }
variable "app_port" { type = number }
variable "aws_region" { type = string }
variable "ecr_repository_url" { type = string }
variable "image_tag" { type = string }

variable "app_asg_min_size" { type = number }
variable "app_asg_max_size" { type = number }
variable "app_asg_desired_capacity" { type = number }

# Networking inputs
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

# Security inputs
variable "alb_security_group_id" { type = string }
variable "app_security_group_id" { type = string }
variable "ec2_instance_profile_name" { type = string }

variable "db_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret holding DB credentials."
}

variable "app_secrets_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret holding JWT signing keys."
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_name" {
  type        = string
  description = "Database name."
}

variable "cache_port" {
  type    = number
  default = 6379
}
variable "db_host" {
  type        = string
  description = "RDS primary endpoint hostname (no port) — passed directly from the database module's output."
}

variable "cache_host" {
  type        = string
  description = "ElastiCache primary endpoint hostname — passed directly from the storage module's output."
}