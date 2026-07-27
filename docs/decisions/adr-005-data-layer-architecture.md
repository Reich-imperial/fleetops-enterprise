# ADR-005: Data Layer Architecture

## Status

Accepted

---

## Context

Phase 5 introduced the data layer for **FleetOps Enterprise**. Until this point, the backend application intentionally failed to start because the required `DATABASE_URL` and `REDIS_URL` dependencies did not exist. Provisioning Amazon RDS and ElastiCache completed the infrastructure required for the application to run.

Several architectural decisions needed to be made deliberately rather than inherited from a generic AWS reference architecture. These included:

- Database sizing
- Read replica placement
- Redis topology
- Security group design

The goal of this phase was to implement production-inspired patterns while keeping infrastructure cost aligned with a portfolio project.

---

## Decision

### 1. Database Sizing

The primary database is deployed using **Amazon RDS PostgreSQL (`db.t3.micro`)** in a **Multi-AZ** configuration.

This project does not have sustained production traffic, so a burstable instance provides sufficient capacity to validate:

- Multi-AZ deployment
- Automatic failover
- Private subnet connectivity
- Terraform provisioning
- Least-privilege network access

without introducing unnecessary cost.

---

### 2. Read Replica Placement

The original design proposed a **cross-region read replica** to mirror a disaster recovery architecture and reinforce AWS SAA-C03 concepts.

During implementation, the target Region did not contain a default VPC. Standing up additional networking solely to host a replica with no consuming workload was not proportionate to the learning goals of this project.

Instead, the read replica was deployed **within the same AWS Region**.

The replica retains the original naming convention (`fleetops-db-replica-usw2`) for implementation traceability, even though it is not a true cross-region deployment.

A genuine cross-region replica remains a future enhancement rather than an omitted capability.

---

### 3. Cache Architecture

Amazon ElastiCache Redis is deployed as a **single-node cache cluster** with **Cluster Mode disabled**.

The objectives of this phase are to validate:

- Redis integration
- Private subnet deployment
- Backend connectivity
- Terraform provisioning

Cluster Mode, sharding, and Multi-AZ failover introduce operational complexity that is unnecessary for the expected workload of this portfolio project.

---

### 4. Security Group Design

Separate security groups were created for the database and cache tiers:

- `db-sg`
- `cache-sg`

Both security groups allow inbound traffic **only** from `app-sg`.

Although a combined security group would reduce the Terraform resource count, separate groups better align with the layered security model introduced in Phase 2 and preserve least-privilege boundaries should database and cache access requirements diverge in the future.

---

## Consequences

### Benefits

- Multi-AZ RDS demonstrates production-inspired database deployment patterns.
- Separate security groups provide clearer service isolation and least-privilege access.
- Redis integration matches the application's current requirements without unnecessary complexity.
- Infrastructure cost remains appropriate for a portfolio project.

### Trade-offs

- The same-region read replica does **not** demonstrate true cross-region disaster recovery, including regional failover and replica promotion.
- Single-node Redis provides no high availability or sharding.
- Separate security groups introduce one additional Terraform resource, but improve architectural clarity and future flexibility.

---

## Alternatives Considered

### Cross-Region Read Replica

**Rejected for this phase.**

Although it more closely reflects a production disaster recovery architecture, it required building networking infrastructure in a second AWS Region with no consuming workload.

This may be revisited if disaster recovery becomes an explicit project objective.

---

### Combined Database and Cache Security Group

**Rejected.**

A single security group would have simplified the Terraform configuration, but separating PostgreSQL and Redis maintains clearer security boundaries and supports future policy changes without affecting unrelated services.

---

### Redis Cluster Mode

**Rejected.**

Cluster Mode introduces sharding and Multi-AZ failover capabilities that are unnecessary for this project's scale and learning objectives.

---

## Related ADRs

- **ADR-001** — Single NAT Gateway
- **ADR-002** — VPC Endpoints for AWS Services
- **ADR-003** — Session Manager Instead of a Bastion Host
- **ADR-004** — Auto Scaling Group Runs Backend Only; Frontend Deferred to CloudFront + S3

---

## Summary

This ADR captures four deliberate infrastructure decisions made during Phase 5:

- Multi-AZ RDS on `db.t3.micro`
- Same-region read replica as a documented scope reduction
- Single-node ElastiCache Redis with Cluster Mode disabled
- Separate security groups for the database and cache tiers

Together, these decisions prioritize production-inspired architecture, explicit trade-offs, and cost-conscious implementation while remaining aligned with the learning objectives of FleetOps Enterprise.