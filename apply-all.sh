#!/bin/bash
set -e

echo ""
echo "🧹 Limpando todos os diretórios Terraform..."
for dir in */; do
  if [[ -f "$dir/main.tf" ]]; then
    echo "🧹 Limpando $dir"
    rm -rf "$dir/.terraform" "$dir/.terraform.lock.hcl" "$dir/terraform.tfstate" "$dir/terraform.tfstate.backup"
  fi
done

echo ""
echo "===== [1/7] network-terraform ====="
cd network-terraform
terraform init
terraform apply -auto-approve
VPC_ID=$(terraform output -raw vpc_id)
PRIVATE_SUBNETS=$(terraform output -json private_subnets)
PUBLIC_SUBNETS=$(terraform output -json public_subnets)
cd ..

echo ""
echo "===== [2/7] alb-terraform ====="
cd alb-terraform
terraform init
terraform apply -auto-approve \
  -var="vpc_id=$VPC_ID" \
  -var="private_subnets=$PRIVATE_SUBNETS" \
  -var="public_subnets=$PUBLIC_SUBNETS"
ALB_SG_ID=$(terraform output -raw alb_sg_id)
ALB_TARGET_GROUP_ARN=$(terraform output -raw alb_target_group_arn)
ALB_LISTENER_ARN=$(terraform output -raw alb_listener_arn)
ALB_DNS=$(terraform output -raw alb_dns)
cd ..

echo ""
echo "===== [3/7] cognito-terraform ====="
cd cognito-terraform
terraform init
terraform apply -auto-approve
COGNITO_USER_POOL_ID=$(terraform output -raw user_pool_id)
COGNITO_CLIENT_ID=$(terraform output -raw user_pool_client_id)
cd ..

echo ""
echo "===== [4/7] ecs-terraform ====="
cd ecs-terraform
terraform init
terraform apply -auto-approve \
  -var="vpc_id=$VPC_ID" \
  -var="private_subnets=$PRIVATE_SUBNETS" \
  -var="alb_sg_id=$ALB_SG_ID" \
  -var="alb_target_group_arn=$ALB_TARGET_GROUP_ARN" \
  -var="db_host=will_be_set_later" \
  -var="db_username=admin" \
  -var="db_password=Senha123" \
  -var="mercadopago_access_token=TEST-7513763222088119-102723-066d60f2c69bc1f0a4f4d4163d2b448a-163051303" \
  -var="mercadopago_public_key=TEST-5ae40bfd-d399-475d-914f-79a45924cf87" \
  -var="email_user=erik.fernandes87@gmail.com" \
  -var="email_pass=nanf erny zkzm vepg" \
  -var="cognito_user_pool_id=$COGNITO_USER_POOL_ID" \
  -var="cognito_client_id=$COGNITO_CLIENT_ID"
ECS_SERVICE_SG_ID=$(terraform output -raw ecs_service_sg_id)
cd ..

echo ""
echo "===== [5/7] db-terraform ====="
cd db-terraform
terraform init
terraform apply -auto-approve \
  -var="vpc_id=$VPC_ID" \
  -var="private_subnets=$PRIVATE_SUBNETS" \
  -var="ecs_service_sg_id=$ECS_SERVICE_SG_ID" \
  -var="db_username=admin" \
  -var="db_password=Senha123"
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)
cd ..

echo ""
echo "===== [6/7] ecs-terraform (redeploy com endpoint do banco) ====="
cd ecs-terraform
terraform apply -auto-approve \
  -var="vpc_id=$VPC_ID" \
  -var="private_subnets=$PRIVATE_SUBNETS" \
  -var="alb_sg_id=$ALB_SG_ID" \
  -var="alb_target_group_arn=$ALB_TARGET_GROUP_ARN" \
  -var="db_host=$RDS_ENDPOINT" \
  -var="db_username=admin" \
  -var="db_password=Senha123" \
  -var="mercadopago_access_token=TEST-7513763222088119-102723-066d60f2c69bc1f0a4f4d4163d2b448a-163051303" \
  -var="mercadopago_public_key=TEST-5ae40bfd-d399-475d-914f-79a45924cf87" \
  -var="email_user=erik.fernandes87@gmail.com" \
  -var="email_pass=nanf erny zkzm vepg" \
  -var="cognito_user_pool_id=$COGNITO_USER_POOL_ID" \
  -var="cognito_client_id=$COGNITO_CLIENT_ID"
cd ..

echo ""
echo "===== [7/7] api-gateway-terraform ====="
cd api-gateway-terraform
terraform init
terraform apply -auto-approve \
  -var="private_subnets=$PRIVATE_SUBNETS" \
  -var="alb_sg_id=$ALB_SG_ID" \
  -var="alb_listener_arn=$ALB_LISTENER_ARN"
API_URL=$(terraform output -raw api_gateway_url)
cd ..

echo ""
echo "✅ Infraestrutura criada com sucesso!"
echo ""
echo "🌐 Acesse sua aplicação em:"
echo "$API_URL"
echo ""
echo "📘 Swagger disponível em:"
echo "$API_URL/api-docs"