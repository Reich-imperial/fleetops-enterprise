variable "project_name" {
  type        = string
  description = "Used for resource naming and tagging, consistent with other modules"
}

variable "environment" {
  type        = string
  description = "Used for resource naming and tagging, consistent with other modules"
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs from the networking module to deploy the RDS instance into"
}
variable "db_security_group_id" {
  type        = string
  description = "The db-sg security group ID to associate with the RDS instance. Scoped to accept only from app-sg"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Per ADR-005 — burstable small instance, sufficient for this project's scale."
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "Storage in GB, no autoscaling - kept deterministic per ADR-005."
}
variable "db_engine_version" {
  type        = string
  default     = "15.4"
  description = "PostgreSQL version, must match what fleet-platform backend expects"
}
variable "db_name" {
  type        = string
  default     = "fleetops"
  description = "Database name, must match what fleet-platform backend expects"
}
variable "db_username" {
  type        = string
  description = "Database username, must match what fleet-platform backend expects"
}
variable "backup_retention_period" {
  type        = number
  default     = 1
  description = "Number of days to retain backups must be >= 1, per ADR-005"
}
variable "deletion_protection" {
  type        = bool
  default     = false
  description = "false by default for this learning project (matches the teardown workflow you're using). Flip to true deliberately if this ever needs to survive accidental deletes."
}