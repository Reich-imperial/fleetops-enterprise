#!/bin/bash
set -e

# This script configures a backend container on Amazon Linux 2023.
# Secrets are fetched from AWS Secrets Manager at boot and injected into
# the container as environment variables. DB/cache hostnames are passed
# in directly from Terraform outputs — no runtime AWS API lookup needed.

dnf install -y docker jq
systemctl enable docker
systemctl start docker

REPO_HOST="${ecr_repository_host}"

aws ecr get-login-password --region "${aws_region}" | docker login --username AWS --password-stdin "$${REPO_HOST}"
docker pull "${ecr_repository_url}:${image_tag}"

wait_for_tcp() {
  local host="$1"
  local port="$2"
  local name="$3"
  local attempt=0

  until bash -c "cat < /dev/null > /dev/tcp/$${host}/$${port}" >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$${attempt}" -ge 30 ]; then
      echo "Timed out waiting for $${name} at $${host}:$${port}"
      exit 1
    fi
    echo "Waiting for $${name} at $${host}:$${port} ($${attempt}/30)..."
    sleep 5
  done
}

wait_for_tcp "${db_host}" "${db_port}" "database"
wait_for_tcp "${cache_host}" "${cache_port}" "redis"

DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "${db_secret_arn}" \
  --region "${aws_region}" \
  --query SecretString --output text)

DB_USERNAME=$(echo "$${DB_SECRET_JSON}" | jq -r '.username')
DB_PASSWORD=$(echo "$${DB_SECRET_JSON}" | jq -r '.password')

APP_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "${app_secrets_arn}" \
  --region "${aws_region}" \
  --query SecretString --output text)

JWT_SECRET=$(echo "$${APP_SECRET_JSON}" | jq -r '.jwt_secret')
JWT_REFRESH_SECRET=$(echo "$${APP_SECRET_JSON}" | jq -r '.jwt_refresh_secret')

DATABASE_URL="postgres://$${DB_USERNAME}:$${DB_PASSWORD}@${db_host}:${db_port}/${db_name}"
REDIS_URL="redis://${cache_host}:${cache_port}"

docker run -d --restart unless-stopped \
  -p "${app_port}:${app_port}" \
  -e PORT="${app_port}" \
  -e DATABASE_URL="$${DATABASE_URL}" \
  -e REDIS_URL="$${REDIS_URL}" \
  -e JWT_SECRET="$${JWT_SECRET}" \
  -e JWT_REFRESH_SECRET="$${JWT_REFRESH_SECRET}" \
  "${ecr_repository_url}:${image_tag}"