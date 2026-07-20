variable "project_name" {
  description = "Project name used as a prefix for resource naming/tags"
  type        = string
  default     = "fleetops-enterprise"
}

variable "environment" {
  description = "Environment name (single-environment for this project, but kept as a variable so it's a documented next step, not a hardcoded assumption)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across (exactly 2 for this project)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ, order matches var.azs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ, order matches var.azs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "single_nat_gateway" {
  description = "If true, deploy one NAT Gateway (in the first public subnet) shared by all private subnets. If false, deploy one NAT Gateway per AZ for HA. See ADR: why one vs two NAT Gateways."
  type        = bool
  default     = true
}

variable "enable_interface_endpoints" {
  description = "Whether to create interface VPC endpoints for ECR (api/dkr) and SSM (ssm/ssmmessages/ec2messages). Required for Session Manager access with no NAT dependency and for private-subnet ECR pulls."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}
