 variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "services" {
  description = "Lista de microsserviços com seus repositórios GitHub"
  type = map(object({
    repository = string
  }))
  default = {
    cliente-service = {
      repository = "eamaral/cliente-service"
    },
    pedido-service = {
      repository = "eamaral/pedido-service"
    },
    pagamento-service = {
      repository = "eamaral/pagamento-service"
    }
  }
}

# OIDC provider do GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# Role por serviço para GitHub Actions
resource "aws_iam_role" "github_oidc_roles" {
  for_each = var.services

  name = "gh-actions-${each.key}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${each.value.repository}:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# Policy de push ECR + update ECS
resource "aws_iam_role_policy" "ecr_ecs_and_cognito_permissions" {
  for_each = aws_iam_role.github_oidc_roles

  name = "ecr-ecs-cognito-policy"
  role = aws_iam_role.github_oidc_roles[each.key].name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:RespondToAuthChallenge"
        ],
        Resource = "arn:aws:cognito-idp:us-east-1:816069165502:userpool/us-east-1_NS0kvTWfX"
      }
    ]
  })
}


