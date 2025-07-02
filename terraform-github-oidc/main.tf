terraform {
  backend "s3" {
    bucket = "terraform-states-019112154159"
    key    = "github-oidc/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    bucket = "terraform-states-019112154159"
    key    = "cognito/terraform.tfstate"
    region = "us-east-1"
  }
}

# OIDC provider do GitHub
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_oidc_roles" {
  for_each = var.services

  name = "gh-actions-${each.key}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${each.value.repository}:*"
          }
        }
      }
    ]
  })
}



# Policy de push ECR + update ECS + Cognito (com user_pool_id dinâmico)
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
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners"
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
        Resource = "arn:aws:cognito-idp:${var.region}:${var.aws_account_id}:userpool/${data.terraform_remote_state.cognito.outputs.user_pool_id}"
      }
    ]
  })
}

