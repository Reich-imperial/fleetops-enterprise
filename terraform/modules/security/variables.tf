variable "project_name" {
  type    = string
  default = "fleetops-enterprise"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_id" {
  description = "VPC ID from the networking module"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR, used for internal-only rules"
  type        = string
}

variable "app_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 3000
}

variable "alb_ingress_cidrs" {
  description = "CIDRs allowed to reach the ALB on 80/443 (public internet by default)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "db_secret_arn" {
  type        = string
  default     = null
  description = "Optional ARN of the Secrets Manager secret that contains DB credentials. If set, the Secrets Manager IAM policy will be scoped to this ARN."
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "Optional KMS key ARN used to encrypt the DB secret. If set, the KMS permissions will be scoped to this ARN."
}
