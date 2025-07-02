# ☁️ Terraform Video Auth Service

Este módulo provisiona todos os recursos necessários para rodar o `video-auth-service` na AWS, incluindo ECS Fargate, ECR, Security Groups, Load Balancer e configurações de rede.

---

## 🔧 O que é provisionado

- ECS Cluster (compartilhado)
- ECS Task Definition e Service para o `video-auth-service`
- Container Docker publicado via GitHub Actions (ECR)
- Regras de roteamento no Application Load Balancer (ALB)
- Segurança com Security Groups configurados
- Variáveis de ambiente sensíveis injetadas dinamicamente
- Logs enviados ao CloudWatch
- Integração com:
  - Cognito (Auth)
  - MySQL (RDS via `user-db`)
  - Infraestrutura de rede compartilhada (VPC, Subnets)

---

## 📁 Estrutura de Arquivos

```bash
terraform-video-auth-service/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
```

---

## 📦 Dependências

Este módulo depende de quatro estados remotos provisionados previamente:

- `network` — VPC, subnets públicas, internet gateway
- `alb` — Load Balancer compartilhado
- `cognito` — User Pool e Client do AWS Cognito
- `user-db` — RDS com MySQL para armazenar os dados dos usuários

A configuração é feita via `data "terraform_remote_state"` no `main.tf`.

---

## 🧪 Pré-requisitos

- Terraform instalado
- AWS CLI configurado com permissões adequadas
- Acesso ao bucket `terraform-states-<aws_account_id>`

---

## 🚀 Como aplicar

```bash
# 1. Clone o repositório
git clone https://github.com/Fiap-pos-tech-2024/terraform-video-auth-service.git
cd terraform-video-auth-service

# 2. Configure as variáveis
cp terraform.tfvars.example terraform.tfvars
# Edite com seus valores (role, região, etc.)

# 3. Inicialize o Terraform
terraform init

# 4. Execute o plano e aplique
terraform plan
terraform apply
```

---

## 📄 terraform.tfvars (exemplo)

```hcl
execution_role_arn = "arn:aws:iam::019112154159:role/gh-actions-video-auth-service-role"
region             = "us-east-1"
```

---

## 🌐 Endpoint exposto

Seu serviço será acessível via ALB público na seguinte URL:

```
http://<ALB_DNS>/auth-docs
http://<ALB_DNS>/api/auth
http://<ALB_DNS>/api/usuarios
```

> O DNS é exportado pelo módulo `terraform-alb` e consumido aqui via `terraform_remote_state`.

---

## ➕ Como adicionar um novo microsserviço

1. Crie um novo repositório `terraform-nome-do-seu-servico`.
2. Copie este repositório como base.
3. No `main.tf`, edite:
   - Nome do serviço ECS
   - Porta usada pelo container
   - Caminhos da regra de roteamento no ALB
   - Nome do repositório no ECR
4. No `terraform.tfvars`, adicione a role específica para o novo serviço.
5. No repositório do serviço, configure o GitHub Actions com:
   ```yaml
   - name: Configure AWS credentials
     uses: aws-actions/configure-aws-credentials@v2
     with:
       role-to-assume: arn:aws:iam::<account_id>:role/gh-actions-nome-do-servico-role
       aws-region: us-east-1
   ```
6. Aplique o Terraform normalmente:
   ```bash
   terraform init
   terraform apply
   ```

> Lembre-se de configurar o módulo `terraform-github-oidc` para liberar a nova Role com base no repositório do microsserviço.

---

## 🔄 Deploy contínuo via GitHub Actions

Esse módulo está integrado ao CI/CD com OIDC + ECR + ECS. Ao fazer merge na branch `main` do repositório `video-auth-service`, uma nova imagem Docker é construída e publicada no ECR, e o ECS Service é atualizado automaticamente com `--force-new-deployment`.

---

## 🧾 Observações

- O container usa a porta 3000.
- O Health Check está configurado em `/health`.
- Logs estão sendo enviados para `/ecs/video-auth-service` no CloudWatch.
- Todas as variáveis sensíveis (como MySQL e Cognito) são passadas como variáveis de ambiente no container.

---

## 🧾 Licença

Uso acadêmico e profissional autorizado. Parte do projeto FIAP X.
