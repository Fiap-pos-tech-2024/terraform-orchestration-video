#!/bin/bash

set -e

cd cognito-terraform
COGNITO_USER_POOL_ID=$(terraform output -raw user_pool_id)
COGNITO_CLIENT_ID=$(terraform output -raw user_pool_client_id)
cd ..

cd db-terraform
DB_HOST=$(terraform output -raw rds_endpoint)
DB_USER=$(terraform output -raw rds_username)
DB_PASS="Senha123"
DB_NAME="fastfood"
DB_PORT=3306
cd ..

cd api-gateway-terraform
API_BASE_URL=$(terraform output -raw http_api_endpoint)
cd ..

cat <<EOF > .env.example
API_BASE_URL=$API_BASE_URL
COGNITO_CLIENT_ID=$COGNITO_CLIENT_ID
COGNITO_USER_POOL_ID=$COGNITO_USER_POOL_ID
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS
EOF
