#!/bin/bash

set -e

echo "⚠️ Iniciando destruição da infraestrutura (ordem reversa)..."

MODULES=(
  terraform-monitoring-grafana-alloy
  terraform-video-processor-service
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
  terraform-video-bucket
  terraform-backend
)

for dir in "${MODULES[@]}"; do
  echo "🔥 Destruindo $dir..."
  cd "$dir"
  terraform destroy -auto-approve || echo "⚠️ Falha ao destruir $dir — verifique manualmente."
  cd ..
done

echo "✅ Toda a infraestrutura foi destruída."
