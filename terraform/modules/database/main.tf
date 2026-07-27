 
// Allow using an existing Secrets Manager secret (JSON with username/password)
locals {
  use_existing_secret = var.existing_db_secret_arn != null && var.existing_db_secret_arn != ""
}

data "aws_secretsmanager_secret_version" "existing" {
  count     = local.use_existing_secret ? 1 : 0
  secret_id = var.existing_db_secret_arn
}

resource "random_password" "db" {
  count   = local.use_existing_secret ? 0 : 1
  length  = 20
  special = true
  override_special = "!#$%^&*()-_=+[]{};:,.<>?"
}

// Ensure tags variable is declared for module usage
variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}

resource "aws_secretsmanager_secret" "db" {
  count       = local.use_existing_secret ? 0 : 1
  name        = "${var.project_name}/${var.environment}/db-credentials"
  description = "RDS database credentials for ${var.project_name} in ${var.environment}"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  count = local.use_existing_secret ? 0 : 1
  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db[0].result
  })
}

locals {
  db_creds = local.use_existing_secret ? jsondecode(data.aws_secretsmanager_secret_version.existing[0].secret_string) : null
  db_username_resolved = local.use_existing_secret ? local.db_creds.username : var.db_username
  db_password_resolved = local.use_existing_secret ? local.db_creds.password : random_password.db[0].result
}
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}
resource "aws_db_instance" "primary" {
  identifier     = "${var.project_name}-db-primary"
  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = local.db_username_resolved
  password = local.db_password_resolved

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  storage_encrypted       = true

  deletion_protection = var.deletion_protection
  skip_final_snapshot = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-primary"
  })
}
resource "aws_db_instance" "replica" {
  identifier          = "${var.project_name}-db-replica"
  replicate_source_db = aws_db_instance.primary.identifier

  instance_class = var.db_instance_class

  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  skip_final_snapshot = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-replica"
  })
}