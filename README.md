# ☁️ Terraform Orchestration — Projeto Video Auth (FIAP X)

Este repositório contém a infraestrutura como código (IaC) do sistema de autenticação da plataforma de vídeos da FIAP X. Cada módulo é independente e representa uma parte da arquitetura em nuvem provisionada via **Terraform**.

---

## 📦 Estrutura de Módulos

```bash
terraform-orchestration-video/
├── terraform-backend/               # Criação do bucket S3 para estados remotos
├── terraform-network/               # VPC, Subnets, IGW, roteamento
├── terraform-cognito/               # User Pool, App Client e configurações do Cognito
├── terraform-user-db/               # Banco de dados MySQL para armazenar os usuários
├── terraform-alb/                   # Application Load Balancer compartilhado
├── terraform-github-oidc/           # Integração com GitHub Actions via OIDC
├── terraform-video-auth-service/    # ECS Fargate, Service, Task, SG e ECR do microsserviço
├── terraform-monitoring-grafana-alloy/ # Observabilidade com Alloy + Prometheus remoto
```

Cada módulo é **isolado e com estado remoto próprio**, armazenado no bucket S3 `terraform-states-<AWS_ACCOUNT_ID>`.

---

## 🧭 Execução dos Módulos com Scripts Automatizados

Este repositório já inclui dois scripts para facilitar a aplicação e destruição completa da infraestrutura, respeitando as dependências entre os módulos:

### ✅ Aplicação completa

```bash
./apply-all.sh
```

Esse script executa:

- Limpeza de arquivos temporários de Terraform
- `terraform init` + `apply` para cada módulo na ordem correta
- Provisionamento completo do ambiente com um único comando

> Útil para configurar o ambiente do zero ou atualizar toda a infraestrutura de forma segura e padronizada.

---

### 🗑️ Destruição completa

```bash
./destroy-all.sh
```

Esse script executa:

- `terraform destroy` em todos os módulos
- Em ordem reversa para garantir a remoção correta dos recursos interdependentes

> Ideal para resetar o ambiente de desenvolvimento ou destruir a infraestrutura após a entrega do projeto.

---

## 📘 Documentação por Módulo

- [`terraform-github-oidc`](./terraform-github-oidc) — Integração com GitHub Actions via OIDC  
- [`terraform-alb`](./terraform-alb) — Regras de roteamento para microsserviços via ALB  
- [`terraform-video-auth-service`](./terraform-video-auth-service) — Deploy ECS Fargate do microsserviço de autenticação  
- [`terraform-monitoring-grafana-alloy`](./terraform-monitoring-grafana-alloy) — Observabilidade com Prometheus remoto via Alloy

---

## ⚠️ Configuração do módulo Grafana Alloy

O módulo `terraform-monitoring-grafana-alloy` exige que você forneça manualmente as credenciais da sua stack do Grafana Cloud.

### Como configurar

1. Acesse o Grafana Cloud em:
   ```
   https://fiapmicroservices.grafana.net
   ```

2. Vá em:  
   `Connections` → `Add new connection` → `Hosted Prometheus metrics`  
   > (Não use o menu de API Keys tradicional)

3. Clique em **"Create a new token"** e defina um nome. Isso irá gerar:
   - Seu **username**
   - Seu **token de API (password)** com escopo `set:alloy-data-write`

4. Edite o arquivo `terraform.tfvars` com os valores recebidos:

```hcl
grafana_username         = "<seu ID numérico de usuário no Grafana Cloud>"
grafana_password         = "<token gerado com set:alloy-data-write>"
grafana_remote_write_url = "https://<sua-stack>.grafana.net/api/prom/push"
```

> 🔐 Esses valores **não devem ser versionados no Git**. O arquivo `terraform.tfvars` já está no `.gitignore`.

---

## 🔐 Segurança

Este projeto utiliza o padrão **GitHub OIDC + IAM Roles** para evitar o uso de credenciais estáticas. Nenhuma `AWS_SECRET_ACCESS_KEY` é armazenada em pipelines.

---

## 🧪 Ambientes e Observabilidade

- Deploy contínuo via GitHub Actions
- Logs no CloudWatch
- Métricas Prometheus expostas em `/metrics` via ALB
- Visualização centralizada no Grafana Cloud:
  - Dashboard: [https://fiapmicroservices.grafana.net/d/video-auth-prom/video-auth-service-prometheus](https://fiapmicroservices.grafana.net/d/video-auth-prom/video-auth-service-prometheus)

### ℹ️ Importante para novos microsserviços

Não é necessário criar um módulo específico de observabilidade por serviço.

A stack `terraform-monitoring-grafana-alloy` já contempla a coleta de métricas de todos os serviços via ALB.

Para isso, basta garantir que sua aplicação:

- Exponha uma rota de métricas compatível com Prometheus  
  > Exemplo: `/auth-metrics`, `/pedido-metrics`, `/cliente-metrics`, etc.
- Esteja registrada no ALB (via `terraform-alb`) com path correspondente
- Use métricas com nomes e labels consistentes  
  (ex: `http_request_duration_seconds` com labels `method`, `route`, `status_code`)

---

## 👩‍💻 Como adicionar um novo microsserviço

1. Criar um novo diretório `terraform-nome-do-servico`
2. Copiar o template de `terraform-video-auth-service`
3. Ajustar nomes, portas, variáveis, ALB e regras de segurança
4. Adicionar a role no módulo `terraform-github-oidc`
5. Garantir que o serviço expõe `/metrics`
6. Aplicar normalmente com `terraform apply`

---

## 🧾 Licença

Uso acadêmico autorizado. Parte do projeto de pós-graduação da FIAP — FIAP X.
