output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.networking.nat_gateway_ids
}

output "vpc_endpoints_security_group_id" {
  value = module.networking.vpc_endpoints_security_group_id
}

output "alb_security_group_id" {
  value = module.security.alb_security_group_id
}

output "app_security_group_id" {
  value = module.security.app_security_group_id
}

output "alb_arn" {
  value = module.compute.alb_arn
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "app_tg_arn" {
  value = module.compute.app_tg_arn
}

output "app_asg_name" {
  value = module.compute.app_asg_name
}

output "ec2_instance_profile_name" {
  value = module.security.ec2_instance_profile_name
}

output "db_primary_endpoint" {
  value       = module.database.primary_endpoint
  description = "Primary RDS endpoint (host:port)"
}

output "db_primary_address" {
  value       = module.database.primary_address
  description = "Primary RDS hostname"
}

output "db_secret_arn" {
  value       = module.database.db_secret_arn
  description = "Secrets Manager ARN for DB credentials"
}
output "cache_primary_endpoint" {
  value       = module.storage.cache_primary_endpoint
  description = "Redis primary endpoint — combine with cache_port for REDIS_URL."
}

output "cache_port" {
  value = module.storage.cache_port
}