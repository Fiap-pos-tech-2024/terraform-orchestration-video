# ☁️ Terraform Orchestration — Projeto Video Auth (FIAP X)

Este repositório contém a infraestrutura como código (IaC) do sistema de autenticação da plataforma de vídeos da FIAP X. Cada módulo é independente e representa uma parte da arquitetura em nuvem provisionada via **Terraform**.

---

## 📦 Estrutura de Módulos

```bash
terraform-orchestration-video/
├── terraform-backend/           # Criação do bucket S3 + DynamoDB para estados remotos
├── terraform-network/           # VPC, Subnets, IGW, roteamento
├── terraform-cognito/           # User Pool, App Client e configurações do Cognito
├── terraform-user-db/           # Banco de dados MySQL para armazenar os usuários
├── terraform-alb/               # Application Load Balancer compartilhado
├── terraform-github-oidc/       # Integração com GitHub Actions via OIDC
├── terraform-video-auth-service # ECS Fargate, Service, Task, SG e ECR para o microsserviço
```

Cada módulo é **isolado e com estado remoto próprio**, armazenado no bucket S3 `terraform-states-<AWS_ACCOUNT_ID>`.

---

## 🧭 Ordem de Execução Recomendada

```bash
# 1. Criar bucket S3 e DynamoDB para backend remoto (obrigatório)
cd terraform-backend
terraform apply

# 2. Provisionar rede compartilhada
cd terraform-network
terraform apply

# 3. Provisionar Cognito
cd terraform-cognito
terraform apply

# 4. Provisionar banco de dados do serviço de auth
cd terraform-user-db
terraform apply

# 5. Provisionar o Load Balancer compartilhado
cd terraform-alb
terraform apply

# 6. Provisionar integração com GitHub Actions (OIDC)
cd terraform-github-oidc
terraform apply

# 7. Provisionar o ECS do video-auth-service
cd terraform-video-auth-service
terraform apply
```

> ✅ A ordem acima respeita as dependências entre os módulos (por exemplo: `video-auth-service` depende do estado remoto de `network`, `alb`, `cognito` e `user-db`).

---

## 📘 Documentação por Módulo

Os módulos abaixo possuem `README.md` com orientações detalhadas:

- [`terraform-github-oidc`](./terraform-github-oidc) — Integração com GitHub Actions via OIDC  
- [`terraform-alb`](./terraform-alb) — Regras de roteamento para microsserviços via ALB  
- [`terraform-video-auth-service`](./terraform-video-auth-service) — Deploy ECS Fargate do microsserviço de autenticação

---

## 🔐 Segurança

Este projeto utiliza o padrão **GitHub OIDC + IAM Roles** para evitar o uso de credenciais estáticas. Nenhuma `AWS_SECRET_ACCESS_KEY` é armazenada em pipelines.

---

## 🧪 Ambientes e Observabilidade

- Deploy contínuo via GitHub Actions
- Logs no CloudWatch
- Métricas Prometheus disponíveis via `/metrics`
- Integração futura com Grafana

---

## 👩‍💻 Como adicionar um novo microsserviço

1. Criar um novo diretório `terraform-nome-do-servico`
2. Copiar o template de `terraform-video-auth-service`
3. Ajustar nomes, portas, variáveis, ALB e regras de segurança
4. Adicionar a role no módulo `terraform-github-oidc`
5. Aplicar normalmente com `terraform apply`

---

## 🧾 Licença

Uso acadêmico autorizado. Parte do projeto de pós-graduação da FIAP — FIAP X.
