# ADR 003: Session Manager instead of a bastion host

## Status
Accepted — design applied via Terraform; live Session Manager connection
not yet manually verified (see Verification note below).

## Context
Instances in the private subnets need some way to be reached for
administration — running commands, checking logs, debugging. The
traditional pattern is a bastion host: a small EC2 instance in a public
subnet with port 22 open (usually restricted to a known IP range), which
administrators SSH into first, then hop from there to private instances.

The alternative is AWS Systems Manager Session Manager, which requires no
inbound port at all. An IAM role attached to the instance (via an instance
profile) grants it permission to register with the SSM service; the
`ssm`, `ssmmessages`, and `ec2messages` VPC interface endpoints from ADR
002 let it do that without needing internet access. Session Manager
sessions are then initiated from the AWS side (console or CLI) over that
existing outbound-registered connection — nothing needs to accept an
inbound connection on the instance at all.

The security module (`terraform/modules/security`) creates the IAM role,
attaches the AWS-managed `AmazonSSMManagedInstanceCore` policy, and builds
an instance profile from it. Neither security group created in this module
(`alb-sg`, `app-sg`) has an inbound rule for port 22, and none is planned.

## Decision
Use Session Manager exclusively for instance access. No bastion host will
be built anywhere in this project, and no security group will open port 22.

## Consequences

**Eliminated attack surface, not just reduced:** a bastion host is a
public-facing entry point that has to be patched, monitored, and is a
standing target regardless of how tightly its security group is scoped.
Session Manager removes that entire host and its inbound port instead of
just hardening it.

**Access control moves to IAM, which is a genuine trade-off, not a pure
win:** with a bastion, access control is "who has the SSH key / is in the
allowed CIDR." With Session Manager, it's "who has IAM permission to call
`ssm:StartSession`." This is arguably more auditable (every session shows
up in CloudTrail, and can be logged to S3/CloudWatch) but it does mean
IAM policy hygiene becomes the actual security boundary — a
misconfigured, over-broad IAM policy is now the equivalent risk that an
exposed bastion used to represent.

**Hard dependency on the chain built in ADR 002:** Session Manager access
depends on three things all being correct simultaneously — the instance's
IAM role/instance profile, the SSM interface endpoints being reachable
from the instance's subnet, and DNS hostnames being enabled on the VPC.
If any one of these is missing, Session Manager fails silently from the
instance's side (it just never registers), which can look like "instance
is broken" rather than "one specific piece of the SSM chain is missing."
This project hit exactly that kind of failure once already, in ADR 002's
DNS hostnames issue, which is good first-hand evidence of how this chain
can break.

## Verification note
The original Phase 2 plan called for launching a throwaway EC2 instance in
a private subnet with this instance profile attached, and confirming a
live Session Manager connection in the console before tearing the
instance down. That verification step was not yet performed as of this
ADR being written — the IAM role, instance profile, and endpoints are all
applied and should work, but "should work" and "confirmed working" are
different claims. Recommended before this environment is torn down: launch
one `t3.micro` in a private subnet with `ec2_instance_profile_name` from
Terraform outputs attached, confirm Session Manager connects, then
terminate it. Update this status to "Verified" once done.
