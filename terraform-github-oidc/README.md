# ☁️ GitHub OIDC Terraform Module

Este módulo provisiona o **GitHub OIDC Provider** na AWS e uma **IAM Role por microsserviço**, permitindo que repositórios GitHub realizem deploys seguros via GitHub Actions **sem precisar de secret keys**.

---

## 🔐 O que é provisionado

- OIDC Provider com URL `https://token.actions.githubusercontent.com`
- Uma IAM Role por microsserviço (definido em `services`)
- Trust policy restrita ao repositório e branch `main`
- Permissões para:
  - Push de imagem no ECR
  - Atualização de serviço ECS
  - Operações no Cognito (create user, auth)

---

## 📁 Estrutura de Arquivos

```bash
terraform-github-oidc/
├── main.tf
├── variables.tf
├── terraform.tfvars
```

---

## 🔁 Exemplo de uso

### Em `variables.tf`:

```hcl
variable "services" {
  description = "Lista de microsserviços com seus repositórios GitHub"
  type = map(object({
    repository = string
  }))
  default = {
    video-auth-service = {
      repository = "Fiap-pos-tech-2024/video-auth-service"
    }
  }
}
```

### Em `terraform.tfvars`:

```hcl
aws_account_id = "816069165502"
```

> ⚠️ **Atenção:** Substitua o valor acima pelo **seu próprio `aws_account_id`**. Não utilize o ID da conta de exemplo (`816069165502`) para evitar conflitos e problemas de deploy.

---

## 📦 Integração com Cognito

Este módulo consome o `user_pool_id` dinamicamente via `terraform_remote_state` apontando para o estado remoto do módulo `cognito-terraform`.

```hcl
data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    bucket = "terraform-states-<seu-id>"
    key    = "cognito/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## 🚀 No repositório GitHub

Para que o repositório possa assumir a role criada, configure o workflow com:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: arn:aws:iam::<seu-id>:role/gh-actions-video-auth-service-role
    aws-region: us-east-1
```

---

## ➕ Como adicionar um novo microsserviço

1. No arquivo `variables.tf`, adicione na variável `services`:

```hcl
meu-novo-servico = {
  repository = "minha-org/meu-novo-servico"
}
```

2. Aplique o Terraform:

```bash
cd terraform-github-oidc
terraform apply
```

3. Use a role gerada no GitHub Actions:

```
gh-actions-meu-novo-servico-role
```

---

## 🧾 Licença

Uso acadêmico e profissional autorizado. Adaptado para projetos com CI/CD GitHub Actions via OIDC.
