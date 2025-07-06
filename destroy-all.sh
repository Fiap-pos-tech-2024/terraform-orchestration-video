#!/bin/bash

set -e

echo "⚠️ Iniciando destruição da infraestrutura (ordem reversa)..."

MODULES=(
  terraform-monitoring-grafana-alloy
  terraform-notification-service
  terraform-video-upload-service
  terraform-video-auth-service
  terraform-github-oidc
  terraform-alb
  terraform-user-db
  terraform-video-db
  terraform-video-queues
  terraform-cognito
  terraform-network
  terraform-backend
)

for dir in "${MODULES[@]}"; do
  echo "🔥 Destruindo $dir..."
  cd "$dir"
  terraform destroy -auto-approve
  cd ..
done

echo "✅ Toda a infraestrutura foi destruída."
