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
