terraform {
  backend "s3" {
    bucket  = "terraform-states-fiap-20250706"
    key     = "ecs-shared-role/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
