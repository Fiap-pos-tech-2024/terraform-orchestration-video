#!/bin/bash

set -e

echo "🧹 Limpando todos os artefatos locais anteriores de Terraform..."

# Limpeza profunda com find
find . -type d -name ".terraform" -exec rm -rf {} +
find . -type f -name "terraform.tfstate" -delete
find . -type f -name "terraform.tfstate.backup" -delete
find . -type f -name ".terraform.lock.hcl" -delete

# Ordem de execução
MODULES=(
  terraform-backend
  terraform-network
  terraform-ecs-shared-role
  terraform-cognito
  terraform-video-queues
  terraform-video-bucket
  terraform-user-db
  terraform-video-db
  terraform-alb
  terraform-github-oidc
  terraform-video-auth-service
  terraform-notification-service
  terraform-video-processor-service
  terraform-video-upload-service
  terraform-monitoring-grafana-alloy
)

echo "🚀 Iniciando execução em ordem correta..."

for dir in "${MODULES[@]}"; do
  echo "📦 Entrando em $dir..."
  cd "$dir"
  terraform init -upgrade -reconfigure
  terraform apply -auto-approve
  cd ..
done

echo "✅ Infraestrutura aplicada com sucesso!"
