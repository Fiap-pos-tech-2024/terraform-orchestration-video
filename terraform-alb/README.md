# ☁️ Application Load Balancer (ALB) – Terraform Module

Este módulo provisiona um **ALB compartilhado** para microsserviços públicos em ECS Fargate. É responsável por:

- Criar o Load Balancer público
- Criar um Security Group padrão liberando porta 80 (HTTP)
- Criar um listener na porta 80
- Definir regras de roteamento (`listener_rule`) por path
- Criar `target_group` por microsserviço, compatível com ECS (IP-based)

---

## 📁 Estrutura de Arquivos

```bash
terraform-alb/
├── main.tf
├── variables.tf
├── outputs.tf
```

---

## ✅ Pré-requisitos

Este módulo depende dos outputs do módulo `network-terraform`:

- `vpc_id`
- `public_subnet_ids`

Esses valores são consumidos via `terraform_remote_state`.

---

## 🔀 Como adicionar um novo microsserviço

### 1. Criar um novo `aws_lb_target_group`

Cada microsserviço precisa de um target group com:

- Porta do container
- Health check path (ex: `/health`)
- `target_type = "ip"`

```hcl
resource "aws_lb_target_group" "meu_servico" {
  name        = "meu-servico-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
```

---

### 2. Criar a `listener_rule` com path personalizado

Cada regra precisa de:

- Prioridade única (ex: 40, 50, ...)
- Paths únicos para o microsserviço (ex: `/api/pedidos*`, `/docs*`, etc)

```hcl
resource "aws_lb_listener_rule" "meu_servico_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.meu_servico.arn
  }

  condition {
    path_pattern {
      values = ["/meu-docs*", "/api/meus-dados*", "/health"]
    }
  }
}
```

---

## 🔁 Exemplo de rota no backend

```js
app.use('/meu-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.get('/health', (_req, res) => res.send('OK'));
```

---

## 🔄 Como reaplicar

```bash
cd terraform-alb
terraform apply
```

---

## 📤 Outputs gerados

- `alb_dns_name`: domínio público do ALB
- `alb_security_group_id`: SG usado pelas tasks no ECS
- `*_target_group_arn`: ARNs de cada microsserviço (ex: `video_auth_service_target_group_arn`)

---

## 🧾 Licença

Infraestrutura compartilhada para projetos acadêmicos e profissionais com ECS + ALB + Terraform.
