output "alb_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.app_lb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.app_lb.dns_name
}

output "app_tg_arn" {
  description = "ARN of the application target group"
  value       = aws_lb_target_group.app_tg.arn
}

output "app_asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}
