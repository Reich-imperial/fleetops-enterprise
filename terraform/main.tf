# Phase 1: networking foundation only. Other modules (security, compute,
# database, storage, messaging, edge, observability) get wired in here as
# each phase lands — their inputs will pull from module.networking's outputs
# (e.g. compute's ASG will use module.networking.private_subnet_ids).

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment

  # Defaults from the module cover the Phase 1 spec (2 AZs, single NAT).
  # Override here later if the single-NAT ADR conclusion changes.
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  vpc_cidr     = module.networking.vpc_cidr

  # app_port and alb_ingress_cidrs use module defaults (3000, 0.0.0.0/0)
  # until Phase 3 makes the actual app port a real decision.
}
