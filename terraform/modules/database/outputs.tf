output "primary_endpoint" {
  value       = aws_db_instance.primary.endpoint
  description = "Primary RDS endpoint, host:port. Used to build DATABASE_URL."
}

output "primary_address" {
  value       = aws_db_instance.primary.address
  description = "Primary RDS hostname only (no port) — useful if you need to construct the URL manually."
}

output "replica_endpoint" {
  value       = aws_db_instance.replica.endpoint
  description = "Read replica endpoint — for read-heavy queries once the app supports read/write splitting (not wired into fleet-platform yet)."
}

output "db_secret_arn" {
  value       = try(aws_secretsmanager_secret.db[0].arn, var.existing_db_secret_arn)
  description = "ARN of the Secrets Manager secret holding username+password. Compute module or app runtime can fetch credentials from here instead of plaintext."
}

output "db_name" {
  value       = aws_db_instance.primary.db_name
  description = "Database name, needed alongside the endpoint to build a full connection string."
}