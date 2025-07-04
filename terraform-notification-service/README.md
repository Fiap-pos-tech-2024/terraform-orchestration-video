# 📧 Terraform - Notification Service

Este módulo provisiona a infraestrutura ECS para o **notification-service**, responsável por enviar notificações por e-mail.

---

## 📦 Recursos Criados

- **ECS Task Definition**: Container do notification service
- **ECS Service**: Gerenciamento e escalonamento do container
- **Security Group**: Controle de acesso de rede
- **CloudWatch Log Group**: Logs da aplicação

---

## 🔧 Configuração

### 1. **Criar arquivo terraform.tfvars**

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. **Configurar variáveis SMTP**

Edite o arquivo `terraform.tfvars`:

```hcl
smtp_user   = "seu-email@gmail.com"
smtp_pass   = "sua-senha-de-app"  # Use App Password para Gmail
from_email  = "seu-email@gmail.com"
from_name   = "Video Processing System"
```

> ⚠️ **Para Gmail**: Use uma [App Password](https://support.google.com/accounts/answer/185833) ao invés da senha normal.

---

## 🚀 Deploy

### 1. **Aplicar infraestrutura**

```bash
terraform init
terraform plan
terraform apply
```

### 2. **Build e Push da imagem Docker**

```bash
# No diretório do hacka-app-video-notification
cd ../../hacka-app-video-notification

# Login no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin SEU_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Criar repositório ECR
aws ecr create-repository --repository-name notification-service --region us-east-1

# Build e push
docker build -t notification-service:latest .
docker tag notification-service:latest SEU_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/notification-service:latest
docker push SEU_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/notification-service:latest
```

### 3. **Forçar novo deployment**

```bash
aws ecs update-service \
  --cluster microservices-cluster \
  --service notification-service \
  --force-new-deployment \
  --region us-east-1
```

---

## 🌐 Acesso

Após o deploy:

- **Swagger/Docs**: `http://ALB_DNS/notification-docs`
- **API Base**: `http://ALB_DNS/api/notifications`

---

## 🔗 Dependências

Este módulo depende dos seguintes recursos:

- ✅ `terraform-network` (VPC, subnets)
- ✅ `terraform-alb` (Load Balancer e Target Groups)
- ✅ `terraform-video-auth-service` (IAM roles do ECS)

---

## 📊 Endpoints da API

- `POST /api/notify/success` - Enviar notificação de sucesso
- `POST /api/notify/error` - Enviar notificação de erro
- `GET /docs` - Documentação Swagger

---

## 🔍 Monitoramento

Logs disponíveis em CloudWatch:
```bash
aws logs tail /ecs/notification-service --region us-east-1 --follow
```
