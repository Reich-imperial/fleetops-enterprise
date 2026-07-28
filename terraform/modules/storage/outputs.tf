output "cache_primary_endpoint" {
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
  description = "Primary endpoint address for the Redis replication group — use for REDIS_URL (redis://<this>:6379)."
}

output "cache_port" {
  value       = aws_elasticache_replication_group.this.port
  description = "Redis port, needed to assemble the full REDIS_URL."
}