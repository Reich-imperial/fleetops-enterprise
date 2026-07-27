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

# Optional: the EC2 IAM role name to attach additional policies to (role created in security module)
variable "ec2_role_name" {
  type    = string
  default = null
}

# Optional: DB secret and KMS ARNs so compute can attach a scoped policy to the EC2 role
variable "db_secret_arn" {
  type    = string
  default = null
}

variable "db_kms_key_arn" {
  type    = string
  default = null
}
