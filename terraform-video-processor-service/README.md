# 🎬 Terraform Video Processor

Este módulo provisiona a infraestrutura para o serviço de processamento de vídeos na AWS.

## 📦 Recursos Provisionados

### 🐳 ECS (Elastic Container Service)
- **Task Definition**: `video-processor-task` com 512 CPU e 1024 MB de memória
- **Service**: `video-processor` rodando no Fargate
- **Container**: `maickway/video-processor:latest` exposto na porta 3000

### 🪣 S3 (Simple Storage Service)
- **Bucket**: `video-processor-storage-{suffix}` para armazenar vídeos e frames
- **Versionamento**: Habilitado
- **Criptografia**: AES256

### 📮 SQS (Simple Queue Service)
- **Queue Principal**: `video-processing-queue` para processamento de vídeos
- **Dead Letter Queue**: `video-processing-dlq` para mensagens com falha
- **Configurações**:
  - Tempo de visibilidade: 5 minutos
  - Retenção: 24 horas
  - Máximo de tentativas: 3

### 🔒 IAM (Identity and Access Management)
- **Role**: `video-processor-task-role` para o container ECS
- **Permissões**:
  - S3: Leitura, escrita e listagem do bucket
  - SQS: Receber, enviar e deletar mensagens

### 🔍 CloudWatch
- **Log Group**: `/ecs/video-processor` com retenção de 7 dias

### 🌐 Load Balancer Integration
- **Target Group**: `video-processor-tg` na porta 3000
- **Health Check**: `/health` endpoint
- **Roteamento**: Paths `/processor*`, `/api/video*`, `/video-docs*`

## 🔗 Dependências

Este módulo depende dos seguintes módulos:

1. **terraform-network**: VPC, subnets e configurações de rede
2. **terraform-alb**: Application Load Balancer compartilhado
3. **terraform-video-auth-service**: ECS Cluster e IAM roles

## 🚀 Como Usar

### Pré-requisitos

1. Aplicar os módulos dependentes primeiro:
   ```bash
   cd terraform-backend && terraform apply
   cd ../terraform-network && terraform apply
   cd ../terraform-alb && terraform apply
   cd ../terraform-video-auth-service && terraform apply
   ```

2. Ou usar o script automatizado:
   ```bash
   ./apply-all.sh
   ```

### Aplicação Individual

```bash
cd terraform-video-processor-service
terraform init
terraform apply
```

## 📋 Outputs

- `s3_bucket_name`: Nome do bucket S3
- `s3_bucket_arn`: ARN do bucket S3
- `sqs_queue_url`: URL da fila SQS principal
- `sqs_queue_arn`: ARN da fila SQS principal
- `sqs_dlq_url`: URL da fila DLQ
- `sqs_dlq_arn`: ARN da fila DLQ
- `ecs_service_name`: Nome do serviço ECS
- `ecs_task_definition_arn`: ARN da task definition
- `video_processor_task_role_arn`: ARN da IAM role

## 🌍 Variáveis de Ambiente

O container receberá as seguintes variáveis:

- `PORT=3000`: Porta da aplicação
- `AWS_REGION=us-east-1`: Região AWS
- `S3_BUCKET`: Nome do bucket S3 criado
- `SQS_QUEUE_URL`: URL da fila SQS
- `NODE_ENV=production`: Ambiente de produção

## 🔧 Configurações

- **CPU**: 512 unidades (0.5 vCPU)
- **Memória**: 1024 MB (1 GB)
- **Réplicas**: 1 instância
- **Health Check**: Endpoint `/health`

## 🗑️ Destruição

```bash
cd terraform-video-processor-service
terraform destroy
```

Ou usar o script automatizado:
```bash
./destroy-all.sh
```

## 📊 Monitoramento

- Logs disponíveis no CloudWatch: `/ecs/video-processor`
- Métricas do ECS disponíveis no CloudWatch
- Health checks via ALB Target Group
