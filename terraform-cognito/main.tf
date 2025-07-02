terraform {
  backend "s3" {
    bucket = "terraform-states-019112154159"
    key    = "cognito/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_cognito_user_pool" "video_pool" {
  name = "video-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                    = 6
    require_lowercase                 = false
    require_numbers                   = false
    require_symbols                   = false
    require_uppercase                 = false
    temporary_password_validity_days  = 7
  }

  schema {
    name                = "cpf"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  mfa_configuration = "OFF"

  lifecycle {
    # impede que o Terraform tente remover ou modificar o bloco schema após a criação
    ignore_changes = [ schema ]
  }
}
 
resource "aws_cognito_user_pool_client" "video_pool_client" {
  name         = "video-user-pool-client"
  user_pool_id = aws_cognito_user_pool.video_pool.id

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false

  callback_urls = ["http://localhost:3000/callback"]
  logout_urls   = ["http://localhost:3000/logout"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  supported_identity_providers = ["COGNITO"]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30
}