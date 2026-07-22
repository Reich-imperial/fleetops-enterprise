# ADR 004: ASG runs the backend container only; frontend deferred to CloudFront + S3

## Status
Accepted

## Context
While building the Phase 3 launch template's user data script (installing
Docker, pulling from ECR, running the app container), the original design
assumed a single unified application image with a generic `latest` tag.
Checking fleet-platform's actual GitHub Actions workflow
(`.github/workflows/deploy.yml`) showed this assumption was wrong: the
pipeline builds and pushes two separate images to the same ECR
repository, tagged `backend-*` and `frontend-*`. The existing deploy
workflow runs both, plus nginx, redis, and postgres, together via
docker-compose on a single EC2 instance over SSH - the exact
single-instance pattern this whole fleetops-enterprise project exists to
replace.

This meant a real decision was needed: should the ASG's launch template
run both containers per instance (replicating the current docker-compose
shape onto every ASG instance), or should the two concerns be split
according to what they actually are - a stateless API service and a set
of static assets?

Separately, this decision effectively resolved most of what the original
11-phase plan scoped as Phase 4 ("containerize + ECR + Terraform
everything"). Phase 3's launch template already pulls from ECR and runs
the container via Terraform-managed user data - there was no
additional containerization work left for Phase 4 to do once Phase 3 was
built correctly.

## Decision
The ASG runs the backend container only, on port 3000. The frontend is
explicitly out of scope for compute/ASG instances - it will be served as
static assets via S3 + CloudFront in Phase 7, which was already in the
original architecture list for other reasons (TLS termination, edge
caching) and is now also the correct home for frontend delivery, not an
additional service bolted on.

Phase 4 as originally scoped is considered folded into Phase 3 - the
ECR-pull-via-Terraform-user-data work Phase 4 was meant to cover was
already necessarily built in order to get Phase 3's launch template
working at all. Phase 4 will not be built as a separate, standalone
phase.

## Consequences

**This is the correct direction for the eventual architecture, not a
shortcut.** A stateless backend API scaling independently behind an ALB,
with static frontend assets served from CDN edge locations, is a more
correct separation of concerns than running both on every compute
instance - it means ASG scaling decisions are based on real API load, not
inflated by static asset serving that doesn't need compute at all.

**Real gap accepted until Phase 7 lands:** there is currently no way to
actually serve the frontend in this AWS environment - it exists only in
the old docker-compose deployment path, not in anything Terraform-managed
yet. This is a known, deliberate gap, not an oversight - flagging it here
so it isn't mistaken for something broken if noticed before Phase 7 is
built.

**Renumbering consequence:** with Phase 4 folded into Phase 3, the
project's phase count and READMEs' phase tracker need updating to reflect
that Phase 4 is complete-by-consequence, not a separate remaining task.
Update the phase tracker table in the root README accordingly.

**Discovery method worth naming:** this decision came from actually
reading the existing GitHub Actions workflow before writing infrastructure
against an assumption, rather than assuming a unified image existed
because that would have been simpler to build for. Worth treating as a
standing habit for the remaining phases - check what already exists in
fleet-platform's real deploy pipeline before designing new infrastructure
around a guessed shape of it.
