# ADR-006: Secrets and Runtime Configuration Injection at Boot

## Status
Accepted, Implemented

## Context
Following Phase 5's infrastructure work (RDS, ElastiCache), the backend container
continued to crash-loop with:

    Error: Invalid environment configuration: DATABASE_URL: Required, REDIS_URL: Required,
    JWT_SECRET: Required, JWT_REFRESH_SECRET: Required

Infrastructure existed, but nothing injected connection strings or application
secrets into the running container at boot. This ADR covers how that gap was closed.

## Decision

### Application secrets storage
JWT signing keys (`JWT_SECRET`, `JWT_REFRESH_SECRET`) are generated via Terraform's
`random_password` resource and stored in a dedicated Secrets Manager secret
(`fleetops-enterprise/prod/app-secrets`), separate from the existing database
credentials secret. Kept separate rather than combined into the DB secret, since
JWT signing keys and database credentials are conceptually distinct — one is an
app-level secret with no relationship to RDS, the other is a data-tier credential.

### Boot-time injection mechanism — two approaches attempted

**Attempt 1 (rejected): dynamic runtime discovery.**
The `user_data` script called `aws rds describe-db-instances` and
`aws elasticache describe-replication-groups` at boot to discover the database
and cache hostnames dynamically, rather than hardcoding them.

This failed in production: the EC2 IAM role had no permission for
`rds:DescribeDBInstances` or `elasticache:DescribeReplicationGroups`. Under
`set -e`, a failed command substitution (`VAR=$(failing-command)`) does not stop
script execution — the variable is simply assigned an empty string. This meant
`DB_HOST`/`CACHE_HOST` silently became empty strings, a subsequent TCP
readiness-check loop retried against an empty host for 30 attempts (2.5 minutes),
then exited — well before `docker run` was ever reached. The result was
consistent with a container that was never even started, and an Auto Scaling
Group repeatedly cycling failed instances.

**Attempt 2 (accepted): pass Terraform-known values directly.**
Terraform already knows the RDS primary hostname (`module.database.primary_address`)
and the ElastiCache primary endpoint (`module.storage.cache_primary_endpoint`) the
moment those resources are created. Rather than have the instance re-discover
these values via an AWS API call that requires its own IAM permissions, they are
passed directly into the `user_data` template as plain interpolated values at
`terraform apply` time.

This removes an entire failure mode (boot-time API dependency, and the specific
`set -e` gotcha above) and avoids granting `rds:Describe*`/`elasticache:Describe*`
permissions that would otherwise need to be unscoped (`resources = ["*"]`, since
these describe actions don't support resource-level ARN scoping) — a meaningful
least-privilege improvement, not just a bug fix.

The database/cache readiness-check loop (`wait_for_tcp`, retrying a raw TCP
connection before proceeding) was kept from the failed attempt — it remains a
legitimate safeguard against boot-ordering races between the instance and RDS/
ElastiCache becoming reachable, independent of how the hostname is obtained.

### Credential and secret fetching at boot
DB credentials and JWT secrets are fetched from their respective Secrets Manager
secrets via the instance's IAM role at boot (`aws secretsmanager get-secret-value`),
parsed with `jq`, and passed into the container via `docker run -e`. Nothing
sensitive is hardcoded in the launch template or committed to the repository.

## Consequences

### Benefits
- Backend container now boots successfully and passes ALB health checks — confirmed
  via a live `200 OK` response from `/api/health`.
- No new IAM permissions beyond `secretsmanager:GetSecretValue` (scoped to two
  specific secret ARNs) were needed for the working solution.
- Eliminates a boot-time dependency on RDS/ElastiCache describe API availability.

### Trade-offs
- If the RDS or ElastiCache endpoint ever changes outside of Terraform's knowledge
  (e.g., manual failover to a differently-named endpoint), the launch template
  would need to be re-applied to pick up the new value, since it's baked in at
  apply time rather than discovered dynamically. Given this project's Multi-AZ
  failover preserves the same DNS endpoint by design, this is a low-probability
  edge case, not a functional gap.

## Related ADRs
- ADR-005 — Data Layer Architecture (RDS Multi-AZ, ElastiCache, security groups)