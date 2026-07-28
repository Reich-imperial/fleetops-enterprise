variable "project_name" {
  type        = string
  description = "Used for resource naming and tagging, consistent with other modules."
}

variable "environment" {
  type        = string
  description = "e.g. dev/staging/prod — used in naming."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs from the networking module — ElastiCache must never sit in a public subnet."
}

variable "cache_security_group_id" {
  type        = string
  description = "The cache-sg ID from the security module, scoped to accept only from app-sg."
}

variable "cache_node_type" {
  type        = string
  default     = "cache.t3.micro"
  description = "Per ADR-005 — burstable small node, sufficient for this project's scale."
}

variable "cache_engine_version" {
  type        = string
  description = "Redis version — must match what fleet-platform's backend expects. Check docker-compose.yml's redis image tag."
}

variable "tags" {
  type    = map(string)
  default = {}
}