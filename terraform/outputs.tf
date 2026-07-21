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
