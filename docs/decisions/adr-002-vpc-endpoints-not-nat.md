# ADR 002: VPC Endpoints for ECR and SSM instead of routing through NAT

## Status
Accepted

## Context
Instances in the private subnets need two things that would otherwise
require internet access: pulling Docker images from ECR, and being managed
by Systems Manager (Session Manager, in particular — see ADR 003). Without
VPC endpoints, that traffic would route out through the NAT Gateway to the
public AWS endpoints for these services and back in.

AWS provides VPC Endpoints for both — a Gateway endpoint for S3 (which ECR
uses under the hood for image layers) and Interface endpoints for
`ecr.api`, `ecr.dkr`, `ssm`, `ssmmessages`, and `ec2messages`. Interface
endpoints create real ENIs inside the VPC's subnets with private IP
addresses; when DNS hostnames and private DNS resolution are enabled on
the VPC, the standard AWS service hostnames resolve to these private IPs
instead of the public internet endpoints, so traffic never leaves the VPC.

While building this by hand in the console, creating the first interface
endpoint failed with: *"Enabling private DNS requires both
enableDnsSupport and enableDnsHostnames VPC attributes set to true"* — the
VPC had DNS resolution on by default but DNS hostnames off, which had to
be explicitly enabled before any interface endpoint would work. This is
now baked into the Terraform module (`enable_dns_hostnames = true` on the
VPC resource) so it can't be missed on a fresh apply.

## Decision
Deploy VPC Endpoints for S3 (Gateway) and ECR API/DKR + SSM/SSM
Messages/EC2 Messages (Interface, one ENI per private subnet/AZ) rather
than letting this traffic route through the NAT Gateway.

## Consequences

**Cost trade-off, inverted from the usual assumption:** interface VPC
endpoints aren't free (roughly $0.01/hour each, ×5 endpoints ×730 hours ≈
$36.50/month, plus data processing), so on paper this looks like it adds
cost rather than saves it. But NAT Gateway data processing is charged
per-GB-processed, and ECR image pulls in particular can be large and
frequent (every deploy, every ASG instance-refresh cycle) — for anything
beyond light, occasional traffic, the endpoints pay for themselves by
keeping that volume off the NAT Gateway's metered path. For a project this
size, the actual dollar difference either way is small; the pattern is
what matters for a resume-facing project targeting SAA-C03-level judgment.

**Reliability:** Session Manager and ECR pulls no longer have any
dependency on the NAT Gateway's availability. Given ADR 001 accepts a
single NAT Gateway as a real single point of failure for general internet
egress, routing SSM and ECR traffic around that dependency entirely means
an AZ-level NAT outage wouldn't also take out the ability to manage
instances via Session Manager or deploy new container versions — those
keep working through the endpoints regardless of NAT Gateway health.

**Operational gotcha worth remembering:** `enable_dns_hostnames` is not on
by default when creating a "VPC only" (no wizard) in the console, only
`enable_dns_support` is. Any future VPC built by hand for a project needing
interface endpoints needs this checked explicitly, or endpoint creation
will fail with the exact error hit during this build.
