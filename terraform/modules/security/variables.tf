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
  description = "ARN of the Secrets Manager secret that the EC2 role should read"
  type        = string
  default     = null
}

variable "db_kms_key_arn" {
  description = "ARN of the KMS key that the EC2 role may use to decrypt the database secret"
  type        = string
  default     = null
}

