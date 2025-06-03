# ☁️ Terraform Orchestration

Este repositório organiza toda a **infraestrutura dos microsserviços da lanchonete** na AWS usando **Terraform**. Cada pasta representa um módulo independente e reutilizável, seguindo uma estrutura desacoplada.

---

## 📦 Módulos

| Diretório                     | Função                                                           |
|------------------------------|------------------------------------------------------------------|
| `network-terraform/`         | Criação de VPC, Subnets, Internet Gateway, etc.                  |
| `cognito-terraform/`         | Autenticação com AWS Cognito (User Pool + App Client)            |
| `terraform-backend/`         | Criação do bucket S3 + DynamoDB para controlar o estado remoto   |
| `terraform-alb/`             | Load Balancer compartilhado entre os microsserviços              |
| `cliente-db-terraform/`      | Banco RDS MySQL para o cliente-service                           |
| `pedido-db-terraform/`       | Banco RDS MySQL para o pedido-service                            |
| `pagamento-db-terraform/`    | Tabela DynamoDB para o pagamento-service                         |
| `terraform-cliente-service/` | ECS Fargate para o cliente-service + ALB target group            |
| `terraform-pedido-service/`  | ECS Fargate para o pedido-service + ALB target group             |
| `terraform-pagamento-service/` | ECS Fargate para o pagamento-service + DynamoDB + MP Webhook  |
| `terraform-github-oidc/`     | Permissões para GitHub Actions assumirem roles com OIDC          |

---

## 🔁 Ordem de Execução

> Recomendado aplicar na seguinte ordem:

```bash
# Backend e estado remoto
cd terraform-backend
terraform init && terraform apply

# Infra de rede base
cd ../network-terraform
terraform init && terraform apply

# Autenticação
cd ../cognito-terraform
terraform init && terraform apply

# ALB compartilhado
cd ../terraform-alb
terraform init && terraform apply

# Databases
cd ../cliente-db-terraform && terraform apply
cd ../pedido-db-terraform && terraform apply
cd ../pagamento-db-terraform && terraform apply

# Roles GitHub OIDC
cd ../terraform-github-oidc
terraform apply

# Microsserviços
cd ../terraform-cliente-service
terraform apply

cd ../terraform-pedido-service
terraform apply

cd ../terraform-pagamento-service
terraform apply
```

> ⚠️ Certifique-se de preencher os `terraform.tfvars` com os outputs corretos entre módulos (ex: `subnet_ids`, `vpc_id`, `db_password`, etc).

---

## 📁 Backend Terraform

O controle de estado (`terraform.tfstate`) é feito de forma **centralizada**:

- Bucket: `terraform-states-816069165502`
- DynamoDB: para lock de estado
- Configurado no `terraform-backend/` e referenciado nos demais módulos

---

## 🧾 Licença

Projeto acadêmico com provisionamento completo na AWS usando IAC.

