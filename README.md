# fleetops-enterprise

Production-grade AWS infrastructure for Fleet Platform's trip-completion
reporting feature — an 11-phase capstone built for AWS SAA-C03 prep and
DevOps/Cloud portfolio work.

Extends `fleet-platform`'s application layer with resilient, production-grade
infrastructure: multi-AZ networking, RDS Multi-AZ + cross-region replica,
event-driven reporting (SQS → Lambda → S3/SNS), CDN + WAF, and full
observability.

## The driving feature

When a trip's status flips to `completed`, an async pipeline generates a PDF
report (fuel usage, route summary, driver performance, maintenance flags) and
emails it to the fleet admin. This single feature is the reason nearly every
service below exists — not a disconnected service demo.

## Architecture

See `diagrams/` for the current architecture diagram (updated each phase).

- **Networking**: VPC, public/private subnets (2 AZs), IGW, NAT Gateway, VPC
  Endpoints (S3, ECR, SSM)
- **Edge/DNS**: Route 53 (failover health checks), ACM, CloudFront, WAF
- **Compute**: Launch Template, ASG, ALB, Docker/ECR
- **Data**: RDS PostgreSQL Multi-AZ + cross-region read replica, ElastiCache
  Redis, S3 with Glacier lifecycle
- **Event-driven**: SQS → Lambda → S3 (report) + SNS (notify)
- **Security**: IAM least-privilege, Secrets Manager, SSM Parameter Store,
  KMS, Session Manager (no bastion, no port 22 anywhere)
- **Monitoring**: CloudWatch, X-Ray, Prometheus + Grafana
- **Backup/DR**: AWS Backup, cross-region RDS snapshot copy, documented
  RPO/RTO
- **Cost**: AWS Budgets, Cost Explorer, tagging
- **CI/CD**: GitHub Actions → Terraform plan (PR) → apply on merge → Docker →
  ECR → ASG Instance Refresh

## Repo layout

```
terraform/
  modules/
    networking/     VPC, subnets, NAT, IGW, route tables, VPC endpoints
    security/       SGs, NACLs, IAM roles, Session Manager
    compute/        Launch template, ASG, ALB, target groups
    database/       RDS, read replica, ElastiCache
    storage/        S3, lifecycle rules
    messaging/      SQS, SNS, Lambda, EventBridge
    edge/           CloudFront, ACM, WAF, Route 53
    observability/  CloudWatch alarms/dashboards, X-Ray
  main.tf           wires modules together
  variables.tf
  outputs.tf
  backend.tf        S3 remote state (terraform-state-samson-2tier)
lambda/
  report-generator/  Phase 10: trip-completion report Lambda source
docs/
  decisions/         ADRs — one per key architectural choice
diagrams/            architecture diagram, updated each phase
.github/
  workflows/         Terraform plan/apply, Docker build/push, ASG refresh
```

## Build method

Console first (for genuinely new services — networking, RDS, WAF) or straight
to CLI/Terraform (for things already built once elsewhere) → tear down
console resources → codify in Terraform with proper resource references →
Terraform-managed state is the final artifact per phase.

## Phase tracker

| Phase | Scope                                                   | Status |
|-------|----------------------------------------------------------|--------|
| 1     | Networking foundation                                     | ✅ scaffolded, not yet applied |
| 2     | Security foundation (SGs, NACLs, IAM, Session Manager)     | ⬜ |
| 3     | Compute + ALB + ASG                                        | ⬜ |
| 4     | Containerize + ECR + Terraform                             | ⬜ |
| 5     | RDS Multi-AZ + read replica + ElastiCache                  | ⬜ |
| 6     | S3 + lifecycle + CI/CD via ASG Instance Refresh             | ⬜ |
| 7     | Route 53 + ACM + CloudFront                                 | ⬜ |
| 8     | WAF + Secrets Manager + Parameter Store + KMS               | ⬜ |
| 9     | Monitoring (CloudWatch + Prometheus/Grafana)                | ⬜ |
| 10    | SQS + Lambda + SNS event-driven reports                     | ⬜ |
| 11    | Backups + capstone (diagram, ADRs, cost, README, demo)      | ⬜ |

## Deliberate scope cuts

No GuardDuty, AWS Config, Shield, OpenSearch, or k6 (future work only). No
live AZ-failure/DR drill — RPO/RTO is documented, not executed live. No
Kubernetes in this repo (see `k8s-learning`). Single Terraform environment
(dev/prod separation documented as a next step, not built).

## Related repos

- `fleet-platform` — the application this infrastructure serves
- `k8s-learning` — Kubernetes track (Minikube → Helm → EKS)
- `terraform-2tier` — earlier VPC/ALB/EC2 Terraform work
