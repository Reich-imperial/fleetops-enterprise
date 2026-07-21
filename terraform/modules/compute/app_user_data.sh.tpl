#!/bin/bash
set -e

# This script configures a backend container on Amazon Linux 2023.
# Secrets and environment variables (DATABASE_URL, JWT secrets, etc.) are
# intentionally NOT handled here; that will be added in Phase 8.

# Install Docker and start the service.
dnf install -y docker
systemctl enable docker
systemctl start docker

REPO_URL="${ecr_repository_url}"
REPO_HOST="${ecr_repository_host}"

# Log in to ECR and run the backend container.
aws ecr get-login-password --region "${aws_region}" | docker login --username AWS --password-stdin "$${REPO_HOST}"

docker pull "${ecr_repository_url}:${image_tag}"
docker run -d --restart unless-stopped -p "${app_port}:${app_port}" "${ecr_repository_url}:${image_tag}"
