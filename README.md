# 🚚 FleetOps Enterprise

Production-grade AWS infrastructure for Fleet Platform's trip-completion
reporting feature — an 11-phase capstone designed for AWS SAA-C03 prep and
DevOps/Cloud portfolio work.

> This project extends the Fleet Platform application layer with resilient,
> production-grade infrastructure spanning networking, data resiliency,
> event-driven reporting, edge protection, and observability.

## 💡 Why this project matters

When a trip transitions to `completed`, an asynchronous pipeline generates a PDF
report covering fuel usage, route summary, driver performance, and maintenance
flags, then notifies the fleet admin. Nearly every service in this architecture
exists to support that business flow.

## 📚 Documentation hub

The [docs/decisions](docs/decisions) folder holds the architectural decision
records (ADRs) for the major choices behind this platform. These documents
capture the reasoning, trade-offs, and future direction of the design so the
infrastructure remains understandable as it evolves.

- [docs/decisions](docs/decisions) — stores ADRs for important infrastructure decisions
- [docs/decisions/adr-005-data-layer-architecture.md](docs/decisions/adr-005-data-layer-architecture.md) — documents the Phase 5 data layer choices for RDS, Redis, replicas, and security groups

## 🏗️ Architecture at a glance

The main FleetOps architecture diagram below shows the end-to-end design for
this platform:

![FleetOps Enterprise Architecture](diagrams/FleetOps_Enterprise_Architecture.png)

### ✨ Architecture highlights

- **Networking**: VPC, public/private subnets across 2 AZs, IGW, NAT Gateway,
  and VPC Endpoints for S3, ECR, and SSM
- **Edge/DNS**: Route 53 failover health checks, ACM, CloudFront, and WAF
- **Compute**: Launch Template, Auto Scaling Group, ALB, Docker, and ECR
- **Data**: RDS PostgreSQL Multi-AZ with cross-region read replica, ElastiCache
  Redis, and S3 with Glacier lifecycle policies
- **Event-driven**: SQS → Lambda → S3 for reports and SNS for notifications
- **Security**: IAM least privilege, Secrets Manager, SSM Parameter Store, KMS,
  and Session Manager without a bastion host
- **Monitoring**: CloudWatch, X-Ray, Prometheus, and Grafana
- **Backup/DR**: AWS Backup, cross-region snapshot copy, documented RPO/RTO
- **Cost & delivery**: AWS Budgets, tagging, GitHub Actions, Terraform, and ASG
  instance refresh pipelines

### Diagram gallery

See the phase-by-phase visuals in the [diagrams](diagrams) folder:

- ![Phase 1-2 networking and security](diagrams/FleetOps_Phase_1_2.png)
- ![Phase 3 compute, ALB, target group, and ASG](diagrams/FleetOps_Phase_3.png)
- ![Phase 4 container and ECR architecture](diagrams/FleetOps_Phase_4.png)
- ![Phase 5 database and caching architecture](diagrams/FleetOps_Phase_5.png)

## ✅ Current state

Phases 1-5 are now implemented: networking, security, compute, container/ECR,
and the database + caching foundation are all in place. Phases 6+ continue as
progressive enhancements for storage, edge, secrets, monitoring, and
event-driven reporting.

## 📦 Repo layout

```text
terraform/
  modules/
    networking/     VPC, subnets, NAT, IGW, route tables, VPC endpoints
    security/       SGs, NACLs, IAM roles, Session Manager
    compute/        Launch template, ASG, ALB, target groups
    database/       RDS, read replica, ElastiCache
    storage/        S3, lifecycle rules
    messaging/      SQS, SNS, Lambda, EventBridge
    edge/           CloudFront, ACM, WAF, Route 53
    observability/  CloudWatch alarms, dashboards, X-Ray
  main.tf           wires modules together
  variables.tf
  outputs.tf
  backend.tf        S3 remote state
lambda/
  report-generator/  Phase 10: trip-completion report Lambda source
docs/
  decisions/         ADRs for the key architectural choices
diagrams/            architecture visuals updated by phase
.github/
  workflows/         Terraform plan/apply, Docker build/push, ASG refresh
```

## 🔧 Build method

Console-first for genuinely new services such as networking, RDS, or WAF, then
tear down the initial console resources and codify them in Terraform with
proper references. Terraform-managed state is the final source of truth for each
phase.

## 🧭 Phase tracker

| Phase | Scope | Status |
|-------|-------|--------|
| 1 | Networking foundation | ✅ Complete |
| 2 | Security foundation (SGs, NACLs, IAM, Session Manager) | ✅ Complete |
| 3 | Compute + ALB + ASG | ✅ Complete |
| 4 | Containerize + ECR + Terraform | ✅ Complete |
| 5 | RDS Multi-AZ + read replica + ElastiCache | ✅ Complete |
| 6 | S3 + lifecycle + CI/CD via ASG Instance Refresh | ⏳ Planned |
| 7 | Route 53 + ACM + CloudFront | ⏳ Planned |
| 8 | WAF + Secrets Manager + Parameter Store + KMS | ⏳ Planned |
| 9 | Monitoring (CloudWatch + Prometheus/Grafana) | ⏳ Planned |
| 10 | SQS + Lambda + SNS event-driven reports | ⏳ Planned |
| 11 | Backups + capstone (diagram, ADRs, cost, README, demo) | ⏳ Planned |

## ⚠️ Deliberate scope cuts

No GuardDuty, AWS Config, Shield, OpenSearch, or k6 are included in the current
scope. No live AZ-failure/DR drill is executed here; RPO/RTO are documented
instead. No Kubernetes workload is included in this repo, and a single Terraform
environment is used for the current implementation.

## 🔗 Related repos

- `fleet-platform` — the application this infrastructure serves
- `k8s-learning` — Kubernetes track (Minikube → Helm → EKS)
- `terraform-2tier` — earlier VPC/ALB/EC2 Terraform work
