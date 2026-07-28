# Phases 1-3 are wired in here: networking, security, and compute.
# Later phases will add database, storage, messaging, edge, observability, etc.
# Phase 3 currently provisions the backend compute stack behind an ALB.

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment

  # Defaults from the module cover the Phase 1 spec (2 AZs, single NAT).
  # Override here later if the single-NAT ADR conclusion changes.
}

module "database" {
  source = "./modules/database"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags

  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine_version    = var.db_engine_version
  db_name              = var.db_name
  db_username          = var.db_username

  private_subnet_ids = module.networking.private_subnet_ids

  db_security_group_id = module.security.db_security_group_id
}

module "security" {
  source = "./modules/security"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  vpc_cidr       = module.networking.vpc_cidr
  db_secret_arn  = module.database.db_secret_arn
  db_kms_key_arn = module.database.db_kms_key_arn

  # app_port and alb_ingress_cidrs use module defaults (3000, 0.0.0.0/0)
  # until Phase 3 makes the actual app port a real decision.
}
module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags

  app_ami_id         = var.app_ami_id
  app_instance_type  = var.app_instance_type
  app_port           = var.app_port
  aws_region         = var.aws_region
  ecr_repository_url = var.ecr_repository_url
  image_tag          = var.image_tag

  app_asg_min_size         = var.app_asg_min_size
  app_asg_max_size         = var.app_asg_max_size
  app_asg_desired_capacity = var.app_asg_desired_capacity

  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  alb_security_group_id     = module.security.alb_security_group_id
  app_security_group_id     = module.security.app_security_group_id
  ec2_instance_profile_name = module.security.ec2_instance_profile_name

  db_secret_arn   = module.database.db_secret_arn
  app_secrets_arn = module.security.app_secrets_arn
  db_host         = module.database.primary_address
  db_port         = module.database.db_port
  db_name         = module.database.db_name
  cache_host      = module.storage.cache_primary_endpoint
  cache_port      = 6379
}
module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags

  private_subnet_ids      = module.networking.private_subnet_ids
  cache_security_group_id = module.security.cache_security_group_id

  cache_node_type      = var.cache_node_type
  cache_engine_version = var.cache_engine_version
}
