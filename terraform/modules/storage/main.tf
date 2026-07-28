# Phase TBD — not yet built. See README.md for the 11-phase build plan.
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project_name}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-cache-subnet-group"
  })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.project_name}-cache-primary"
  description          = "Single-node Redis cache for ${var.project_name}"

  engine         = "redis"
  engine_version = var.cache_engine_version
  node_type      = var.cache_node_type

  num_cache_clusters = 1

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [var.cache_security_group_id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = false

  automatic_failover_enabled = false
  multi_az_enabled           = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-cache-primary"
  })
}