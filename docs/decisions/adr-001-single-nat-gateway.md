# ADR 001: Single NAT Gateway instead of one per AZ

## Status
Accepted

## Context
The networking module spans two Availability Zones (us-east-1a, us-east-1b)
with two private subnets, each of which needs outbound internet access for
things like OS updates and any external API calls that aren't covered by a
VPC endpoint. A NAT Gateway is the standard way to provide that.

The standard production pattern is one NAT Gateway per AZ, so that an
AZ failure doesn't take out egress for the other AZ's private subnet. Each
NAT Gateway costs roughly $0.045/hour (~$32/month) plus data processing
charges, so two NAT Gateways roughly doubles that fixed cost.

I built this by hand in the console before codifying it in Terraform. The
NAT Gateway sits in a single public subnet (`fleetops-public-1a`) and both
private route tables (`fleetops-private-rt`, associated with both AZs'
private subnets) point their `0.0.0.0/0` route at that one NAT Gateway's ID.

## Decision
Use a single NAT Gateway for this project, not one per AZ. The Terraform
module (`terraform/modules/networking`) supports both via the
`single_nat_gateway` boolean variable, defaulting to `true`.

## Consequences

**Accepted trade-off:** if the AZ hosting the NAT Gateway (`us-east-1a`)
has an outage, private-subnet instances in *both* AZs lose outbound
internet access, not just the instances in the affected AZ. This is a
real single point of failure for egress traffic.

**Why this is acceptable here:** this is a portfolio/learning project, not
a system with a production SLA. An AZ outage taking out egress for a few
hours has no real business consequence, and halving the fixed NAT cost is
a meaningful saving for a project running on personal infrastructure spend.
If this project graduated into something with actual uptime requirements,
flipping `single_nat_gateway = false` in the networking module is a
one-line change — the module is already built to support per-AZ NAT
Gateways without any structural rework.

**Note:** this trade-off is specifically about *egress* availability, not
inbound availability — the ALB and target instances themselves are still
multi-AZ regardless of this decision, so a NAT-affecting AZ outage would
degrade outbound calls from private instances, not take the application
down for inbound traffic.
