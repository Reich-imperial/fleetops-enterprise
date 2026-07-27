output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "ec2_iam_role_name" {
  value = aws_iam_role.ec2.name
}

output "ec2_iam_role_arn" {
  value = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "Attach this to the ASG launch template in Phase 3 to enable Session Manager"
  value       = aws_iam_instance_profile.ec2.name
}
output "db_security_group_id" {
  value       = aws_security_group.db.id
  description = "Security group ID for RDS — accepts only from app-sg on port 5432."
}

output "cache_security_group_id" {
  value       = aws_security_group.cache.id
  description = "Security group ID for ElastiCache — accepts only from app-sg on port 6379."
}
