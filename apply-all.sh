#!/bin/bash

set -e

echo "🧹 Limpando todos os artefatos locais anteriores de Terraform..."

# Limpeza profunda com find
find . -type d -name ".terraform" -exec rm -rf {} +
find . -type f -name "terraform.tfstate" -delete
find . -type f -name "terraform.tfstate.backup" -delete
find . -type f -name ".terraform.lock.hcl" -delete

# Lista de diretórios dos módulos em ordem
MODULES=(
  terraform-backend
  terraform-network
  terraform-cognito
  terraform-user-db
  terraform-alb
  terraform-github-oidc
  terraform-video-auth-service
  terraform-notification-service
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
