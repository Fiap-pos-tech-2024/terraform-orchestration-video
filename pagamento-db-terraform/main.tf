terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# DynamoDB PAY_PER_REQUEST (on-demand), sem necessidade de VPC
resource "aws_dynamodb_table" "pagamento" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = var.hash_key_name

  attribute {
    name = var.hash_key_name
    type = var.hash_key_type
  }

  tags = {
    Environment = var.environment
    Service     = "pagamento"
  }
}
