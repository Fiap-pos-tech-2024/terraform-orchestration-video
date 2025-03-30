#!/bin/bash
set -e

echo ""
echo "===== [1/7] api-gateway-terraform ====="
cd api-gateway-terraform
terraform destroy -auto-approve || true
cd ..

echo ""
echo "===== [2/7] ecs-terraform ====="
cd ecs-terraform
terraform destroy -auto-approve || true
cd ..

echo ""
echo "===== [3/7] db-terraform ====="
cd db-terraform
terraform destroy -auto-approve || true
cd ..

echo ""
echo "===== [4/7] cognito-terraform ====="
cd cognito-terraform
terraform destroy -auto-approve || true
cd ..

echo ""
echo "===== [5/7] alb-terraform ====="
cd alb-terraform
terraform destroy -auto-approve || true
cd ..

echo ""
echo "===== [6/7] network-terraform ====="
cd network-terraform
terraform destroy -auto-approve || true
cd ..

echo ""
echo "✅ Infraestrutura destruída com sucesso!"
