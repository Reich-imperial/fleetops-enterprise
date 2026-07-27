variable "project_name" {
  type    = string
  default = "fleetops-enterprise"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "app_ami_id" {
  type        = string
  default     = null
  description = "Optional AMI ID for application EC2 instances. If unset, the latest AL2023 AMI is resolved automatically."
}

variable "app_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL for the backend container image"
}

variable "image_tag" {
  type        = string
  default     = "backend-latest"
  description = "Image tag for the backend container. Frontend is out of scope for this phase."
}

variable "app_asg_min_size" {
  type    = number
  default = 2
}

variable "app_asg_max_size" {
  type    = number
  default = 10
}

variable "app_asg_desired_capacity" {
  type    = number
  default = 3
}

variable "db_username" {
  type        = string
  default     = "fleetops"
  description = "Database username for the RDS instance created by the database module"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class for the database module"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage (GB) for the RDS instance"
}

variable "db_engine_version" {
  type        = string
  default     = "15.4"
  description = "Postgres engine version for RDS"
}

variable "db_name" {
  type        = string
  default     = "fleetops"
  description = "Database name for RDS"
}

variable "db_kms_key_arn" {
  type        = string
  default     = null
  description = "Optional KMS key ARN used to encrypt DB secrets. If set, security module will scope KMS permissions to this ARN."
}
