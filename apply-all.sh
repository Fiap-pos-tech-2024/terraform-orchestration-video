#!/bin/bash

set -e

echo "🧹 Limpando arquivos locais antigos..."
for dir in terraform-*; do
  echo "🧼 Limpando $dir..."
  rm -rf "$dir/.terraform" \
         "$dir/terraform.tfstate" \
         "$dir/terraform.tfstate.backup" \
         "$dir/.terraform.lock.hcl"
done

echo "🚀 Iniciando execução em ordem correta..."

MODULES=(
  terraform-backend
  terraform-network
  terraform-cognito
  terraform-video-queues
  terraform-video-bucket
  terraform-user-db
  terraform-video-db
  terraform-alb
  terraform-github-oidc
  terraform-video-auth-service
  terraform-notification-service
  terraform-video-upload-service
  terraform-monitoring-grafana-alloy
)

for dir in "${MODULES[@]}"; do
  echo "📦 Entrando em $dir..."
  cd "$dir"
  terraform init -upgrade
  terraform apply -auto-approve
  cd ..
done

echo "✅ Infraestrutura aplicada com sucesso!"
